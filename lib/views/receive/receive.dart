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
import 'package:mobile_scanner/mobile_scanner.dart';

class ReceiveView extends ConsumerStatefulWidget {
  const ReceiveView({super.key});

  @override
  ConsumerState<ReceiveView> createState() => _ReceiveViewState();
}

class _ReceiveViewState extends ConsumerState<ReceiveView> {
  final _codeController = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _isReceiving = false;
  ReceiveConfig _receiveConfig = const ReceiveConfig();

  ReceivePhase _phase = ReceivePhase.idle;

  double _simProgress = 0;
  Timer? _progressTimer;
  StreamSubscription<TransferProgress>? _receiveSub;

  void _startSimProgress() {
    _simProgress = 0;
    _progressTimer?.cancel();
    int step = 0;
    _progressTimer = Timer.periodic(const Duration(milliseconds: 60), (t) {
      if (!mounted) { t.cancel(); return; }
      step++;
      if (step <= 3) { _simProgress = (step * 0.25 / 3); }
      else if (_simProgress < 0.90) { _simProgress += 0.01; if (_simProgress > 0.90) _simProgress = 0.90; }
      setState(() {});
    });
  }

  void _finishSimProgress() {
    _progressTimer?.cancel();
    int step = 0;
    _progressTimer = Timer.periodic(const Duration(milliseconds: 16), (t) {
      if (!mounted) { t.cancel(); return; }
      step++;
      if (step <= 10) { _simProgress = 0.90 + (step * 0.01); }
      else if (step <= 22) { _simProgress = 1.0; }
      else { t.cancel(); if (mounted) setState(() => _phase = ReceivePhase.completed); }
      setState(() {});
    });
  }

  // Received content tracking
  final List<FileItem> _receivedFiles = [];
  int _selectedTab = 0; // 0=files, 1=text
  bool _isPasteMode = false; // receive: default copy
  final _receivedTextController = TextEditingController();
  String _effectiveOutputPath = '';

  @override
  void initState() {
    super.initState();
    _loadReceivePrefs();
  }

  // ── Persistence ──

  static const _prefReceiveConfig = 'receive_config';

  void _loadReceivePrefs() {
    final json = AppPrefs.getJson(_prefReceiveConfig);
    if (json.isNotEmpty) {
      _receiveConfig = ReceiveConfig.fromJson(json);
    }
  }

  void _saveReceivePrefs() {
    AppPrefs.setJson(_prefReceiveConfig, _receiveConfig.toJson());
  }

  /// Build FileItem list from received file names, detecting folders.
  List<FileItem> _buildFileItems(List<String> fileNames, int totalSize) {
    if (fileNames.isEmpty) {
      return [FileItem(name: 'file', path: _effectiveOutputPath, size: 0)];
    }
    if (fileNames.length > 1) {
      final separator = fileNames[0].contains('/') ? '/' : (fileNames[0].contains('\\') ? '\\' : null);
      String? commonRoot;
      if (separator != null) {
        final root = fileNames[0].split(separator)[0];
        if (fileNames.every((n) => n.startsWith('$root$separator'))) {
          commonRoot = root;
        }
      }
      if (commonRoot != null) {
        return [FileItem(name: commonRoot, path: '$_effectiveOutputPath${Platform.pathSeparator}$commonRoot', size: totalSize)];
      }
      return fileNames.map((n) => FileItem(
        name: n,
        path: '$_effectiveOutputPath${Platform.pathSeparator}${n.replaceAll('/', Platform.pathSeparator)}',
        size: totalSize,
      )).toList();
    }
    final name = fileNames[0];
    return [FileItem(
      name: name,
      path: '$_effectiveOutputPath${Platform.pathSeparator}$name',
      size: totalSize,
    )];
  }

  void _openScanner() async {
    if (isDesktop) {
      if (mounted) context.showSnackBar(context.appLocalizations.scanMobileOnly);
      return;
    }
    try {
      final result = await Navigator.of(context).push<String>(
        _QrScannerRoute(builder: (_) => const _QRScannerDialog()),
      );
      if (result != null && mounted) {
        _codeController.text = result;
      }
    } catch (e, st) {
      commonPrint('Scanner dialog error: $e\n$st');
      if (mounted) context.showSnackBar(context.appLocalizations.localizeCrocError(e.toString()));
    }
  }

