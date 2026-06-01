import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/controller.dart';
import 'package:fl_croc/core/controller.dart';
import 'package:fl_croc/enum/enum.dart';
import 'package:fl_croc/l10n/l10n.dart';
import 'package:fl_croc/models/models.dart';
import 'package:fl_croc/providers/providers.dart';
import 'package:fl_croc/state.dart';
import 'package:fl_croc/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

/// Data emitted by [QuickTransferWidget.statusNotifier] for the AppBar chip.
class QuickStatus {
  final String label;
  final Color color;
  final double progress; // 0.0–1.0, or -1 for indeterminate

  const QuickStatus({required this.label, required this.color, this.progress = -1});
}

/// Unified quick send + receive card for the dashboard.
///
/// Layout: [File/Text toggle] [file/text area] [Send] [Settings] [Receive]
///
/// The static [statusNotifier] emits the current transfer phase so the parent
/// dashboard can show a status chip in its AppBar.
class QuickTransferWidget extends ConsumerStatefulWidget {
  const QuickTransferWidget({super.key});

  /// Emits a [QuickStatus] when a transfer is active; null when idle.
  static final statusNotifier = ValueNotifier<QuickStatus?>(null);

  @override
  ConsumerState<QuickTransferWidget> createState() => _QuickTransferWidgetState();
}

enum _QuickPhase { idle, sending, receiving, completed, failed, cancelled }

class _QuickTransferWidgetState extends ConsumerState<QuickTransferWidget> {
  final _textCtrl = TextEditingController();
  bool _isTextMode = false;
  List<PlatformFile> _selectedFiles = [];
  _QuickPhase _phase = _QuickPhase.idle;
  String? _activeTransferId;
  TransferRecord? _activeRecord;
  StreamSubscription<TransferProgress>? _activeSub;
  String? _selectedFolder;

  // Quick codes
  String _quickSendCode = 'shimo-kita-1145';
  String _quickReceiveCode = 'shimo-kita-1145';
  bool _useSameCode = true;

  // Receive results (shown in input area)
  final List<FileItem> _receivedFiles = [];
  String _receivedText = '';

  double _simProgress = 0;
  Timer? _progressTimer;

  // Clipboard toggle: long-press paste button to switch paste/copy
  bool _isPasteMode = true;

  // File picker toggle: long-press to switch file/folder mode
  bool _isFolderPicker = false;

  static const _defaultCode = 'shimo-kita-1145';

  static const _prefQuickSendCode = 'quick_send_code';
  static const _prefQuickReceiveCode = 'quick_receive_code';
  static const _prefUseSameCode = 'quick_use_same_code';

  @override
  void initState() {
    super.initState();
    // Load saved values; keep defaults if never configured
    final savedSend = AppPrefs.getString(_prefQuickSendCode);
    final savedRecv = AppPrefs.getString(_prefQuickReceiveCode);
    _quickSendCode = savedSend.isNotEmpty ? savedSend : _defaultCode;
    _quickReceiveCode = savedRecv.isNotEmpty ? savedRecv : _defaultCode;
    _useSameCode = AppPrefs.getBool(_prefUseSameCode, true);
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _textCtrl.dispose();
    QuickTransferWidget.statusNotifier.value = null;
    super.dispose();
  }

  // ── Helpers ──

  bool get _isActive => _phase != _QuickPhase.idle && _phase != _QuickPhase.completed && _phase != _QuickPhase.failed && _phase != _QuickPhase.cancelled;

  void _cancelTransfer() {
    _progressTimer?.cancel();
    _activeSub?.cancel();
    _activeSub = null;
    if (_activeTransferId != null) {
      coreController.cancelTransfer(_activeTransferId!);
    }
    if (_activeRecord != null) {
      appController.updateTransferRecord(
        _activeRecord!.copyWith(status: TransferStatus.cancelled, endTime: DateTime.now()),
      );
    }
    _setPhase(_QuickPhase.cancelled);
    Future.delayed(const Duration(seconds: 1), () => _setPhase(_QuickPhase.idle));
  }

  void _clearFiles() => setState(() { _selectedFiles.clear(); _selectedFolder = null; });
  void _clearText() => _textCtrl.clear();
  void _removeFile(int index) => setState(() => _selectedFiles.removeAt(index));

