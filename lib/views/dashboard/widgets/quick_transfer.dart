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

/// Unified quick send + receive card for the dashboard.
///
/// Layout: [File/Text toggle] [file/text area] [Send] [Settings] [Receive]
///
/// The static [statusNotifier] emits the current transfer phase so the parent
/// dashboard can show a status chip in its AppBar.
class QuickTransferWidget extends ConsumerStatefulWidget {
  const QuickTransferWidget({super.key});

  /// Emits `(label, color)` when a transfer is active; null when idle.
  static final statusNotifier = ValueNotifier<(String, Color)?>(null);

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
  String? _selectedFolder;

  // Quick codes
  String _quickSendCode = 'shimo-kita-1145';
  String _quickReceiveCode = 'shimo-kita-1145';
  bool _useSameCode = true;

  // Receive results (shown in input area)
  final List<FileItem> _receivedFiles = [];
  String _receivedText = '';

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
    _textCtrl.dispose();
    QuickTransferWidget.statusNotifier.value = null;
    super.dispose();
  }

  // ── Helpers ──

  bool get _isActive => _phase != _QuickPhase.idle && _phase != _QuickPhase.completed && _phase != _QuickPhase.failed && _phase != _QuickPhase.cancelled;

  void _cancelTransfer() {
    if (_activeTransferId != null) {
      coreController.cancelTransfer(_activeTransferId!);
    }
    _setPhase(_QuickPhase.cancelled);
    Future.delayed(const Duration(seconds: 2), () => _setPhase(_QuickPhase.idle));
  }

  void _clearFiles() => setState(() { _selectedFiles.clear(); _selectedFolder = null; });
  void _clearText() => _textCtrl.clear();
  void _removeFile(int index) => setState(() => _selectedFiles.removeAt(index));

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

  void _setPhase(_QuickPhase phase) {
    if (!mounted) return;
    final l10n = context.appLocalizations;
    final (String? label, Color? color) = switch (phase) {
      _QuickPhase.sending => (l10n.sending, const Color(0xFF2196F3)),       // blue
      _QuickPhase.receiving => (l10n.receiving, const Color(0xFF2196F3)),   // blue
      _QuickPhase.completed => (l10n.completed, const Color(0xFF4CAF50)),   // green
      _QuickPhase.failed => (l10n.failed, const Color(0xFFF44336)),         // red
      _QuickPhase.cancelled => (l10n.cancelled, const Color(0xFF9E9E9E)),   // grey
      _QuickPhase.idle => (null, null),
    };
    setState(() => _phase = phase);
    if (phase == _QuickPhase.idle) {
      _activeTransferId = null;
      _selectedFiles.clear();
      _textCtrl.clear();
      _selectedFolder = null;
      // Keep _lastAction and results — cleared by user via [clear] button
    }
    if (label != null && color != null) {
      QuickTransferWidget.statusNotifier.value = (label, color);
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

    final transferId = appController.generateId();
    _activeTransferId = transferId;

    final resolvedPaths = <String>[];
    if (!_isTextMode) {
      if (_selectedFolder != null) {
        resolvedPaths.add(_selectedFolder!);
      } else {
        for (final f in _selectedFiles) {
          if (f.path == null) continue;
          if (isAndroid && f.path!.startsWith('content://')) {
            try {
              final bytes = await File(f.path!).readAsBytes();
              final tempDir = await getTemporaryDirectory();
              final tmp = File('${tempDir.path}${Platform.pathSeparator}${f.name}');
              await tmp.writeAsBytes(bytes);
              resolvedPaths.add(tmp.path);
            } catch (_) {}
          } else {
            resolvedPaths.add(f.path!);
          }
        }
      }
    }

    final code = _quickSendCode.isNotEmpty ? _quickSendCode : null;
    final relayConfig = ref.read(appSettingProvider).relayConfig;

    final files = _isTextMode
        ? [FileItem(name: l10n.sentText, path: '', size: _textCtrl.text.trim().length)]
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

    final options = SendOptions(
      filePaths: _isTextMode ? [] : resolvedPaths,
      codePhrase: code,
      sendingText: _isTextMode,
      textContent: _isTextMode ? _textCtrl.text.trim() : '',
      onlyLocal: relayConfig.type == RelayType.noRelay,
      relayAddress: relayConfig.type == RelayType.customRelay ? relayConfig.address : null,
      relayPassword: relayConfig.type == RelayType.customRelay ? relayConfig.password : null,
      relayPorts: relayConfig.type == RelayType.customRelay ? relayConfig.port : null,
    );

    coreController.sendFiles(options).listen(
      (progress) {
        if (!mounted) return;
        if (progress.status == TransferProgressStatus.failed && progress.error != null) {
          context.showSnackBar(l10n.localizeCrocError(progress.error!, isSend: true));
        }
        if (progress.codePhrase != null && progress.codePhrase!.isNotEmpty) {
          appController.updateTransferRecord(record.copyWith(codePhrase: progress.codePhrase));
        }
        if (progress.status == TransferProgressStatus.completed) {
          appController.updateTransferRecord(record.copyWith(status: TransferStatus.completed, totalSize: progress.totalSize, endTime: DateTime.now()));
          _setPhase(_QuickPhase.completed);
        } else if (progress.status == TransferProgressStatus.failed) {
          appController.updateTransferRecord(record.copyWith(status: TransferStatus.failed, endTime: DateTime.now()));
          _setPhase(_QuickPhase.failed);
          Future.delayed(const Duration(seconds: 2), () => _setPhase(_QuickPhase.idle));
        } else if (progress.status == TransferProgressStatus.cancelled) {
          appController.updateTransferRecord(record.copyWith(status: TransferStatus.cancelled, endTime: DateTime.now()));
          _setPhase(_QuickPhase.cancelled);
          Future.delayed(const Duration(seconds: 2), () => _setPhase(_QuickPhase.idle));
        }
      },
      onError: (_) {
        if (mounted) {
          appController.updateTransferRecord(record.copyWith(status: TransferStatus.failed, endTime: DateTime.now()));
          _setPhase(_QuickPhase.failed);
          Future.delayed(const Duration(seconds: 2), () => _setPhase(_QuickPhase.idle));
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

    coreController.receiveFiles(options).listen(
      (progress) {
        if (!mounted) return;
        if (progress.status == TransferProgressStatus.failed && progress.error != null) {
          context.showSnackBar(l10n.localizeCrocError(progress.error!));
        }
        if (progress.status == TransferProgressStatus.completed) {
          if (progress.isText) {
            setState(() {
              _receivedText = progress.textContent;
              _receivedFiles.clear();
              _isTextMode = true;
            });
            // Defer text controller update to after the frame so TextField exists
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
            setState(() {
              final fileNames = progress.currentFile.isNotEmpty
                  ? progress.currentFile.split('\n').where((n) => n.isNotEmpty).toList()
                  : <String>[];
              _receivedText = '';
              _textCtrl.clear();
              _isTextMode = false;
              _receivedFiles.clear();
              final fileItems = fileNames.map((n) => FileItem(
                name: n,
                path: '${AppPaths.savePathSync}${Platform.pathSeparator}$n',
                size: 0,
              )).toList();
              _receivedFiles.addAll(fileItems);
              appController.updateTransferRecord(record.copyWith(
                status: TransferStatus.completed,
                totalSize: progress.totalSize,
                files: fileItems.isEmpty ? [const FileItem(name: 'file', path: '', size: 0)] : fileItems,
                endTime: DateTime.now(),
              ));
              if (_receivedFiles.isNotEmpty && isAndroid) {
                for (final f in _receivedFiles) {
                  AppPaths.exportToDownloads(f.path);
                }
              }
            });
          }
          _setPhase(_QuickPhase.completed);
        } else if (progress.status == TransferProgressStatus.failed) {
          appController.updateTransferRecord(record.copyWith(status: TransferStatus.failed, endTime: DateTime.now()));
          _setPhase(_QuickPhase.failed);
          Future.delayed(const Duration(seconds: 2), () => _setPhase(_QuickPhase.idle));
        } else if (progress.status == TransferProgressStatus.cancelled) {
          appController.updateTransferRecord(record.copyWith(status: TransferStatus.cancelled, endTime: DateTime.now()));
          _setPhase(_QuickPhase.cancelled);
          Future.delayed(const Duration(seconds: 2), () => _setPhase(_QuickPhase.idle));
        }
      },
      onError: (_) {
        if (mounted) {
          appController.updateTransferRecord(record.copyWith(status: TransferStatus.failed, endTime: DateTime.now()));
          _setPhase(_QuickPhase.failed);
          Future.delayed(const Duration(seconds: 2), () => _setPhase(_QuickPhase.idle));
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
              TextField(
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
                      IconButton(
                        icon: const Icon(Icons.content_paste, size: 18),
                        tooltip: l10n.paste,
                        onPressed: _isActive ? null : _pasteText,
                      ),
                    ],
                  ),
                ),
              )
            else ...[
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
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  TextButton.icon(
                    onPressed: _isActive ? null : _pickFiles,
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(l10n.selectFiles, style: const TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 4),
                  TextButton.icon(
                    onPressed: _isActive ? null : _pickFolder,
                    icon: const Icon(Icons.create_new_folder, size: 16),
                    label: Text(l10n.selectFolder, style: const TextStyle(fontSize: 12)),
                  ),
                ]),
                TextButton.icon(
                  onPressed: _isActive || (_selectedFiles.isEmpty && _selectedFolder == null) ? null : _clearFiles,
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: Text(l10n.clear, style: const TextStyle(fontSize: 12)),
                ),
              ]),
            ],
            if (_isTextMode) ...[
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _isActive || _textCtrl.text.isEmpty ? null : _clearText,
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: Text(l10n.clear, style: const TextStyle(fontSize: 12)),
                ),
              ),
            ],
            const SizedBox(height: 8),
            // Action row — always Send/Settings/Receive; swap to Cancel during transfer
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 4,
              runSpacing: 4,
              children: [
                if (_phase == _QuickPhase.sending)
                  _actionButton(onPressed: _cancelTransfer, icon: Icons.close, label: l10n.cancel, isCancel: true)
                else
                  _actionButton(
                    onPressed: !_isActive ? _quickSend : null,
                    icon: Icons.send,
                    label: l10n.send,
                  ),
                IconButton(
                  icon: const Icon(Icons.settings, size: 20),
                  tooltip: l10n.settings,
                  visualDensity: VisualDensity.compact,
                  onPressed: _isActive ? null : _showSettings,
                ),
                if (_phase == _QuickPhase.receiving)
                  _actionButton(onPressed: _cancelTransfer, icon: Icons.close, label: l10n.cancel, isCancel: true)
                else
                  _actionButton(
                    onPressed: !_isActive ? _quickReceive : null,
                    icon: Icons.download,
                    label: l10n.receive,
                  ),
              ],
            ),
          ], // Column children
        ),
      ),
    );
  }

  Widget _actionButton({required VoidCallback? onPressed, required IconData icon, required String label, bool isCancel = false}) {
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