  void _pastePhrase() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      _codeController.text = data.text!;
    }
  }

  String _defaultDownloadDir() => AppPaths.savePathSync;

  Future<void> _pickReceivePath() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null && mounted) {
      setState(() {
        _receiveConfig = _receiveConfig.copyWith(outputPath: result);
        _saveReceivePrefs();
      });
    }
  }
  void _startReceive() {
    final code = _codeController.text.trim();
    final l10n = context.appLocalizations;
    if (code.isEmpty) {
      context.showSnackBar(l10n.phraseEmpty);
      return;
    }

    if (!coreController.isAvailable) {
      context.showSnackBar(l10n.noCrocBackend);
      return;
    }

    setState(() {
      _isReceiving = true;
      _phase = ReceivePhase.pending;
      _receivedFiles.clear();
      _receivedTextController.clear();
      _selectedTab = 0;
    });

    final record = TransferRecord(
      id: appController.generateId(),
      direction: TransferDirection.received,
      status: TransferStatus.transferring,
      files: [FileItem(name: l10n.receiving, path: '', size: 0)],
      totalSize: 0,
      startTime: DateTime.now(),
      codePhrase: code,
    );

    appController.addTransferRecord(record);

    final relayConfig = ref.read(appSettingProvider).relayConfig;
    final useNoRelay = relayConfig.type == RelayType.noRelay;
    final useCustom = relayConfig.type == RelayType.customRelay;

    // Resolve effective output path
    final effectivePath = _receiveConfig.outputPath.isNotEmpty
        ? _receiveConfig.outputPath
        : (ref.read(appSettingProvider).defaultSavePath.isNotEmpty
            ? ref.read(appSettingProvider).defaultSavePath
            : _defaultDownloadDir());
    _effectiveOutputPath = effectivePath;

    final options = ReceiveOptions(
      codePhrase: code,
      overwrite: _receiveConfig.overwrite,
      onlyLocal: useNoRelay,
      outputPath: effectivePath,
      relayAddress: useCustom ? relayConfig.address : null,
      relayPassword: useCustom ? relayConfig.password : null,
      relayPorts: useCustom ? relayConfig.port : null,
    );

    _receiveSub = coreController.receiveFiles(options).listen(
      (progress) {
        if (!mounted) return;
        switch (progress.status) {
          case TransferProgressStatus.initializing:
          case TransferProgressStatus.connecting:
            if (mounted) {
              setState(() { _phase = ReceivePhase.receiving; });
              _startSimProgress();
            }
            break;
          case TransferProgressStatus.transferring:
            if (_phase == ReceivePhase.pending) {
              setState(() { _phase = ReceivePhase.receiving; });
              _startSimProgress();
            }
            appController.updateTransferRecord(
              record.copyWith(
                status: TransferStatus.transferring,
                transferredSize: progress.transferredSize,
              ),
            );
            if (mounted) setState(() {});
            break;
          case TransferProgressStatus.completed:
            _finishSimProgress();
            if (progress.isText) {
              setState(() {
                _receivedFiles.clear();
                _selectedTab = 1;
                _isReceiving = false;
              });
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                _receivedTextController
                  ..text = progress.textContent
                  ..selection = TextSelection.collapsed(offset: progress.textContent.length);
              });
              appController.updateTransferRecord(
                record.copyWith(
                  status: TransferStatus.completed,
                  totalSize: progress.textContent.length,
                  files: [FileItem(name: progress.textContent, path: '', size: progress.textContent.length)],
                  endTime: DateTime.now(),
                ),
              );
            } else {
              // File receive
              final fileNames = progress.currentFile.isNotEmpty
                  ? progress.currentFile.split('\n').where((n) => n.isNotEmpty).toList()
                  : <String>[];
              final cleanedNames = fileNames.map((n) {
                if (fileNames.length == 1 && n.endsWith('.zip')) return n.substring(0, n.length - 4);
                return n;
              }).toList();
              final fileItems = _buildFileItems(cleanedNames, progress.totalSize);
              setState(() {
                _receivedFiles.clear();
                _receivedFiles.addAll(fileItems);
                _receivedTextController.clear();
                _selectedTab = fileItems.isNotEmpty ? 0 : _selectedTab;
                _isReceiving = false;
              });
              if (fileItems.isNotEmpty && isAndroid) {
                for (final f in fileItems) {
                  AppPaths.exportToDownloads(f.path);
                }
              }
              appController.updateTransferRecord(
                record.copyWith(
                  status: TransferStatus.completed,
                  transferredSize: progress.totalSize,
                  totalSize: progress.totalSize,
                  files: fileItems.isEmpty ? [const FileItem(name: 'file', path: '', size: 0)] : fileItems,
                  endTime: DateTime.now(),
                ),
              );
            }
          case TransferProgressStatus.failed:
            _progressTimer?.cancel();
            setState(() { _isReceiving = false; _phase = ReceivePhase.failed; });
            appController.updateTransferRecord(
              record.copyWith(
                status: TransferStatus.failed,
                files: [FileItem(name: l10n.receiveFailed, path: '', size: 0)],
                endTime: DateTime.now(),
              ),
            );
            if (progress.error != null && mounted) {
              commonPrint('Receive failed: ${progress.error}');
              final errMsg = progress.error == CoreController.noBackendError
                  ? l10n.noCrocBackend
                  : l10n.localizeCrocError(progress.error!);
              context.showSnackBar(errMsg);
            }
          case TransferProgressStatus.cancelled:
            setState(() => _isReceiving = false);
            appController.updateTransferRecord(
              record.copyWith(
                status: TransferStatus.cancelled,
                endTime: DateTime.now(),
              ),
            );
          }
      },
      onError: (e) {
        if (!mounted) return;
        final l10n = context.appLocalizations;
        setState(() => _isReceiving = false);
        appController.updateTransferRecord(
          record.copyWith(
            status: TransferStatus.failed,
            files: [FileItem(name: l10n.receiveFailed, path: '', size: 0)],
            endTime: DateTime.now(),
          ),
        );
        final errMsg = e.toString() == 'UnsupportedError: unavailable'
            ? l10n.noCrocBackend
            : l10n.localizeCrocError(e.toString());
        context.showSnackBar(errMsg);
        commonPrint('Receive error: $e');
      },
      onDone: () {
        if (mounted) setState(() => _isReceiving = false);
      },
    );
  }

  void _cancelReceive() {
    _progressTimer?.cancel();
    _receiveSub?.cancel();
    _receiveSub = null;
    setState(() { _isReceiving = false; _phase = ReceivePhase.cancelled; });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _phase = ReceivePhase.idle);
    });
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _receiveSub?.cancel();
    _saveReceivePrefs();
    _codeController.dispose();
    _receivedTextController.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    return CommonScaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: SizedBox(
          height: 36,
          child: TextField(
            controller: _codeController,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, letterSpacing: 1),
            decoration: InputDecoration(
              hintText: l10n.enterCodePhrase,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              isDense: true,
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 28, height: 28,
                    child: IconButton(
                      icon: const Icon(Icons.qr_code_scanner, size: 16),
                      onPressed: _openScanner,
                      padding: EdgeInsets.zero,
                      tooltip: l10n.scanQRCode,
                    ),
                  ),
                  SizedBox(
                    width: 28, height: 28,
                    child: IconButton(
                      icon: const Icon(Icons.paste, size: 16),
                      onPressed: _pastePhrase,
                      padding: EdgeInsets.zero,
                      tooltip: l10n.paste,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          if (_phase != ReceivePhase.idle) _buildStatusChip(l10n),
          const SizedBox(width: 8),
          FilledButtonWidget(
            onPressed: _isReceiving ? _cancelReceive : _phase == ReceivePhase.cancelled ? null : _startReceive,
            text: _isReceiving ? l10n.cancel : l10n.receive,
            icon: _isReceiving ? Icons.close : Icons.download,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ListView(
          controller: _scrollCtrl,
          children: [
            // ── File / Text toggle (always visible, matches send page) ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: SegmentedButton<int>(
                segments: [
                  ButtonSegment(value: 0, label: Text(l10n.file), icon: const Icon(Icons.insert_drive_file, size: 18)),
                  ButtonSegment(value: 1, label: Text(l10n.text), icon: const Icon(Icons.text_snippet, size: 18)),
                ],
                selected: {_selectedTab},
                onSelectionChanged: (v) => setState(() => _selectedTab = v.first),
              ),
            ),

            // ── Received content (matches send page layout / behavior) ──
            if (_selectedTab == 0)
              _buildSection(l10n.file, Icons.insert_drive_file, [
                if (_receivedFiles.isEmpty)
                  NullStatusWidget(message: l10n.noReceivedFiles, icon: Icons.inbox_outlined)
                else
                  ..._receivedFiles.map((f) {
                    final showAsFolder = f.name.contains('/') || (_receivedFiles.length == 1 && !f.name.contains('.'));
                    return ListTile(
                      leading: Icon(showAsFolder ? Icons.folder : Icons.insert_drive_file, color: showAsFolder ? Colors.amber : null),
                      title: Text(f.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: f.size > 0 ? Text(f.size.fileSize, style: context.textTheme.bodySmall) : null,
                      dense: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.folder_open, size: 18),
                            onPressed: () => globalState.openFolder(f.path),
                            tooltip: l10n.openFolder,
                            visualDensity: VisualDensity.compact,
                          ),
                          IconButton(
                            icon: const Icon(Icons.open_in_new, size: 18),
                            onPressed: () => showAsFolder ? globalState.openFolder(f.path) : globalState.openFile(f.path),
                            tooltip: l10n.open,
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    );
                  }),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _receivedFiles.isNotEmpty
                          ? () => setState(() => _receivedFiles.clear())
                          : null,
                      icon: const Icon(Icons.clear_all, size: 16),
                      label: Text(l10n.clear),
                    ),
                  ),
                ),
              ])
            else
              _buildSection(l10n.text, Icons.text_snippet, [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: TextField(
                    controller: _receivedTextController,
                    readOnly: true,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: l10n.textHint,
                      border: InputBorder.none,
                      suffixIcon: _ClipboardToggleButton(
                        isPasteMode: _isPasteMode,
                        isActive: false,
                        onTap: _isPasteMode
                            ? () async {
                                final data = await Clipboard.getData(Clipboard.kTextPlain);
                                if (data?.text != null && data!.text!.isNotEmpty) {
                                  setState(() => _receivedTextController.text = data.text!);
                                }
                              }
                            : () {
                              if (_receivedTextController.text.isNotEmpty) {
                                Clipboard.setData(ClipboardData(text: _receivedTextController.text));
                              }
                            },
                        onLongPress: () => setState(() => _isPasteMode = !_isPasteMode),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const SizedBox(width: 1),
                    TextButton.icon(
                      onPressed: _receivedTextController.text.isNotEmpty
                          ? () => setState(() => _receivedTextController.clear())
                          : null,
                      icon: const Icon(Icons.clear_all, size: 16),
                      label: Text(l10n.clear),
                    ),
                  ]),
                ),
              ]),

            // ── Options ──
            ExpansionTile(
              shape: const Border(),
              title: Text(l10n.transferOptions),
              leading: const Icon(Icons.tune),
              initiallyExpanded: _phase == ReceivePhase.idle,
              onExpansionChanged: (_) => setState(() {}),
              children: [
                ListItem.switchItem(
                  leading: const Icon(Icons.file_copy),
                  title: Text(l10n.overwrite),
                  delegate: SwitchDelegate(
                    value: _receiveConfig.overwrite,
                    onChanged: (v) {
                      setState(() {
                        _receiveConfig = _receiveConfig.copyWith(overwrite: v);
                        _saveReceivePrefs();
                      });
                    },
                  ),
                ),
                Consumer(
                  builder: (_, ref, c) {
                    final isCustom = _receiveConfig.outputPath.isNotEmpty;
                    final globalPath = ref.watch(appSettingProvider.select((s) => s.defaultSavePath));
                    final effectivePath = isCustom ? _receiveConfig.outputPath : (globalPath.isNotEmpty ? globalPath : _defaultDownloadDir());
                    return ListItem(
                      leading: const Icon(Icons.folder),
                      title: Text(l10n.savePath),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ChoiceChip(
                                label: Text(l10n.defaultLabel, style: const TextStyle(fontSize: 12)),
                                selected: !isCustom,
                                onSelected: (v) {
                                  if (v) {
                                    setState(() {
                                    _receiveConfig = _receiveConfig.copyWith(outputPath: '');
                                    _saveReceivePrefs();
                                  });
                                  }
                                },
                              ),
                              const SizedBox(width: 8),
                              ChoiceChip(
                                label: Text(l10n.custom, style: const TextStyle(fontSize: 12)),
                                selected: isCustom,
                                onSelected: (v) {
                                  if (v && _receiveConfig.outputPath.isEmpty) {
                                    setState(() {
                                    _receiveConfig = _receiveConfig.copyWith(outputPath: effectivePath);
                                    _saveReceivePrefs();
                                  });
                                  }
                                },
                              ),
                              if (isCustom) ...[
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(Icons.folder_open, size: 18),
                                  visualDensity: VisualDensity.compact,
                                  tooltip: l10n.selectFolder,
                                  onPressed: _pickReceivePath,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(formatPathForDisplay(effectivePath, downloadsLabel: l10n.downloadsFolder), maxLines: 1, overflow: TextOverflow.ellipsis, style: context.textTheme.bodySmall),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),

          const SizedBox(height: 32),
        ],
      ),
      ),  // ScrollConfiguration
    );    // CommonScaffold
  }

  Widget _buildStatusChip(AppLocalizations l10n) {
    final (label, color) = switch (_phase) {
      ReceivePhase.pending => (l10n.pending, Colors.orange),
      ReceivePhase.receiving => (l10n.receiving, context.colorScheme.primary),
      ReceivePhase.completed => (l10n.completed, Colors.green),
      ReceivePhase.failed => (l10n.failed, Colors.red),
      ReceivePhase.cancelled => (l10n.cancelled, Colors.grey),
      _ => ('', Colors.transparent),
    };
    if (label.isEmpty) return const SizedBox.shrink();
    if (_phase == ReceivePhase.receiving) {
      return CapsuleProgressChip(
        label: label,
        color: color,
        progress: _simProgress,
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(icon, size: 18, color: context.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: context.textTheme.titleSmall?.copyWith(
                  color: context.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        ...children,
      ],
    );
  }
}

/// Transparent route that lets the scanner UI show over the previous page.
class _QrScannerRoute<T> extends PageRoute<T> with MaterialRouteTransitionMixin<T> {
  _QrScannerRoute({required this.builder});
  final WidgetBuilder builder;

  @override
  Widget buildContent(BuildContext context) => builder(context);

  @override
  bool get maintainState => true;
  @override
  Color? get barrierColor => Colors.black87;
  @override
  bool get barrierDismissible => false;
  @override
  String? get barrierLabel => 'Close';
  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);
}