  void _onTextDrop(List<File> files) {
    for (final f in files) {
      if (!FileSystemEntity.isDirectorySync(f.path)) {
        try {
          _textCtrl.text = f.readAsStringSync();
          _textCtrl.selection = TextSelection.collapsed(offset: _textCtrl.text.length);
          return;
        } catch (_) {}
      }
    }
  }

  void _onFileDrop(List<File> files) {
    // Check for directories first
    for (final f in files) {
      final path = f.path.endsWith(Platform.pathSeparator)
          ? f.path.substring(0, f.path.length - 1)
          : f.path;
      if (FileSystemEntity.isDirectorySync(path) || Directory(path).existsSync()) {
        setState(() {
          _selectedFolder = path;
          _selectedFiles.clear();
        });
        return;
      }
    }
    // Add files
    final newFiles = <PlatformFile>[];
    for (final f in files) {
      if (!FileSystemEntity.isDirectorySync(f.path) &&
          !_selectedFiles.any((s) => s.path == f.path)) {
        newFiles.add(PlatformFile(name: f.path.split(Platform.pathSeparator).last, path: f.path, size: f.lengthSync()));
      }
    }
    if (newFiles.isNotEmpty) setState(() => _selectedFiles.addAll(newFiles));
  }

  Future<void> _pickFolder() async {
    final path = await FilePicker.platform.getDirectoryPath();
    if (path != null) {
      setState(() {
        _selectedFolder = path;
        _selectedFiles.clear();
      });
    }
  }

