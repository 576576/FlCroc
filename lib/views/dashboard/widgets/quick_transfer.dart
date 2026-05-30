import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/core/controller.dart';
import 'package:fl_croc/models/models.dart';
import 'package:fl_croc/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// Unified quick send + receive card for the dashboard.
///
/// Layout: [File/Text toggle] [file/text area] [Send] [Settings] [Receive]
///
/// The static [statusNotifier] emits the current transfer phase so the parent
/// dashboard can show a status chip in its AppBar.
class QuickTransferWidget extends StatefulWidget {
  const QuickTransferWidget({super.key});

  /// Emits `(label, color)` when a transfer is active; null when idle.
  static final statusNotifier = ValueNotifier<(String, Color)?>(null);

  @override
  State<QuickTransferWidget> createState() => _QuickTransferWidgetState();
}

enum _QuickPhase { idle, sending, receiving, completed, failed, cancelled }

class _QuickTransferWidgetState extends State<QuickTransferWidget> {
  final _textCtrl = TextEditingController();
  bool _isTextMode = false;
  List<PlatformFile> _selectedFiles = [];
  _QuickPhase _phase = _QuickPhase.idle;

  // Quick codes
  String _quickSendCode = '';
  String _quickReceiveCode = '';
  bool _useSameCode = false;

  static const _prefQuickSendCode = 'quick_send_code';
  static const _prefQuickReceiveCode = 'quick_receive_code';
  static const _prefUseSameCode = 'quick_use_same_code';

  @override
  void initState() {
    super.initState();
    _quickSendCode = AppPrefs.getString(_prefQuickSendCode);
    _quickReceiveCode = AppPrefs.getString(_prefQuickReceiveCode);
    _useSameCode = AppPrefs.getBool(_prefUseSameCode);
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    QuickTransferWidget.statusNotifier.value = null;
    super.dispose();
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
    if (label != null && color != null) {
      QuickTransferWidget.statusNotifier.value = (label, color);
    } else {
      QuickTransferWidget.statusNotifier.value = null;
    }
  }

  // ── Send ──

  Future<void> _quickSend() async {
    if (!coreController.isAvailable) {
      if (mounted) context.showSnackBar(context.appLocalizations.noCrocBackend);
      return;
    }
    if (!_isTextMode && _selectedFiles.isEmpty) return;
    if (_isTextMode && _textCtrl.text.trim().isEmpty) return;

    _setPhase(_QuickPhase.sending);

    final resolvedPaths = <String>[];
    if (!_isTextMode) {
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

    final code = _quickSendCode.isNotEmpty ? _quickSendCode : null;
    final options = SendOptions(
      filePaths: _isTextMode ? [] : resolvedPaths,
      codePhrase: code,
      sendingText: _isTextMode,
      textContent: _isTextMode ? _textCtrl.text.trim() : '',
    );

    final l10n = context.appLocalizations;
    coreController.sendFiles(options).listen(
      (progress) {
        if (!mounted) return;
        if (progress.status == TransferProgressStatus.failed && progress.error != null) {
          context.showSnackBar(l10n.localizeCrocError(progress.error!, isSend: true));
        }
        if (progress.status == TransferProgressStatus.completed) {
          _setPhase(_QuickPhase.completed);
          Future.delayed(const Duration(seconds: 2), () => _setPhase(_QuickPhase.idle));
        } else if (progress.status == TransferProgressStatus.failed) {
          _setPhase(_QuickPhase.failed);
          Future.delayed(const Duration(seconds: 2), () => _setPhase(_QuickPhase.idle));
        } else if (progress.status == TransferProgressStatus.cancelled) {
          _setPhase(_QuickPhase.cancelled);
          Future.delayed(const Duration(seconds: 2), () => _setPhase(_QuickPhase.idle));
        }
      },
      onError: (_) {
        if (mounted) { _setPhase(_QuickPhase.failed); Future.delayed(const Duration(seconds: 2), () => _setPhase(_QuickPhase.idle)); }
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
      if (mounted) context.showSnackBar(context.appLocalizations.noCrocBackend);
      return;
    }

    _setPhase(_QuickPhase.receiving);

    final options = ReceiveOptions(
      codePhrase: code,
      outputPath: AppPaths.savePathSync,
    );

    coreController.receiveFiles(options).listen(
      (progress) {
        if (!mounted) return;
        if (progress.status == TransferProgressStatus.failed && progress.error != null) {
          context.showSnackBar(l10n.localizeCrocError(progress.error!));
        }
        if (progress.status == TransferProgressStatus.completed) {
          _setPhase(_QuickPhase.completed);
          Future.delayed(const Duration(seconds: 2), () => _setPhase(_QuickPhase.idle));
        } else if (progress.status == TransferProgressStatus.failed) {
          _setPhase(_QuickPhase.failed);
          Future.delayed(const Duration(seconds: 2), () => _setPhase(_QuickPhase.idle));
        } else if (progress.status == TransferProgressStatus.cancelled) {
          _setPhase(_QuickPhase.cancelled);
          Future.delayed(const Duration(seconds: 2), () => _setPhase(_QuickPhase.idle));
        }
      },
      onError: (_) {
        if (mounted) { _setPhase(_QuickPhase.failed); Future.delayed(const Duration(seconds: 2), () => _setPhase(_QuickPhase.idle)); }
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
            // Mode toggle — full width
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
                  border: const OutlineInputBorder(),
                  isDense: true,
                  contentPadding: const EdgeInsets.all(8),
                ),
              )
            else ...[
              if (_selectedFiles.isNotEmpty)
                ..._selectedFiles.map((f) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.insert_drive_file, size: 18),
                  title: Text(f.name, style: const TextStyle(fontSize: 13)),
                  contentPadding: EdgeInsets.zero,
                )),
              TextButton.icon(
                onPressed: _pickFiles,
                icon: const Icon(Icons.add, size: 16),
                label: Text(l10n.selectFiles, style: const TextStyle(fontSize: 12)),
              ),
            ],
            const SizedBox(height: 8),
            // Action row — wrap on narrow cards
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 4,
              runSpacing: 4,
              children: [
                _actionButton(
                  onPressed: _phase != _QuickPhase.idle ? null : _quickSend,
                  icon: Icons.send,
                  label: l10n.send,
                ),
                IconButton(
                  icon: const Icon(Icons.settings, size: 20),
                  tooltip: l10n.settings,
                  visualDensity: VisualDensity.compact,
                  onPressed: _phase != _QuickPhase.idle ? null : _showSettings,
                ),
                _actionButton(
                  onPressed: _phase != _QuickPhase.idle ? null : _quickReceive,
                  icon: Icons.download,
                  label: l10n.receive,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({required VoidCallback? onPressed, required IconData icon, required String label}) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: FilledButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }
}
