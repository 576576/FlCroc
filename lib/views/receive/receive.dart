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
import 'package:gscankit/gscankit.dart';

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

  // Received content tracking
  final List<FileItem> _receivedFiles = [];
  int _selectedTab = 0; // 0=files, 1=text
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

  void _openScanner() async {
    if (isDesktop) {
      if (mounted) context.showSnackBar(context.appLocalizations.scanMobileOnly);
      return;
    }
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const _QRScannerPage(),
      ),
    );
    if (result != null && mounted) {
      _codeController.text = result;
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
    if (code.isEmpty) return;
    final l10n = context.appLocalizations;

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

    coreController.receiveFiles(options).listen(
      (progress) {
        if (!mounted) return;
        switch (progress.status) {
          case TransferProgressStatus.initializing:
          case TransferProgressStatus.connecting:
            if (mounted) setState(() { _phase = ReceivePhase.receiving; });
            break;
          case TransferProgressStatus.transferring:
            if (_phase == ReceivePhase.pending) setState(() { _phase = ReceivePhase.receiving; });
            appController.updateTransferRecord(
              record.copyWith(
                status: TransferStatus.transferring,
                transferredSize: progress.transferredSize,
              ),
            );
            if (mounted) setState(() {});
          case TransferProgressStatus.completed:
            if (progress.isText) {
              _receivedTextController.text = progress.textContent;
              _receivedFiles.clear();
              _selectedTab = 1;
              setState(() { _isReceiving = false; _phase = ReceivePhase.completed; });
              appController.updateTransferRecord(
                record.copyWith(
                  status: TransferStatus.completed,
                  totalSize: progress.textContent.length,
                  endTime: DateTime.now(),
                ),
              );
            } else {
              // Parse file names from the completed event
              final raw = progress.currentFile.isNotEmpty
                  ? progress.currentFile.split('\n').where((n) => n.isNotEmpty).toList()
                  : <String>[];
              
              // Remove .zip wrapper if croc auto-extracted (strip trailing .zip from name)
              final fileNames = raw.map((n) {
                if (raw.length == 1 && n.endsWith('.zip')) {
                  return n.substring(0, n.length - 4);
                }
                return n;
              }).toList();

              List<FileItem> fileItems;
              if (fileNames.length > 1) {
                // Detect common root directory
                final separator = fileNames[0].contains('/') ? '/' : (fileNames[0].contains('\\') ? '\\' : null);
                String? commonRoot;
                if (separator != null) {
                  final root = fileNames[0].split(separator)[0];
                  if (fileNames.every((n) => n.startsWith('$root$separator'))) {
                    commonRoot = root;
                  }
                }
                if (commonRoot != null) {
                  // Display as single folder
                  final folderPath = '$_effectiveOutputPath${Platform.pathSeparator}$commonRoot';
                  fileItems = [FileItem(name: commonRoot, path: folderPath, size: progress.totalSize)];
                } else {
                  fileItems = fileNames.map((n) => FileItem(
                    name: n,
                    path: '$_effectiveOutputPath${Platform.pathSeparator}${n.replaceAll('/', Platform.pathSeparator)}',
                    size: progress.totalSize,
                  )).toList();
                }
              } else if (fileNames.length == 1) {
                // Single file: detect if it's a folder (no extension) or a file
                final name = fileNames[0];
                final isFolder = !name.contains('.') || progress.totalSize == 0;
                final path = isFolder
                    ? '$_effectiveOutputPath${Platform.pathSeparator}$name'
                    : '$_effectiveOutputPath${Platform.pathSeparator}$name';
                fileItems = [FileItem(name: name, path: path, size: progress.totalSize)];
              } else {
                fileItems = [FileItem(name: l10n.receiving, path: _effectiveOutputPath, size: 0)];
              }

              _receivedFiles.clear();
              _receivedFiles.addAll(fileItems);
              _receivedTextController.clear();
              if (fileItems.isNotEmpty) {
                _selectedTab = 0;
                // Android: export to Downloads via MediaStore
                if (isAndroid) {
                  for (final f in fileItems) {
                    AppPaths.exportToDownloads(f.path);
                  }
                }
              }
              setState(() { _isReceiving = false; _phase = ReceivePhase.completed; });

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
            setState(() { _isReceiving = false; _phase = ReceivePhase.failed; });
            appController.updateTransferRecord(
              record.copyWith(
                status: TransferStatus.failed,
                endTime: DateTime.now(),
              ),
            );
            if (progress.error != null && mounted) {
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
        setState(() => _isReceiving = false);
        final l10n = context.appLocalizations;
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

  @override
  void dispose() {
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
            onPressed: _isReceiving ? null : _startReceive,
            text: l10n.receive,
            icon: Icons.download,
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
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: _receivedTextController.text.isNotEmpty
                            ? () => Clipboard.setData(ClipboardData(text: _receivedTextController.text))
                            : null,
                        tooltip: l10n.copy,
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
      _ => ('', Colors.transparent),
    };
    if (label.isEmpty) return const SizedBox.shrink();
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

/// QR scanner page powered by gscankit.
class _QRScannerPage extends StatefulWidget {
  const _QRScannerPage();

  @override
  State<_QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<_QRScannerPage> {
  bool _hasScanned = false;

  void _onDetect(dynamic capture) {
    if (_hasScanned) return;
    final raw = capture?.barcodes?.firstOrNull?.rawValue;
    if (raw != null && raw is String && raw.isNotEmpty) {
      _hasScanned = true;
      Navigator.of(context).pop(raw);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    return GscanKit(
      onDetect: _onDetect,
      setPortraitOrientation: false,
      gscanOverlayConfig: const GscanOverlayConfig(),
      appBar: (context, ctrl) => AppBar(
        title: Text(l10n.scanQRCode),
        actions: [
          GalleryButton(
            controller: ctrl,
            isSuccess: ValueNotifier<bool?>(null),
            onDetect: _onDetect,
            text: '',
            icon: const Icon(Icons.image, color: Colors.white, size: 22),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_android),
            tooltip: l10n.flipCamera,
            onPressed: () => ctrl.switchCamera(),
          ),
        ],
      ),
    );
  }
}

enum ReceivePhase { idle, pending, receiving, completed, failed }