  Future<void> _pasteText() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      _textCtrl.text = data.text!;
      _textCtrl.selection = TextSelection.collapsed(offset: _textCtrl.text.length);
    }
  }

  Future<void> _pickTextFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'md', 'json', 'xml', 'csv', 'log', 'yaml', 'yml', 'toml', 'ini', 'cfg'],
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.path == null) return;
    try {
      final content = await File(file.path!).readAsString();
      _textCtrl.text = content;
      _textCtrl.selection = TextSelection.collapsed(offset: _textCtrl.text.length);
    } catch (_) {
      if (mounted) context.showSnackBar(context.appLocalizations.sendFailed);
    }
  }

  Future<void> _copyText() async {
    if (_textCtrl.text.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: _textCtrl.text));
    }
  }

  // ── Settings dialog ──

  void _showSettings() {
    final l10n = context.appLocalizations;
    final sendCtrl = TextEditingController(text: _quickSendCode);
    final recvCtrl = TextEditingController(text: _quickReceiveCode);
    var same = _useSameCode;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) {
          return AlertDialog(
            title: Text(l10n.quickSettings),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  title: Text(l10n.quickSameCode),
                  value: same,
                  onChanged: (v) => setDialog(() => same = v),
                  contentPadding: EdgeInsets.zero,
                ),
                TextField(
                  controller: sendCtrl,
                  decoration: InputDecoration(
                    labelText: same ? l10n.quickSRCode : l10n.quickSendCode,
                    hintText: l10n.quickEnterCode,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                if (!same) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: recvCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.quickRecvCode,
                      hintText: l10n.quickEnterCode,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () {
                  final sendVal = sendCtrl.text.trim();
                  final recvVal = same ? sendVal : recvCtrl.text.trim();
                  AppPrefs.setString(_prefQuickSendCode, sendVal);
                  AppPrefs.setString(_prefQuickReceiveCode, recvVal);
                  AppPrefs.setBool(_prefUseSameCode, same);
                  setState(() {
                    _quickSendCode = sendVal;
                    _quickReceiveCode = recvVal;
                    _useSameCode = same;
                  });
                  Navigator.pop(ctx);
                },
                child: Text(l10n.confirm),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── File picking ──

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null && result.files.isNotEmpty) {
      setState(() => _selectedFiles.addAll(result.files));
    }
  }

  // ── Status ──

  void _startSimProgress() {
    _simProgress = 0;
    _progressTimer?.cancel();
    int step = 0;
    _progressTimer = Timer.periodic(const Duration(milliseconds: 60), (t) {
      if (!mounted) { t.cancel(); return; }
      step++;
      if (step <= 3) { _simProgress = (step * 0.25 / 3); }
      else if (_simProgress < 0.90) { _simProgress += 0.01; if (_simProgress > 0.90) _simProgress = 0.90; }
      final l10n = context.appLocalizations;
      final isSend = _phase == _QuickPhase.sending;
      QuickTransferWidget.statusNotifier.value = QuickStatus(
        label: isSend ? l10n.sending : l10n.receiving,
        color: Theme.of(context).colorScheme.primary,
        progress: _simProgress,
      );
    });
  }

  void _finishSimProgress(_QuickPhase donePhase) {
    _progressTimer?.cancel();
    int step = 0;
    _progressTimer = Timer.periodic(const Duration(milliseconds: 16), (t) {
      if (!mounted) { t.cancel(); return; }
      step++;
      if (step <= 10) { _simProgress = 0.90 + (step * 0.01); }
      else if (step <= 22) { _simProgress = 1.0; }
      else { t.cancel(); _setPhase(donePhase); return; }
      QuickTransferWidget.statusNotifier.value = QuickStatus(
        label: _phase == _QuickPhase.sending
            ? context.appLocalizations.sending
            : context.appLocalizations.receiving,
        color: Theme.of(context).colorScheme.primary,
        progress: _simProgress,
      );
    });
  }

  void _setPhase(_QuickPhase phase) {
    if (!mounted) return;
    final l10n = context.appLocalizations;
    final (String? label, Color? color) = switch (phase) {
      _QuickPhase.sending => (l10n.sending, Theme.of(context).colorScheme.primary),
      _QuickPhase.receiving => (l10n.receiving, Theme.of(context).colorScheme.primary),
      _QuickPhase.completed => (l10n.completed, const Color(0xFF4CAF50)),   // green
      _QuickPhase.failed => (l10n.failed, const Color(0xFFF44336)),         // red
      _QuickPhase.cancelled => (l10n.cancelled, const Color(0xFF9E9E9E)),   // grey
      _QuickPhase.idle => (null, null),
    };
    setState(() => _phase = phase);
    if (phase == _QuickPhase.idle) {
      _activeTransferId = null;
      _activeRecord = null;
      _activeSub = null;
      // Keep selected files/folder/text so user can retry after cancel/error.
    }
    if (label != null && color != null) {
      QuickTransferWidget.statusNotifier.value = QuickStatus(
        label: label,
        color: color,
        progress: (phase == _QuickPhase.sending || phase == _QuickPhase.receiving) ? _simProgress : -1,
      );
    } else {
      QuickTransferWidget.statusNotifier.value = null;
    }
  }

  // ── Send ──

  Future<void> _quickSend() async {
    final l10n = context.appLocalizations;
    if (!coreController.isAvailable) {
      if (mounted) context.showSnackBar(l10n.noCrocBackend);
      return;
    }
    // Validate content BEFORE capturing locals
    if (!_isTextMode && _selectedFiles.isEmpty && _selectedFolder == null) {
      if (mounted) context.showSnackBar(l10n.noFiles);
      return;
    }
    if (_isTextMode && _textCtrl.text.trim().isEmpty) {
      if (mounted) context.showSnackBar(l10n.enterTextWarning);
      return;
    }
    if (_quickSendCode.isEmpty && !_useSameCode) {
      if (mounted) context.showSnackBar(l10n.quickEmptySendCode);
      return;
    }

    _setPhase(_QuickPhase.sending);
    _startSimProgress();

    final transferId = appController.generateId();
    _activeTransferId = transferId;

    final resolvedPaths = <String>[];
    String? tempDirPath;
    if (!_isTextMode) {
      if (_selectedFolder != null) {
        resolvedPaths.add(_selectedFolder!);
      } else {
        for (final f in _selectedFiles) {
          if (f.path == null) continue;
          if (isAndroid && f.path!.startsWith('content://')) {
            try {
              final bytes = await File(f.path!).readAsBytes();
              tempDirPath ??= (await getTemporaryDirectory()).path;
              final tmp = File('$tempDirPath${Platform.pathSeparator}${f.name}');
              await tmp.writeAsBytes(bytes);
              resolvedPaths.add(tmp.path);
            } catch (_) {}
          } else {
            resolvedPaths.add(f.path!);
          }
        }
      }
    }
    if (_isTextMode) {
      tempDirPath = (await getTemporaryDirectory()).path;
    }

    final code = _quickSendCode.isNotEmpty ? _quickSendCode : null;
    final relayConfig = ref.read(appSettingProvider).relayConfig;

    final files = _isTextMode
        ? [FileItem(name: _textCtrl.text.trim(), path: '', size: _textCtrl.text.trim().length)]
        : _selectedFolder != null
            ? [FileItem(name: _selectedFolder!.split(Platform.pathSeparator).last, path: _selectedFolder!, size: 0)]
            : _selectedFiles.map((f) => FileItem(name: f.name, path: f.path ?? '', size: f.size)).toList();
    final totalSize = _isTextMode
        ? _textCtrl.text.trim().length
        : files.fold<int>(0, (a, f) => a + f.size);

    final record = TransferRecord(
      id: transferId,
      direction: TransferDirection.sent,
      status: TransferStatus.transferring,
      files: files, totalSize: totalSize,
      startTime: DateTime.now(),
      codePhrase: code ?? '',
    );
    appController.addTransferRecord(record);
    _activeRecord = record;

    final options = SendOptions(
      filePaths: _isTextMode ? [] : resolvedPaths,
      codePhrase: code,
      sendingText: _isTextMode,
      textContent: _isTextMode ? _textCtrl.text.trim() : '',
      tempDir: tempDirPath ?? '',
      onlyLocal: relayConfig.type == RelayType.noRelay,
      relayAddress: relayConfig.type == RelayType.customRelay ? relayConfig.address : null,
      relayPassword: relayConfig.type == RelayType.customRelay ? relayConfig.password : null,
      relayPorts: relayConfig.type == RelayType.customRelay ? relayConfig.port : null,
    );

    _activeSub = coreController.sendFiles(options).listen(
      (progress) {
        if (!mounted) return;
        // Ignore late events after user cancelled
        if (_phase == _QuickPhase.cancelled) return;
        if (progress.status == TransferProgressStatus.failed && progress.error != null) {
          context.showSnackBar(l10n.localizeCrocError(progress.error!, isSend: true));
        }
        if (progress.codePhrase != null && progress.codePhrase!.isNotEmpty) {
          appController.updateTransferRecord(record.copyWith(codePhrase: progress.codePhrase));
        }
        if (progress.status == TransferProgressStatus.completed) {
          _finishSimProgress(_QuickPhase.completed);
          appController.updateTransferRecord(record.copyWith(status: TransferStatus.completed, totalSize: progress.totalSize, endTime: DateTime.now()));
        } else if (progress.status == TransferProgressStatus.failed) {
          _progressTimer?.cancel();
          appController.updateTransferRecord(record.copyWith(status: TransferStatus.failed, endTime: DateTime.now()));
          _setPhase(_QuickPhase.failed);
          Future.delayed(const Duration(seconds: 1), () => _setPhase(_QuickPhase.idle));
        } else if (progress.status == TransferProgressStatus.cancelled) {
          _progressTimer?.cancel();
          appController.updateTransferRecord(record.copyWith(status: TransferStatus.cancelled, endTime: DateTime.now()));
          _setPhase(_QuickPhase.cancelled);
          Future.delayed(const Duration(seconds: 1), () => _setPhase(_QuickPhase.idle));
        }
      },
      onError: (_) {
        if (mounted && _phase != _QuickPhase.cancelled) {
          _progressTimer?.cancel();
          appController.updateTransferRecord(record.copyWith(status: TransferStatus.failed, endTime: DateTime.now()));
          _setPhase(_QuickPhase.failed);
          Future.delayed(const Duration(seconds: 1), () => _setPhase(_QuickPhase.idle));
        }
      },
    );
  }

  // ── Receive ──

  Future<void> _quickReceive() async {
    final l10n = context.appLocalizations;
    final code = _useSameCode ? _quickSendCode : _quickReceiveCode;
    if (code.isEmpty) {
      if (mounted) context.showSnackBar(l10n.quickEmptyRecvCode);
      return;
    }
    if (!coreController.isAvailable) {
      if (mounted) context.showSnackBar(l10n.noCrocBackend);
      return;
    }

    _setPhase(_QuickPhase.receiving);
    _startSimProgress();

    // Clear previous input/results before receiving
    setState(() {
      _selectedFiles.clear();
      _selectedFolder = null;
      _textCtrl.clear();
      _receivedFiles.clear();
      _receivedText = '';
    });

    final transferId = appController.generateId();
    _activeTransferId = transferId;

    final record = TransferRecord(
      id: transferId,
      direction: TransferDirection.received,
      status: TransferStatus.transferring,
      files: [FileItem(name: l10n.receiving, path: '', size: 0)],
      totalSize: 0,
      startTime: DateTime.now(),
      codePhrase: code,
    );
    appController.addTransferRecord(record);
    _activeRecord = record;

    final relayConfig = ref.read(appSettingProvider).relayConfig;
    final outputPath = AppPaths.savePathSync;
    final options = ReceiveOptions(
      codePhrase: code,
      onlyLocal: relayConfig.type == RelayType.noRelay,
      outputPath: outputPath,
      relayAddress: relayConfig.type == RelayType.customRelay ? relayConfig.address : null,
      relayPassword: relayConfig.type == RelayType.customRelay ? relayConfig.password : null,
      relayPorts: relayConfig.type == RelayType.customRelay ? relayConfig.port : null,
    );

    _activeSub = coreController.receiveFiles(options).listen(
      (progress) {
        if (!mounted) return;
        // Ignore late events after user cancelled
        if (_phase == _QuickPhase.cancelled) return;
        if (progress.status == TransferProgressStatus.failed && progress.error != null) {
          context.showSnackBar(l10n.localizeCrocError(progress.error!));
        }
        if (progress.status == TransferProgressStatus.completed) {
          _finishSimProgress(_QuickPhase.completed);
          if (progress.isText) {
            setState(() {
              _receivedText = progress.textContent;
              _receivedFiles.clear();
              _isTextMode = true;
            });
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              _textCtrl
                ..text = progress.textContent
                ..selection = TextSelection.collapsed(offset: progress.textContent.length);
            });
            appController.updateTransferRecord(record.copyWith(
              status: TransferStatus.completed,
              totalSize: progress.textContent.length,
              files: [FileItem(name: progress.textContent, path: '', size: progress.textContent.length)],
              endTime: DateTime.now(),
            ));
          } else {
            final fileNames = progress.currentFile.isNotEmpty
                ? progress.currentFile.split('\n').where((n) => n.isNotEmpty).toList()
                : <String>[];
            setState(() {
              _receivedText = '';
              _isTextMode = false;
              _receivedFiles.clear();
              _receivedFiles.addAll(fileNames.map((n) => FileItem(
                name: n,
                path: '${AppPaths.savePathSync}${Platform.pathSeparator}$n',
                size: 0,
              )));
            });
            appController.updateTransferRecord(record.copyWith(
              status: TransferStatus.completed,
              totalSize: progress.totalSize,
              files: fileNames.isEmpty
                  ? [const FileItem(name: 'file', path: '', size: 0)]
                  : _receivedFiles.map((f) => f).toList(),
              endTime: DateTime.now(),
            ));
            if (_receivedFiles.isNotEmpty && isAndroid) {
              for (final f in _receivedFiles) {
                AppPaths.exportToDownloads(f.path);
              }
            }
          }
        } else if (progress.status == TransferProgressStatus.failed) {
          _progressTimer?.cancel();
          appController.updateTransferRecord(record.copyWith(status: TransferStatus.failed, files: [FileItem(name: l10n.receiveFailed, path: '', size: 0)], endTime: DateTime.now()));
          _setPhase(_QuickPhase.failed);
          Future.delayed(const Duration(seconds: 1), () => _setPhase(_QuickPhase.idle));
        } else if (progress.status == TransferProgressStatus.cancelled) {
          _progressTimer?.cancel();
          appController.updateTransferRecord(record.copyWith(status: TransferStatus.cancelled, endTime: DateTime.now()));
          _setPhase(_QuickPhase.cancelled);
          Future.delayed(const Duration(seconds: 1), () => _setPhase(_QuickPhase.idle));
        }
      },
      onError: (_) {
        if (mounted && _phase != _QuickPhase.cancelled) {
          _progressTimer?.cancel();
          appController.updateTransferRecord(record.copyWith(status: TransferStatus.failed, files: [FileItem(name: l10n.receiveFailed, path: '', size: 0)], endTime: DateTime.now()));
          _setPhase(_QuickPhase.failed);
          Future.delayed(const Duration(seconds: 1), () => _setPhase(_QuickPhase.idle));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    return CommonCard(
      info: Info(iconData: Icons.swap_vert, label: l10n.quickTransfer),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Input area (always visible) ──
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<bool>(
                segments: [
                  ButtonSegment(value: false, label: Text(l10n.file, style: const TextStyle(fontSize: 12)), icon: const Icon(Icons.insert_drive_file, size: 16)),
                  ButtonSegment(value: true, label: Text(l10n.text, style: const TextStyle(fontSize: 12)), icon: const Icon(Icons.text_snippet, size: 16)),
                ],
                selected: {_isTextMode},
                onSelectionChanged: (v) => setState(() => _isTextMode = v.first),
                style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              ),
            ),
            const SizedBox(height: 8),
            if (_isTextMode)
              FileDropTarget(
                enabled: isDesktop,
                onFilesDropped: _onTextDrop,
                hintText: l10n.dropToAdd,
                child: TextField(
                controller: _textCtrl,
                maxLines: 2,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: l10n.textHint,
                  border: InputBorder.none,
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_receivedText.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          tooltip: l10n.clear,
                          onPressed: () => setState(() {
                            _receivedText = '';
                            _textCtrl.clear();
                            _phase = _QuickPhase.idle;
                            QuickTransferWidget.statusNotifier.value = null;
                          }),
                        ),
                      _ClipboardToggleButton(
                        isPasteMode: _isPasteMode,
                        isActive: _isActive,
                        onTap: _isPasteMode ? _pasteText : _copyText,
                        onLongPress: () => setState(() => _isPasteMode = !_isPasteMode),
                      ),
                    ],
                  ),
                ),
              ),
              )
            else ...[
              FileDropTarget(
                enabled: isDesktop,
                onFilesDropped: _onFileDrop,
                hintText: l10n.dropToAdd,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (_selectedFolder != null)
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.folder, size: 18, color: Colors.amber),
                  title: Text(_selectedFolder!.split(Platform.pathSeparator).last, style: const TextStyle(fontSize: 13)),
                  trailing: _isActive ? null : IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () => setState(() => _selectedFolder = null),
                    visualDensity: VisualDensity.compact,
                  ),
                  contentPadding: EdgeInsets.zero,
                )
              else if (_selectedFiles.isNotEmpty)
                ...List.generate(_selectedFiles.length, (i) {
                  final f = _selectedFiles[i];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.insert_drive_file, size: 18),
                    title: Text(f.name, style: const TextStyle(fontSize: 13)),
                    trailing: _isActive ? null : IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () => _removeFile(i),
                      visualDensity: VisualDensity.compact,
                    ),
                    contentPadding: EdgeInsets.zero,
                  );
                })
              else if (_receivedFiles.isNotEmpty)
                ..._receivedFiles.map((f) {
                  final showAsFolder = _isFolderName(f.name);
                  return ListTile(
                    dense: true,
                    leading: Icon(showAsFolder ? Icons.folder : Icons.insert_drive_file, size: 18, color: showAsFolder ? Colors.amber : null),
                    title: Text(f.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                    subtitle: f.size > 0 ? Text(f.size.fileSize, style: TextStyle(fontSize: 11, color: context.colorScheme.onSurfaceVariant)) : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.folder_open, size: 16),
                          tooltip: l10n.openFolder,
                          visualDensity: VisualDensity.compact,
                          onPressed: () => globalState.openFolder(f.path),
                        ),
                        IconButton(
                          icon: const Icon(Icons.open_in_new, size: 16),
                          tooltip: l10n.open,
                          visualDensity: VisualDensity.compact,
                          onPressed: () => showAsFolder ? globalState.openFolder(f.path) : globalState.openFile(f.path),
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          tooltip: l10n.clear,
                          visualDensity: VisualDensity.compact,
                          onPressed: () => setState(() {
                            _receivedFiles.clear();
                            _phase = _QuickPhase.idle;
                            QuickTransferWidget.statusNotifier.value = null;
                          }),
                        ),
                      ],
                    ),
                    contentPadding: EdgeInsets.zero,
                  );
                }),
                ]),  // Column
              ),  // FileDropTarget
              LayoutBuilder(builder: (_, constraints) {
                final w = constraints.maxWidth;
                // Measure label widths so thresholds adapt to locale.
                final textStyle = const TextStyle(fontSize: 12);
                final tp = TextPainter(textDirection: TextDirection.ltr);
                tp.text = TextSpan(text: _isFolderPicker ? l10n.selectFolder : l10n.selectFiles, style: textStyle); tp.layout();
                final wPick = tp.width;
                tp.text = TextSpan(text: l10n.clear, style: textStyle); tp.layout();
                final wClear = tp.width;
                double btnW(double tw) => tw + 56; // text + icon(16) + gap(8) + padding(32)
                const iconW = 44.0;
                const margin = 32.0;
                final iconPick = w + margin < btnW(wPick) + btnW(wClear);
                final iconClear  = w + margin < btnW(wClear) + iconW;
                return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  _PickerToggleButton(
                    isFolderPicker: _isFolderPicker,
                    isActive: _isActive,
                    narrow: iconPick,
                    onTap: _isFolderPicker ? _pickFolder : _pickFiles,
                    onLongPress: () => setState(() => _isFolderPicker = !_isFolderPicker),
                    filesLabel: l10n.selectFiles,
                    folderLabel: l10n.selectFolder,
                  ),
                  if (iconClear)
                    IconButton(
                      icon: const Icon(Icons.clear_all, size: 18),
                      tooltip: l10n.clear,
                      visualDensity: VisualDensity.compact,
                      onPressed: _isActive || (_selectedFiles.isEmpty && _selectedFolder == null) ? null : _clearFiles,
                    )
                  else
                    TextButton.icon(
                      onPressed: _isActive || (_selectedFiles.isEmpty && _selectedFolder == null) ? null : _clearFiles,
                      icon: const Icon(Icons.clear_all, size: 16),
                      label: Text(l10n.clear, style: const TextStyle(fontSize: 12)),
                    ),
                ]);
              }),
            ],
            if (_isTextMode) ...[
              const SizedBox(height: 4),
              LayoutBuilder(builder: (_, constraints) {
                final w = constraints.maxWidth;
                final textStyle = const TextStyle(fontSize: 12);
                final tp = TextPainter(textDirection: TextDirection.ltr);
                tp.text = TextSpan(text: l10n.selectTextFile, style: textStyle); tp.layout();
                final wPick = tp.width;
                tp.text = TextSpan(text: l10n.clear, style: textStyle); tp.layout();
                final wClear = tp.width;
                double btnW(double tw) => tw + 56;
                const iconW = 44.0;
                const margin = 32.0;
                final iconPick = w + margin < btnW(wPick) + btnW(wClear);
                final iconClear  = w + margin < btnW(wClear) + iconW;
                return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  if (iconPick)
                    IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      tooltip: l10n.selectTextFile,
                      visualDensity: VisualDensity.compact,
                      onPressed: _isActive ? null : _pickTextFile,
                    )
                  else
                    TextButton.icon(
                      onPressed: _isActive ? null : _pickTextFile,
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(l10n.selectTextFile, style: const TextStyle(fontSize: 12)),
                    ),
                  if (iconClear)
                    IconButton(
                      icon: const Icon(Icons.clear_all, size: 18),
                      tooltip: l10n.clear,
                      visualDensity: VisualDensity.compact,
                      onPressed: _clearText,
                    )
                  else
                    TextButton.icon(
                      onPressed: _clearText,
                      icon: const Icon(Icons.clear_all, size: 16),
                      label: Text(l10n.clear, style: const TextStyle(fontSize: 12)),
                    ),
                ]);
              }),
            ],
            const SizedBox(height: 8),
            // Action row — responsive: labels when wide, icons only when narrow
            LayoutBuilder(builder: (_, constraints) {
              final w = constraints.maxWidth;
              final textStyle = const TextStyle(fontSize: 12);
              final tp = TextPainter(textDirection: TextDirection.ltr);
              final sendLabel = _phase == _QuickPhase.sending ? l10n.cancel : l10n.send;
              final recvLabel = _phase == _QuickPhase.receiving ? l10n.cancel : l10n.receive;
              tp.text = TextSpan(text: sendLabel, style: textStyle); tp.layout();
              final wSend = tp.width;
              tp.text = TextSpan(text: recvLabel, style: textStyle); tp.layout();
              final wRecv = tp.width;
              double btnW(double tw) => tw + 56;
              const iconW = 44.0;
              const gap = 8.0;
              const margin = 32.0;
              // Receive collapses first, then send
              final iconRecv = w + margin < btnW(wSend) + btnW(wRecv) + iconW + gap;
              final iconSend = w + margin < btnW(wSend) + iconW + iconW + gap;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_phase == _QuickPhase.sending)
                    _actionBtn(onPressed: _cancelTransfer, icon: Icons.close, label: l10n.cancel, isCancel: true, narrow: iconSend)
                  else
                    _actionBtn(onPressed: (!_isActive && _phase != _QuickPhase.cancelled) ? _quickSend : null, icon: Icons.send, label: l10n.send, narrow: iconSend),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.settings, size: 20),
                    tooltip: l10n.settings,
                    visualDensity: VisualDensity.compact,
                    onPressed: _isActive ? null : _showSettings,
                  ),
                  const SizedBox(width: 4),
                  if (_phase == _QuickPhase.receiving)
                    _actionBtn(onPressed: _cancelTransfer, icon: Icons.close, label: l10n.cancel, isCancel: true, narrow: iconRecv)
                  else
                    _actionBtn(onPressed: (!_isActive && _phase != _QuickPhase.cancelled) ? _quickReceive : null, icon: Icons.download, label: l10n.receive, narrow: iconRecv),
                ],
              );
            }),
          ], // Column children
        ),
      ),
    );
  }

  Widget _actionBtn({required VoidCallback? onPressed, required IconData icon, required String label, bool isCancel = false, required bool narrow}) {
    if (narrow) {
      return IconButton(
        icon: Icon(icon, size: 18),
        tooltip: label,
        visualDensity: VisualDensity.compact,
        style: IconButton.styleFrom(
          backgroundColor: isCancel ? Colors.red : Theme.of(context).colorScheme.primary,
          foregroundColor: isCancel ? Colors.white : Theme.of(context).colorScheme.onPrimary,
        ),
        onPressed: onPressed,
      );
    }
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: FilledButton.styleFrom(
        backgroundColor: isCancel ? Colors.red : null,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }

  /// Detect if a file name represents a folder (no extension, or contains path separators).
  bool _isFolderName(String name) {
    if (name.contains('/') || name.contains('\\')) return true;
    return !name.contains('.');
  }
}

