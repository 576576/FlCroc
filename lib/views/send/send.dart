import 'dart:async';
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
  }

  @override
  void dispose() {
    _saveSendPrefs();
    _sendSubscription?.cancel();
    _textController.dispose();
    _codeController.dispose();
    _shakeCtrl.dispose();
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

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null && result.files.isNotEmpty) {
      setState(() => _selectedFiles.addAll(result.files));
    }
  }

  void _removeFile(int index) => setState(() => _selectedFiles.removeAt(index));
  void _clearFiles() => setState(() => _selectedFiles.clear());
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
        _textController.text = content;
      }
    }
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

  String get _currentPhrase => _codeController.text.trim();
  bool get _allowEmptyPhrase => _phraseMode == PhraseMode.defaultMode;

  // ── Persistence ──

  static const _prefSendConfig = 'send_config';
  static const _prefAutoCopy = 'send_autoCopy';
  static const _prefPhraseMode = 'send_phraseMode';
  static const _prefIsTextMode = 'send_isTextMode';

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
  }

  void _saveSendPrefs() {
    AppPrefs.setJson(_prefSendConfig, _sendConfig.toJson());
    AppPrefs.setBool(_prefAutoCopy, _autoCopyPhrase);
    AppPrefs.setString(_prefPhraseMode, _phraseMode.index.toString());
    AppPrefs.setBool(_prefIsTextMode, _isTextMode);
  }

  // ── Send ──

  Future<void> _startSend() async {
    try {
      await _doSend();
    } catch (e, s) {
      debugPrint('_startSend crashed: $e\n$s');
      if (mounted) {
        setState(() => _phase = SendPhase.fail);
        _showWarning('Send error: $e');
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
    if (!isText && _selectedFiles.isEmpty) {
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

    final files = isText
        ? [FileItem(name: l10n.sentText, path: '', size: textContent.length)]
        : _selectedFiles.map((f) => FileItem(name: f.name, path: f.path ?? '', size: f.size)).toList();
    final totalSize = isText ? textContent.length : files.fold<int>(0, (a, f) => a + f.size);

    final record = TransferRecord(
      id: appController.generateId(),
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

    final options = SendOptions(
      filePaths: isText ? [] : _selectedFiles.map((f) => f.path ?? '').where((p) => p.isNotEmpty).toList(),
      codePhrase: code.isEmpty ? null : code, sendingText: isText, textContent: isText ? textContent : '',
      curve: _sendConfig.curve, hashAlgorithm: _sendConfig.hashAlgorithm,
      noCompress: _sendConfig.noCompress, overwrite: _sendConfig.overwrite,
      zipFolder: _sendConfig.zipFolder,
      onlyLocal: useNoRelay,
      relayAddress: useCustom ? relayConfig.address : null,
      relayPassword: useCustom ? relayConfig.password : null,
    );

    setState(() => _phase = SendPhase.sending);

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
            setState(() => _phase = SendPhase.success);
            appController.updateTransferRecord(record.copyWith(status: TransferStatus.completed, transferredSize: totalSize, endTime: DateTime.now()));
            _sendSubscription = null;
            break;
          case TransferProgressStatus.failed:
            setState(() => _phase = SendPhase.fail);
            appController.updateTransferRecord(record.copyWith(status: TransferStatus.failed, endTime: DateTime.now()));
            if (progress.error != null && mounted) context.showSnackBar(progress.error!);
            _sendSubscription = null;
            break;
          case TransferProgressStatus.cancelled:
            setState(() => _phase = SendPhase.fail);
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
        context.showSnackBar('Send failed: $e');
        _sendSubscription = null;
      },
      onDone: () {
        if (mounted && _phase != SendPhase.success) setState(() => _phase = SendPhase.fail);
        _sendSubscription = null;
      },
    );
  }

  Future<void> _cancelSend() async {
    final sub = _sendSubscription;
    if (sub == null) return;
    await sub.cancel();
    _sendSubscription = null;
    final tid = _activeTransferId;
    if (tid != null) {
      coreController.cancelTransfer(tid);
    }
    if (mounted) setState(() => _phase = SendPhase.fail);
  }

  void _showWarning(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 3)),
    );
  }

  // ── Build ──

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
                  SizedBox(width: 28, height: 28, child: IconButton(icon: const Icon(Icons.refresh, size: 16), onPressed: _generateCode, padding: EdgeInsets.zero, tooltip: l10n.generate)),
                  SizedBox(width: 28, height: 28, child: IconButton(icon: const Icon(Icons.copy, size: 16), onPressed: _copyPhrase, padding: EdgeInsets.zero, tooltip: l10n.copyCode)),
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
      body: FileDropTarget(
        enabled: !_isTextMode && isDesktop,
        onFilesDropped: (files) {
          final newFiles = <PlatformFile>[];
          for (final f in files) {
            if (!_selectedFiles.any((s) => s.path == f.path)) {
              newFiles.add(PlatformFile(name: f.path.split(Platform.pathSeparator).last, path: f.path, size: f.lengthSync()));
            }
          }
          if (newFiles.isNotEmpty) setState(() => _selectedFiles.addAll(newFiles));
        },
        child: ListView(
        children: [
          // Mode toggle
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: false, label: Text(l10n.fileMode), icon: const Icon(Icons.insert_drive_file)),
                ButtonSegment(value: true, label: Text(l10n.textMode), icon: const Icon(Icons.text_snippet)),
              ],
              selected: {_isTextMode},
              onSelectionChanged: (v) => setState(() { _isTextMode = v.first; _saveSendPrefs(); }),
            ),
          ),

          if (_isTextMode) ...[
            _shakeWrap(1, _buildSection(l10n.textMode, Icons.text_snippet, [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
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
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  TextButton.icon(
                    onPressed: _pickTextFile,
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(l10n.uploadTextFile),
                  ),
                  TextButton.icon(
                    onPressed: _clearText,
                    icon: const Icon(Icons.clear_all, size: 16),
                    label: Text(l10n.clearText),
                  ),
                ]),
              ),
            ])),
          ] else ...[
            _shakeWrap(0, _buildSection(l10n.files, Icons.insert_drive_file, [
              if (_selectedFiles.isEmpty)
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
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  TextButton.icon(onPressed: _pickFiles, icon: const Icon(Icons.add, size: 16), label: Text(l10n.selectFiles)),
                  TextButton.icon(
                    onPressed: _selectedFiles.isNotEmpty ? _clearFiles : null,
                    icon: const Icon(Icons.clear_all, size: 16),
                    label: Text(l10n.clearFiles),
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
                    _phraseChip(l10n.phraseModeDefault, PhraseMode.defaultMode),
                    _phraseChip(l10n.phraseModeOn, PhraseMode.on),
                    _phraseChip(l10n.phraseModeNever, PhraseMode.never),
                  ]),
                ),
              ),
              const Divider(height: 0, indent: 56),
              ListItem.switchItem(
                leading: const Icon(Icons.copy, size: 20),
                title: Text(l10n.autoCopyPhrase),
                delegate: SwitchDelegate(value: _autoCopyPhrase, onChanged: (v) => setState(() { _autoCopyPhrase = v; _saveSendPrefs(); })),
              ),
              const Divider(height: 0, indent: 16),
              ListItem(leading: const Icon(Icons.show_chart), title: Text(l10n.encryptionCurve), subtitle: _buildCurveChips(l10n)),
              const Divider(height: 0, indent: 56),
              ListItem(leading: const Icon(Icons.tag), title: Text(l10n.hashAlgorithm), subtitle: _buildHashChips(l10n)),
              const Divider(height: 0, indent: 56),
              ListItem.switchItem(leading: const Icon(Icons.compress), title: Text(l10n.compression), delegate: SwitchDelegate(value: !_sendConfig.noCompress, onChanged: (v) => setState(() { _sendConfig = _sendConfig.copyWith(noCompress: !v); _saveSendPrefs(); }))),
              const Divider(height: 0, indent: 56),
              ListItem.switchItem(leading: const Icon(Icons.folder_zip), title: Text(l10n.zipFolder), delegate: SwitchDelegate(value: _sendConfig.zipFolder, onChanged: (v) => setState(() { _sendConfig = _sendConfig.copyWith(zipFolder: v); _saveSendPrefs(); }))),
              const SizedBox(height: 12),
            ],
          ),

          // QR code — below transfer options
          if (_currentPhrase.isNotEmpty)
            Padding(padding: const EdgeInsets.all(16), child: Center(child: QrImageView(data: _currentPhrase, version: QrVersions.auto, size: 160))),

          const SizedBox(height: 32),
        ],
        ),  // ListView
      ),    // FileDropTarget
    );
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
      if (v) setState(() {
        _phraseMode = mode;
        if (mode != PhraseMode.defaultMode) _codeController.clear();
        _saveSendPrefs();
      });
    },
  );

  Widget _buildCurveChips(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        children: [
          ChoiceChip(
            label: Text(l10n.phraseModeDefault),
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
            label: Text(l10n.phraseModeDefault),
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
      _ => ('', Colors.transparent),
    };
    if (label.isEmpty) return const SizedBox.shrink();
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

enum SendPhase { idle, pending, sending, success, fail }
