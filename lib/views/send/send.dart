import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/controller.dart';
import 'package:fl_croc/core/controller.dart';
import 'package:fl_croc/enum/enum.dart';
import 'package:fl_croc/l10n/l10n.dart';
import 'package:fl_croc/models/models.dart';
import 'package:fl_croc/providers/providers.dart';
import 'package:fl_croc/widgets/widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

enum PhraseMode { defaultMode, on, never }

class SendView extends ConsumerStatefulWidget {
  const SendView({super.key});

  @override
  ConsumerState<SendView> createState() => _SendViewState();
}

class _SendViewState extends ConsumerState<SendView> with TickerProviderStateMixin {
  final List<PlatformFile> _selectedFiles = [];
  bool _isTextMode = false;
  PhraseMode _phraseMode = PhraseMode.defaultMode;
  SendPhase _phase = SendPhase.idle;

  final _textController = TextEditingController();
  final _codeController = TextEditingController();
  SendConfig _sendConfig = const SendConfig();
  bool _autoCopyPhrase = false;
  bool _whiteBgQR = false; // always use white background for QR code

  // Text size limit: null=default(10000), 0=unlimited, >0=custom
  int? _textByteLimit;
  static const _defaultTextLimit = 10000;
  final _limitCtrl = TextEditingController();

  double _simProgress = 0;
  Timer? _progressTimer;
  bool _progressDone = false;

  void _startSimProgress() {
    _progressDone = false;
    _simProgress = 0;
    _progressTimer?.cancel();
    int step = 0;
    _progressTimer = Timer.periodic(const Duration(milliseconds: 60), (t) {
      if (!mounted) { t.cancel(); return; }
      step++;
      if (step <= 3) {
        _simProgress = (step * 0.25 / 3);
      } else if (_simProgress < 0.90) {
        _simProgress += 0.01;
        if (_simProgress > 0.90) _simProgress = 0.90;
      }
      setState(() {});
    });
  }

  void _finishSimProgress() {
    _progressTimer?.cancel();
    _progressDone = true;
    int step = 0;
    _progressTimer = Timer.periodic(const Duration(milliseconds: 16), (t) {
      if (!mounted) { t.cancel(); return; }
      step++;
      if (step <= 10) {
        _simProgress = 0.90 + (step * 0.01);
      } else if (step <= 22) {
        _simProgress = 1.0;
      } else {
        t.cancel();
        if (mounted) setState(() => _phase = SendPhase.success);
      }
      setState(() {});
    });
  }

  int get _effectiveTextLimit => _textByteLimit ?? _defaultTextLimit;

  // Send lifecycle
  StreamSubscription<TransferProgress>? _sendSubscription;
  String? _activeTransferId;