/// Animated clipboard button with press animation and long-press paste/copy toggle.
class _ClipboardToggleButton extends StatefulWidget {
  const _ClipboardToggleButton({
    required this.isPasteMode,
    required this.isActive,
    required this.onTap,
    required this.onLongPress,
  });

  final bool isPasteMode;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  State<_ClipboardToggleButton> createState() => _ClipboardToggleButtonState();
}

class _ClipboardToggleButtonState extends State<_ClipboardToggleButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: widget.isActive ? null : widget.onLongPress,
      onTapDown: widget.isActive ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.isActive ? null : (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.isActive ? null : () {
        widget.onTap();
        setState(() => _pressed = false);
      },
      child: AnimatedScale(
        scale: _pressed ? 0.75 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
          child: Icon(
            key: ValueKey(widget.isPasteMode),
            widget.isPasteMode ? Icons.content_paste : Icons.content_copy,
            size: 18,
            color: widget.isActive ? Theme.of(context).disabledColor : null,
          ),
        ),
      ),
    );
  }
}

/// Animated file/folder picker button — long-press toggles mode.
class _PickerToggleButton extends StatefulWidget {
  const _PickerToggleButton({
    required this.isFolderPicker,
    required this.isActive,
    required this.narrow,
    required this.onTap,
    required this.onLongPress,
    required this.filesLabel,
    required this.folderLabel,
  });