/// QR scanner dialog — full-screen Scaffold with camera filling the body.
class _QRScannerDialog extends StatefulWidget {
  const _QRScannerDialog();

  @override
  State<_QRScannerDialog> createState() => _QRScannerDialogState();
}

class _QRScannerDialogState extends State<_QRScannerDialog> {
  late final MobileScannerController _ctrl;
  bool _hasScanned = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _ctrl = MobileScannerController();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw != null && raw.isNotEmpty) {
      _hasScanned = true;
      Navigator.of(context).pop(raw);
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;
    final path = result.files.first.path;
    if (path == null) return;
    try {
      final capture = await _ctrl.analyzeImage(path);
      if (capture != null && capture.barcodes.isNotEmpty && mounted) {
        final raw = capture.barcodes.first.rawValue;
        if (raw != null && raw.isNotEmpty) {
          Navigator.of(context).pop(raw);
        }
      }
    } catch (e, st) {
      commonPrint('QR image analyze error: $e\n$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Camera view
            MobileScanner(
              controller: _ctrl,
              onDetect: _onDetect,
              errorBuilder: (context, error, child) {
                String message;
                if (error case MobileScannerException(errorCode: final code)) {
                  message = switch (code) {
                    MobileScannerErrorCode.permissionDenied => l10n.cameraPermissionDenied,
                    MobileScannerErrorCode.unsupported => l10n.cameraUnsupported,
                    _ => '${l10n.cameraError}: ${code.name}',
                  };
                } else {
                  message = '$error';
                }
                commonPrint('MobileScanner error: $message ($error)');
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.white70),
                      const SizedBox(height: 12),
                      Text(message, style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                );
              },
            ),
            // Bottom buttons
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image, size: 18),
                    label: Text(l10n.selectQRImage),
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(200),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 18),
                    label: Text(l10n.cancel),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
            size: 20,
          ),
        ),
      ),
    );
  }
}

enum ReceivePhase { idle, pending, receiving, completed, failed, cancelled }