  // Shake
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;
  int _shakeTarget = -1; // -1:none, 0:files, 1:text, 2:phrase

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _shakeAnim = Tween<double>(begin: 0, end: 2 * pi * 3).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );
    _loadSendPrefs();
    _textController.addListener(_enforceTextLimit);
    _pickUpSharedFiles();
  }

  /// Pick up files shared via Android/iOS "Open with" intent.
  void _pickUpSharedFiles() {
    final paths = ref.read(pendingSharedFilesProvider);
    if (paths.isEmpty) return;
    final newFiles = <PlatformFile>[];
    for (final p in paths) {
      final f = File(p);
      if (!f.existsSync()) continue;
      if (_selectedFiles.any((s) => s.path == p)) continue;
      newFiles.add(PlatformFile(
        name: p.split(Platform.pathSeparator).last,
        path: p,
        size: f.lengthSync(),
      ));
    }
    if (newFiles.isNotEmpty) {
      setState(() { _selectedFiles.addAll(newFiles); _isTextMode = false; });
    }
    ref.read(pendingSharedFilesProvider.notifier).state = [];
  }

  bool _limiting = false;

  void _enforceTextLimit() {
    if (_limiting) return;
    final limit = _effectiveTextLimit;
    if (limit <= 0) return; // unlimited
    final bytes = utf8.encode(_textController.text);
    if (bytes.length > limit) {
      _limiting = true;
      // Truncate to limit bytes
      var truncated = '';
      var byteCount = 0;
      for (final char in _textController.text.characters) {
        final charBytes = utf8.encode(char);
        if (byteCount + charBytes.length > limit) break;
        truncated += char;
        byteCount += charBytes.length;
      }
      final oldSelection = _textController.selection;
      _textController.text = truncated;
      if (oldSelection.baseOffset <= truncated.length) {
        _textController.selection = oldSelection;
      }
      _limiting = false;
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _saveSendPrefs();
    _sendSubscription?.cancel();
    _textController.dispose();
    _codeController.dispose();
    _shakeCtrl.dispose();
    _limitCtrl.dispose();
    super.dispose();
  }

  void _shake(int target) {
    try {
      _shakeTarget = target;
      _shakeCtrl.forward(from: 0).then((_) => _shakeTarget = -1);
    } catch (_) {
      _shakeTarget = -1;
    }
  }

  // ── File management ──

  String? _selectedFolder;

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null && result.files.isNotEmpty) {
      setState(() => _selectedFiles.addAll(result.files));
    }
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

  void _removeFile(int index) => setState(() => _selectedFiles.removeAt(index));
  void _clearFiles() => setState(() { _selectedFiles.clear(); _selectedFolder = null; });
  void _clearText() => _textController.clear();

  void _pasteText() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      _textController.text = data.text!;
    }
  }

  Future<void> _pickTextFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'md', 'json', 'xml', 'csv', 'log', 'yaml', 'yml'],
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.path != null) {
        final content = await File(file.path!).readAsString();
        final limited = _applyTextLimit(content);
        _textController.text = limited;
      }
    }
  }

  /// Truncate text to the effective byte limit, respecting character boundaries.
  String _applyTextLimit(String text) {
    final limit = _effectiveTextLimit;
    if (limit <= 0) return text;
    final bytes = utf8.encode(text);
    if (bytes.length <= limit) return text;
    var result = '';
    var count = 0;
    for (final char in text.characters) {
      final cb = utf8.encode(char);
      if (count + cb.length > limit) break;
      result += char;
      count += cb.length;
    }
    return result;
  }

  // ── Code phrase ──

  void _generateCode() {
    const adj = ['swift','bold','calm','keen','warm','cool','fast','bright','sharp','pure','free','wild'];
    const nouns = ['falcon','jaguar','python','raven','otter','eagle','tiger','whale','hawk','wolf','bear'];
    final rng = Random();
    final a = adj[rng.nextInt(adj.length)];
    final n = nouns[rng.nextInt(nouns.length)];
    final dc = 3 + rng.nextInt(3);
    final min = pow(10, dc - 1).toInt();
    final max = pow(10, dc).toInt() - 1;
    final d = min + rng.nextInt(max - min + 1);
    _codeController.text = '$a-$n-$d';
    if (_autoCopyPhrase) _copyPhrase();
  }

  void _copyPhrase() {
    final p = _codeController.text.trim();
    if (p.isEmpty) return;
    Clipboard.setData(ClipboardData(text: p));
    if (mounted) context.showSnackBar(context.appLocalizations.codeCopied);
  }

  void _pastePhrase() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      _codeController.text = data.text!;
    }
  }

  void _showQRCode() {
    final code = _currentPhrase;
    if (code.isEmpty) {
      if (mounted) context.showSnackBar(context.appLocalizations.phraseEmpty);
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) {
        final l10n = context.appLocalizations;
        return AlertDialog(
          title: Text(l10n.generateQRCode),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 200, height: 200,
                child: _buildQR(code, 200),
              ),
              const SizedBox(height: 12),
              Text(code, style: const TextStyle(fontFamily: 'monospace', fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                if (mounted) context.showSnackBar(context.appLocalizations.codeCopied);
              },
              child: Text(l10n.copy),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.confirm),
            ),
          ],
        );
      },
    );
  }

  String get _currentPhrase => _codeController.text.trim();
  bool get _allowEmptyPhrase => _phraseMode == PhraseMode.defaultMode;

  // ── Persistence ──

  static const _prefSendConfig = 'send_config';
  static const _prefAutoCopy = 'send_autoCopy';
  static const _prefPhraseMode = 'send_phraseMode';
  static const _prefIsTextMode = 'send_isTextMode';
  static const _prefTextByteLimit = 'send_textByteLimit';
  static const _prefWhiteBgQR = 'send_whiteBgQR';

  void _loadSendPrefs() {
    final json = AppPrefs.getJson(_prefSendConfig);
    if (json.isNotEmpty) {
      _sendConfig = SendConfig.fromJson(json);
    }
    _autoCopyPhrase = AppPrefs.getBool(_prefAutoCopy);
    final pmIdx = AppPrefs.getString(_prefPhraseMode);
    if (pmIdx.isNotEmpty) {
      _phraseMode = PhraseMode.values[int.tryParse(pmIdx) ?? 0];
    }
    _isTextMode = AppPrefs.getBool(_prefIsTextMode);
    _whiteBgQR = AppPrefs.getBool(_prefWhiteBgQR);
    final limitStr = AppPrefs.getString(_prefTextByteLimit);
    if (limitStr.isNotEmpty) {
      _textByteLimit = int.tryParse(limitStr);
      if (_textByteLimit != null && _textByteLimit! > 0) {
        _limitCtrl.text = _textByteLimit.toString();
      }
    }
  }

  void _saveSendPrefs() {
    AppPrefs.setJson(_prefSendConfig, _sendConfig.toJson());
    AppPrefs.setBool(_prefAutoCopy, _autoCopyPhrase);
    AppPrefs.setString(_prefPhraseMode, _phraseMode.index.toString());
    AppPrefs.setBool(_prefIsTextMode, _isTextMode);
    AppPrefs.setBool(_prefWhiteBgQR, _whiteBgQR);
    AppPrefs.setString(_prefTextByteLimit, _textByteLimit?.toString() ?? '');
  }

  // ── Send ──

  Future<void> _startSend() async {
    final l10n = context.appLocalizations;
    try {
      await _doSend();
    } catch (e, s) {
      debugPrint('_startSend crashed: $e\n$s');
      if (mounted) {
        setState(() => _phase = SendPhase.fail);
        _showWarning('${l10n.sendFailed}: $e');
      }
    }
  }

  Future<void> _doSend() async {
    final l10n = context.appLocalizations;

    if (!coreController.isAvailable) {
      setState(() => _phase = SendPhase.fail);
      _showWarning(l10n.noCrocBackend);
      return;
    }

    final isText = _isTextMode;
    final textContent = _textController.text.trim();

    // Validate content
    if (!isText && _selectedFiles.isEmpty && _selectedFolder == null) {
      _showWarning(l10n.noFiles);
      _shake(0); // shake file section
      return;
    }
    if (isText && textContent.isEmpty) {
      _showWarning(l10n.enterTextWarning);
      _shake(1); // shake text area
      return;
    }

    String code = _currentPhrase;
    if (_phraseMode == PhraseMode.on) {
      _generateCode();
      code = _currentPhrase;
    }

    if (code.isEmpty) {
      if (_allowEmptyPhrase) {
        // let croc generate
      } else {
        _showWarning(l10n.enterPhraseWarning);
        _shake(2); // shake phrase field
        return;
      }
    }

    setState(() => _phase = SendPhase.pending);

    // Generate transfer ID early so cancel can always find it
    final transferId = appController.generateId();
    _activeTransferId = transferId;

    final files = isText
        ? [FileItem(name: textContent, path: '', size: textContent.length)]
        : _selectedFolder != null
            ? [FileItem(name: _selectedFolder!.split(Platform.pathSeparator).last, path: _selectedFolder!, size: 0)]
            : _selectedFiles.map((f) => FileItem(name: f.name, path: f.path ?? '', size: f.size)).toList();
    final totalSize = isText
        ? textContent.length
        : files.fold<int>(0, (a, f) => a + f.size);

    final record = TransferRecord(
      id: transferId,
      direction: TransferDirection.sent,
      status: TransferStatus.pending,
      files: files, totalSize: totalSize,
      startTime: DateTime.now(),
      codePhrase: code.isNotEmpty ? code : '(croc)',
    );
    appController.addTransferRecord(record);

    final relayConfig = ref.read(appSettingProvider).relayConfig;
    final useNoRelay = relayConfig.type == RelayType.noRelay;
    final useCustom = relayConfig.type == RelayType.customRelay;

    // Resolve file paths for Go bridge (Android content URIs → temp files)
    final resolvedPaths = <String>[];
    String? tempDirPath;
    if (!isText) {
      if (_selectedFolder != null) {
        resolvedPaths.add(_selectedFolder!);
      } else {
        for (final f in _selectedFiles) {
          final p = f.path;
          if (p == null || p.isEmpty) continue;
          if (isAndroid && p.startsWith('content://')) {
            try {
              final bytes = await File(p).readAsBytes();
              tempDirPath ??= (await getTemporaryDirectory()).path;
              final tempFile = File('$tempDirPath${Platform.pathSeparator}${f.name}');
              await tempFile.writeAsBytes(bytes);
              resolvedPaths.add(tempFile.path);
            } catch (_) {
              // Skip inaccessible content URIs
            }
          } else {
            resolvedPaths.add(p);
          }
        }
      }
    }
    // Ensure we have a temp dir for text mode on Android
    if (isText) {
      tempDirPath = (await getTemporaryDirectory()).path;
    }

    final options = SendOptions(
      filePaths: isText ? [] : resolvedPaths,
      codePhrase: code.isEmpty ? null : code, sendingText: isText, textContent: isText ? textContent : '',
      tempDir: tempDirPath ?? '',
      curve: _sendConfig.curve, hashAlgorithm: _sendConfig.hashAlgorithm,
      noCompress: _sendConfig.noCompress, overwrite: _sendConfig.overwrite,
      zipFolder: _sendConfig.zipFolder,
      onlyLocal: useNoRelay,
      relayAddress: useCustom ? relayConfig.address : null,
      relayPassword: useCustom ? relayConfig.password : null,
      relayPorts: useCustom ? relayConfig.port : null,
    );

    setState(() => _phase = SendPhase.sending);

    _startSimProgress();

    _sendSubscription = coreController.sendFiles(options).listen(
      (progress) {
        if (!mounted) return;
        _activeTransferId = progress.transferId;
        // Capture code phrase generated by croc
        if (progress.codePhrase != null && progress.codePhrase!.isNotEmpty) {
          _codeController.text = progress.codePhrase!;
          appController.updateTransferRecord(record.copyWith(codePhrase: progress.codePhrase));
          if (_autoCopyPhrase) _copyPhrase();
          setState(() {}); // rebuild to show QR code
        }
        switch (progress.status) {
          case TransferProgressStatus.completed:
            _finishSimProgress();
            appController.updateTransferRecord(record.copyWith(status: TransferStatus.completed, transferredSize: totalSize, endTime: DateTime.now()));
            _sendSubscription = null;
            break;
          case TransferProgressStatus.failed:
            _progressTimer?.cancel();
            setState(() => _phase = SendPhase.fail);
            appController.updateTransferRecord(record.copyWith(status: TransferStatus.failed, endTime: DateTime.now()));
            if (progress.error != null && mounted) {
              commonPrint('Send failed: ${progress.error}');
              context.showSnackBar(l10n.localizeCrocError(progress.error!, isSend: true));
            }
            _sendSubscription = null;
            break;
          case TransferProgressStatus.cancelled:
            setState(() => _phase = SendPhase.cancelled);
            appController.updateTransferRecord(record.copyWith(status: TransferStatus.cancelled, endTime: DateTime.now()));
            _sendSubscription = null;
            break;
          case TransferProgressStatus.initializing:
          case TransferProgressStatus.connecting:
          case TransferProgressStatus.transferring:
            break;
        }
      },
      onError: (e) {
        if (!mounted) return;
        setState(() => _phase = SendPhase.fail);
        appController.updateTransferRecord(record.copyWith(status: TransferStatus.failed, endTime: DateTime.now()));
        context.showSnackBar(l10n.localizeCrocError(e.toString(), isSend: true));
        commonPrint('Send error: $e');
        _sendSubscription = null;
      },
      onDone: () {
        if (mounted && _phase != SendPhase.success && _phase != SendPhase.cancelled) setState(() => _phase = SendPhase.fail);
        _sendSubscription = null;
      },
    );
  }

  Future<void> _cancelSend() async {
    // Immediately show cancelled state — no delay
    if (mounted) setState(() => _phase = SendPhase.cancelled);

    // Always attempt Go-side cancel first — it uses the global activeClient
    final tid = _activeTransferId;
    if (tid != null) {
      coreController.cancelTransfer(tid);
    }
    // Then cancel the stream subscription (non-null only after listen starts)
    final sub = _sendSubscription;
    if (sub != null) {
      await sub.cancel();
      _sendSubscription = null;
    }

    // 2s cooldown before re-enabling the send button
    await Future.delayed(const Duration(seconds: 2));
    if (mounted && _phase == SendPhase.cancelled) {
      setState(() => _phase = SendPhase.idle);
    }
  }

  void _showWarning(String msg) {
    context.showSnackBar(msg);
  }

  // ── Build ──

  Widget _buildQR(String data, double size) {
    final qr = QrImageView(
      data: data,
      version: QrVersions.auto,
      size: size,
      foregroundColor: _whiteBgQR
          ? Colors.black
          : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
    );
    if (!_whiteBgQR) return qr;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: qr,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    // Watch for files shared from other apps (warm start)
    ref.listen<List<String>>(pendingSharedFilesProvider, (prev, next) {
      if (next.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _pickUpSharedFiles());
      }
    });

    return CommonScaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: SizedBox(
          height: 36,
          child: TextField(
            controller: _codeController,
            readOnly: _phraseMode != PhraseMode.never,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1),
            decoration: InputDecoration(
              hintText: _phraseHint(l10n),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              isDense: true,
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 28, height: 28, child: IconButton(icon: const Icon(Icons.qr_code, size: 16), onPressed: _showQRCode, padding: EdgeInsets.zero, tooltip: l10n.generateQRCode)),
                  SizedBox(width: 28, height: 28, child: IconButton(icon: const Icon(Icons.copy, size: 16), onPressed: _copyPhrase, padding: EdgeInsets.zero, tooltip: l10n.copy)),
                  SizedBox(width: 28, height: 28, child: IconButton(icon: const Icon(Icons.paste, size: 16), onPressed: _pastePhrase, padding: EdgeInsets.zero, tooltip: l10n.paste)),
                ],
              ),
            ),
          ),
        ),
        actions: [
          if (_phase != SendPhase.idle) _buildStatusChip(l10n),
          const SizedBox(width: 8),
          FilledButtonWidget(
            onPressed: _phase == SendPhase.sending || _phase == SendPhase.pending
                ? _cancelSend
                : _phase == SendPhase.cancelled
                    ? null
                    : _startSend,
            text: _phase == SendPhase.sending || _phase == SendPhase.pending
                ? l10n.cancel
                : l10n.send,
            icon: _phase == SendPhase.sending || _phase == SendPhase.pending
                ? Icons.close
                : Icons.send,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        children: [
          // Mode toggle
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: false, label: Text(l10n.file), icon: const Icon(Icons.insert_drive_file)),
                ButtonSegment(value: true, label: Text(l10n.text), icon: const Icon(Icons.text_snippet)),
              ],
              selected: {_isTextMode},
              onSelectionChanged: (v) => setState(() { _isTextMode = v.first; _saveSendPrefs(); }),
            ),
          ),

          if (_isTextMode) ...[
            _shakeWrap(1, _buildSection(l10n.text, Icons.text_snippet, [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: FileDropTarget(
                  enabled: isDesktop,
                  onFilesDropped: _onTextDrop,
                  hintText: l10n.dropToAdd,
                  child: TextField(
                    controller: _textController, maxLines: 5,
                    decoration: InputDecoration(
                      hintText: l10n.textHint,
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.paste, size: 20),
                        onPressed: _pasteText,
                        tooltip: l10n.paste,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  TextButton.icon(
                    onPressed: _pickTextFile,
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(l10n.selectTextFile),
                  ),
                  TextButton.icon(
                    onPressed: _clearText,
                    icon: const Icon(Icons.clear_all, size: 16),
                    label: Text(l10n.clear),
                  ),
                ]),
              ),
            ])),
          ] else ...[
            _shakeWrap(0, _buildSection(l10n.file, Icons.insert_drive_file, [
              FileDropTarget(
                enabled: isDesktop,
                onFilesDropped: _onFileDrop,
                hintText: l10n.dropToAdd,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  if (_selectedFolder != null)
                    ListTile(
                      leading: const Icon(Icons.folder, color: Colors.amber),
                      title: Text(_selectedFolder!.split(Platform.pathSeparator).last),
                      subtitle: Text(_selectedFolder!, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.textTheme.bodySmall),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() => _selectedFolder = null),
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                  else if (_selectedFiles.isEmpty)
                    NullStatusWidget(message: l10n.noFiles, icon: Icons.cloud_upload_outlined)
                  else
                    ...List.generate(_selectedFiles.length, (i) {
                      final f = _selectedFiles[i];
                      return ListTile(
                        leading: const Icon(Icons.insert_drive_file), title: Text(f.name),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(f.size.fileSize, style: context.textTheme.bodySmall), const SizedBox(width: 4),
                          IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => _removeFile(i), visualDensity: VisualDensity.compact),
                        ]),
                      );
                    }),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    TextButton.icon(onPressed: _pickFiles, icon: const Icon(Icons.add, size: 16), label: Text(l10n.selectFiles)),
                    const SizedBox(width: 8),
                    TextButton.icon(onPressed: _pickFolder, icon: const Icon(Icons.create_new_folder, size: 16), label: Text(l10n.selectFolder)),
                  ]),
                  TextButton.icon(
                    onPressed: _selectedFiles.isNotEmpty || _selectedFolder != null ? _clearFiles : null,
                    icon: const Icon(Icons.clear_all, size: 16),
                    label: Text(l10n.clear),
                  ),
                ]),
              ),
            ])),
          ],

          // Transfer options — collapsible (collapsed while sending)
          ExpansionTile(
            shape: const Border(),
            title: Text(l10n.transferOptions),
            leading: const Icon(Icons.tune),
            initiallyExpanded: _phase == SendPhase.idle,
            onExpansionChanged: (_) => setState(() {}),
            children: [
              // Phrase mode chips — inline with other settings
              ListItem(
                leading: const Icon(Icons.vpn_key),
                title: Text(l10n.phraseMode),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(spacing: 8, runSpacing: 4, children: [
                    _phraseChip(l10n.defaultLabel, PhraseMode.defaultMode),
                    _phraseChip(l10n.phraseModeOn, PhraseMode.on),
                    _phraseChip(l10n.custom, PhraseMode.never),
                    if (_phraseMode == PhraseMode.never)
                      SizedBox(
                        height: 32,
                        child: IconButton(
                          icon: const Icon(Icons.refresh, size: 16),
                          tooltip: l10n.generate,
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          onPressed: _generateCode,
                        ),
                      ),
                  ]),
                ),
              ),
              ListItem.switchItem(
                leading: const Icon(Icons.copy, size: 20),
                title: Text(l10n.autoCopyPhrase),
                delegate: SwitchDelegate(value: _autoCopyPhrase, onChanged: (v) => setState(() { _autoCopyPhrase = v; _saveSendPrefs(); })),
              ),
              ListItem.switchItem(
                leading: const Icon(Icons.qr_code_2, size: 20),
                title: Text(l10n.whiteBgQR),
                delegate: SwitchDelegate(value: _whiteBgQR, onChanged: (v) => setState(() { _whiteBgQR = v; _saveSendPrefs(); })),
              ),
              ListItem(leading: const Icon(Icons.show_chart), title: Text(l10n.encryptionCurve), subtitle: _buildCurveChips(l10n)),
              ListItem(leading: const Icon(Icons.tag), title: Text(l10n.hashAlgorithm), subtitle: _buildHashChips(l10n)),
              ListItem.switchItem(leading: const Icon(Icons.compress), title: Text(l10n.enableCompression), delegate: SwitchDelegate(value: !_sendConfig.noCompress, onChanged: (v) => setState(() { _sendConfig = _sendConfig.copyWith(noCompress: !v); _saveSendPrefs(); }))),
              ListItem.switchItem(leading: const Icon(Icons.folder_zip), title: Text(l10n.zipFolder), delegate: SwitchDelegate(value: _sendConfig.zipFolder, onChanged: (v) => setState(() { _sendConfig = _sendConfig.copyWith(zipFolder: v); _saveSendPrefs(); }))),
              ListItem(
                leading: const Icon(Icons.text_snippet),
                title: Text(l10n.textSizeLimit),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: Text(l10n.defaultLabel, style: const TextStyle(fontSize: 12)),
                        selected: _textByteLimit == null,
                        onSelected: (v) {
                          if (v) setState(() { _textByteLimit = null; _limitCtrl.clear(); _saveSendPrefs(); });
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text(l10n.unlimited, style: const TextStyle(fontSize: 12)),
                        selected: _textByteLimit == 0,
                        onSelected: (v) {
                          if (v) setState(() { _textByteLimit = 0; _limitCtrl.clear(); _saveSendPrefs(); });
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text(l10n.custom, style: const TextStyle(fontSize: 12)),
                        selected: _textByteLimit != null && _textByteLimit! > 0,
                        onSelected: (v) {
                          if (v) setState(() { _textByteLimit = _defaultTextLimit; _limitCtrl.text = '$_defaultTextLimit'; _saveSendPrefs(); });
                        },
                      ),
                      if (_textByteLimit != null && _textByteLimit! > 0) ...[
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 72,
                          child: TextField(
                            controller: _limitCtrl,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 13),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (v) {
                              final val = int.tryParse(v);
                              if (val != null && val > 0) {
                                _textByteLimit = val;
                                _saveSendPrefs();
                                _enforceTextLimit();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text('B', style: TextStyle(fontSize: 12)),
                        IconButton(
                          icon: const Icon(Icons.restart_alt, size: 16),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                          tooltip: l10n.reset,
                          onPressed: () {
                            setState(() {
                              _textByteLimit = null;
                              _limitCtrl.clear();
                              _saveSendPrefs();
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),

          // QR code — below transfer options
          if (_currentPhrase.isNotEmpty)
            Padding(padding: const EdgeInsets.all(16), child: Center(child: _buildQR(_currentPhrase, 160))),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _onTextDrop(List<File> files) {
    for (final f in files) {
      if (!FileSystemEntity.isDirectorySync(f.path)) {
        try {
          final content = f.readAsStringSync();
          _textController.text = _applyTextLimit(content);
          _textController.selection = TextSelection.collapsed(offset: _textController.text.length);
          return;
        } catch (_) {}
      }
    }
  }

  void _onFileDrop(List<File> files) {
    commonPrint('_onFileDrop: ${files.length} files, paths=${files.map((f) => f.path).toList()}');
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

  // ── Shake wrapper ──

  Widget _shakeWrap(int target, Widget child) {
    return AnimatedBuilder(
      animation: _shakeCtrl.view,
      builder: (_, child) {
        final dx = (_shakeTarget == target) ? sin(_shakeAnim.value) * 6 : 0.0;
        return Transform.translate(offset: Offset(dx, 0), child: child!);
      },
      child: child,
    );
  }

  // ── Helper methods ──

  String _phraseHint(AppLocalizations l10n) => switch (_phraseMode) {
    PhraseMode.defaultMode => l10n.phraseHintCroc,
    PhraseMode.on => l10n.phraseHintRandom,
    PhraseMode.never => l10n.enterCodePhrase,
  };

  Widget _phraseChip(String label, PhraseMode mode) => ChoiceChip(
    label: Text(label), selected: _phraseMode == mode,
    onSelected: (v) {
      if (v) {
        setState(() {
        _phraseMode = mode;
        if (mode != PhraseMode.defaultMode) _codeController.clear();
        _saveSendPrefs();
      });
      }
    },
  );

  Widget _buildCurveChips(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        children: [
          ChoiceChip(
            label: Text(l10n.defaultLabel),
            selected: _sendConfig.curve == defaultCurve,
            onSelected: (v) { if (v) setState(() { _sendConfig = _sendConfig.copyWith(curve: defaultCurve); _saveSendPrefs(); }); },
          ),
          ...availableCurves.where((c) => c != defaultCurve).map((c) {
            return ChoiceChip(
              label: Text(c),
              selected: _sendConfig.curve == c,
              onSelected: (v) { if (v) setState(() { _sendConfig = _sendConfig.copyWith(curve: c); _saveSendPrefs(); }); },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHashChips(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        children: [
          ChoiceChip(
            label: Text(l10n.defaultLabel),
            selected: _sendConfig.hashAlgorithm == defaultHashAlgo,
            onSelected: (v) { if (v) setState(() { _sendConfig = _sendConfig.copyWith(hashAlgorithm: defaultHashAlgo); _saveSendPrefs(); }); },
          ),
          ...availableHashAlgos.where((h) => h != defaultHashAlgo).map((h) {
            return ChoiceChip(
              label: Text(h),
              selected: _sendConfig.hashAlgorithm == h,
              onSelected: (v) { if (v) setState(() { _sendConfig = _sendConfig.copyWith(hashAlgorithm: h); _saveSendPrefs(); }); },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatusChip(AppLocalizations l10n) {
    final (label, color) = switch (_phase) {
      SendPhase.pending => (l10n.pending, Colors.orange),
      SendPhase.sending => (l10n.sending, context.colorScheme.primary),
      SendPhase.success => (l10n.completed, Colors.green),
      SendPhase.fail => (l10n.failed, Colors.red),
      SendPhase.cancelled => (l10n.cancelled, Colors.grey),
      _ => ('', Colors.transparent),
    };
    if (label.isEmpty) return const SizedBox.shrink();
    if (_phase == SendPhase.sending) {
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

  Widget _buildSection(String title, IconData icon, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), child: Row(children: [
        Icon(icon, size: 18, color: context.colorScheme.primary), const SizedBox(width: 8),
        Text(title, style: context.textTheme.titleSmall?.copyWith(color: context.colorScheme.primary)),
      ])),
      ...children,
    ],
  );
}

enum SendPhase { idle, pending, sending, success, fail, cancelled }