  final bool isFolderPicker;
  final bool isActive;
  final bool narrow;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final String filesLabel;
  final String folderLabel;

  @override
  State<_PickerToggleButton> createState() => _PickerToggleButtonState();
}

class _PickerToggleButtonState extends State<_PickerToggleButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final icon = widget.isFolderPicker ? Icons.create_new_folder : Icons.add;
    final label = widget.isFolderPicker ? widget.folderLabel : widget.filesLabel;
    final onPress = widget.isActive ? null : widget.onTap;
    // Long-press toggles mode — always allowed, even during transfer.
    final onLong = widget.onLongPress;

    if (widget.narrow) {
      return GestureDetector(
        onLongPress: onLong,
        onTapDown: onPress == null ? null : (_) => setState(() => _pressed = true),
        onTapUp: onPress == null ? null : (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: onPress == null ? null : () { onPress(); setState(() => _pressed = false); },
        child: AnimatedScale(
          scale: _pressed ? 0.75 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeInOut,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
            child: IconButton(
              key: ValueKey(widget.isFolderPicker),
              icon: Icon(icon, size: 18),
              tooltip: label,
              visualDensity: VisualDensity.compact,
              onPressed: onPress,
            ),
          ),
        ),
      );
    }
    return GestureDetector(
      onLongPress: onLong,
      onLongPressDown: (_) => setState(() => _pressed = true),
      onLongPressUp: () => setState(() => _pressed = false),
      onLongPressCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.75 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
          child: TextButton.icon(
            key: ValueKey(widget.isFolderPicker),
            onPressed: onPress,
            icon: Icon(icon, size: 16),
            label: Text(label, style: const TextStyle(fontSize: 12)),
          ),
        ),
      ),
    );
  }
}
