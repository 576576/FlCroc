import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/controller.dart';
import 'package:fl_croc/core/controller.dart';
import 'package:fl_croc/enum/enum.dart';
import 'package:fl_croc/models/models.dart';
import 'package:fl_croc/widgets/widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SendView extends ConsumerStatefulWidget {
  const SendView({super.key});

  @override
  ConsumerState<SendView> createState() => _SendViewState();
}

class _SendViewState extends ConsumerState<SendView> {
  List<PlatformFile> _selectedFiles = [];
  String _codePhrase = '';
  String _customCode = '';
  bool _isSending = false;
  bool _isTextMode = false;
  final _textController = TextEditingController();
  SendConfig _sendConfig = const SendConfig();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFiles = result.files;
      });
    }
  }

  void _generateCode() {
    // Generate a random code phrase (3 words, like croc does)
    const adjectives = ['happy', 'blue', 'fast', 'cool', 'red', 'big'];
    const nouns = ['tiger', 'eagle', 'shark', 'wolf', 'bear', 'hawk'];
    const verbs = ['run', 'fly', 'swim', 'jump', 'dash', 'zoom'];
    final rng = DateTime.now().millisecond;
    final adj = adjectives[rng % adjectives.length];
    final noun = nouns[(rng * 2) % nouns.length];
    final verb = verbs[(rng * 3) % verbs.length];
    setState(() {
      _codePhrase = '$adj-$noun-$verb';
    });
  }

  void _startSend() {
    final isText = _isTextMode;
    final textContent = _textController.text.trim();
    if (!isText && _selectedFiles.isEmpty) return;
    if (isText && textContent.isEmpty) return;
    final code = _customCode.isNotEmpty ? _customCode : _codePhrase;
    if (code.isEmpty) return;

    setState(() => _isSending = true);
    final files = isText
        ? [FileItem(name: 'text.txt', path: '', size: textContent.length)]
        : _selectedFiles
              .map((f) => FileItem(
                    name: f.name,
                    path: f.path ?? '',
                    size: f.size,
                  ))
              .toList();
    final totalSize = isText
        ? textContent.length
        : files.fold<int>(0, (a, f) => a + f.size);

    final record = TransferRecord(
      id: appController.generateId(),
      direction: TransferDirection.sent,
      status: TransferStatus.transferring,
      files: files,
      totalSize: totalSize,
      startTime: DateTime.now(),
      codePhrase: code,
    );
    appController.addTransferRecord(record);

    // Wire up the real croc backend
    final options = SendOptions(
      filePaths: isText
          ? []
          : _selectedFiles
              .map((f) => f.path ?? '')
              .where((p) => p.isNotEmpty)
              .toList(),
      codePhrase: code,
      sendingText: isText,
      textContent: isText ? textContent : '',
      curve: _sendConfig.curve,
      hashAlgorithm: _sendConfig.hashAlgorithm,
      noCompress: _sendConfig.noCompress,
      overwrite: _sendConfig.overwrite,
      zipFolder: _sendConfig.zipFolder,
      onlyLocal: _sendConfig.onlyLocal,
      disableLocal: _sendConfig.disableLocal,
    );

    coreController.sendFiles(options).listen(
      (progress) {
        if (!mounted) return;
        switch (progress.status) {
          case TransferProgressStatus.transferring:
            appController.updateTransferRecord(
              record.copyWith(
                status: TransferStatus.transferring,
                transferredSize: progress.transferredSize,
              ),
            );
            break;
          case TransferProgressStatus.completed:
            setState(() => _isSending = false);
            appController.updateTransferRecord(
              record.copyWith(
                status: TransferStatus.completed,
                transferredSize: totalSize,
                endTime: DateTime.now(),
              ),
            );
            break;
          case TransferProgressStatus.failed:
            setState(() => _isSending = false);
            appController.updateTransferRecord(
              record.copyWith(
                status: TransferStatus.failed,
                endTime: DateTime.now(),
              ),
            );
            if (progress.error != null && mounted) {
              context.showSnackBar(progress.error!);
            }
            break;
          case TransferProgressStatus.cancelled:
            setState(() => _isSending = false);
            appController.updateTransferRecord(
              record.copyWith(
                status: TransferStatus.cancelled,
                endTime: DateTime.now(),
              ),
            );
            break;
          default:
            break;
        }
      },
      onError: (e) {
        if (!mounted) return;
        setState(() => _isSending = false);
        appController.updateTransferRecord(
          record.copyWith(
            status: TransferStatus.failed,
            endTime: DateTime.now(),
          ),
        );
        context.showSnackBar('Send failed: $e');
      },
      onDone: () {
        if (mounted) setState(() => _isSending = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    return CommonScaffold(
      title: l10n.sendFiles,
      actions: [
        if (_selectedFiles.isNotEmpty || (_isTextMode && _textController.text.isNotEmpty))
          FilledButtonWidget(
            onPressed: _isSending ? null : _startSend,
            text: l10n.startSend,
            icon: Icons.send,
          ),
        const SizedBox(width: 8),
      ],
      body: ListView(
        children: [
          // Send Mode Toggle
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: false, label: Text(l10n.fileMode), icon: const Icon(Icons.insert_drive_file)),
                ButtonSegment(value: true, label: Text(l10n.textMode), icon: const Icon(Icons.text_snippet)),
              ],
              selected: {_isTextMode},
              onSelectionChanged: (v) => setState(() => _isTextMode = v.first),
            ),
          ),

          if (_isTextMode) ...[
            // Text Input
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _textController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: l10n.textHint,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.text_fields),
                ),
              ),
            ),
          ] else ...[
            // File Selection
            _buildSection(
              l10n.files,
              Icons.insert_drive_file,
              [
                if (_selectedFiles.isEmpty)
                  NullStatusWidget(
                    message: l10n.noFiles,
                    icon: Icons.cloud_upload_outlined,
                  )
                else
                  ..._selectedFiles.map(
                    (f) => ListTile(
                      leading: const Icon(Icons.insert_drive_file),
                      title: Text(f.name),
                      trailing: Text(f.size.fileSize),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: OutlinedButton.icon(
                    onPressed: _pickFiles,
                    icon: const Icon(Icons.add),
                    label: Text(l10n.selectFiles),
                  ),
                ),
              ],
            ),
          ],

          const Divider(),

          // Code Phrase
          _buildSection(
            l10n.codePhrase,
            Icons.vpn_key,
            [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: l10n.customCodeHint,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (v) => _customCode = v,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonal(
                      onPressed: _generateCode,
                      child: Text(l10n.generate),
                    ),
                  ],
                ),
              ),
              if (_codePhrase.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _codePhrase,
                              style: context.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _codePhrase));
                              if (mounted) {
                                context.showSnackBar(l10n.codeCopied);
                              }
                            },
                            icon: const Icon(Icons.copy),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (_codePhrase.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: QrImageView(
                      data: _codePhrase,
                      version: QrVersions.auto,
                      size: 160,
                    ),
                  ),
                ),
            ],
          ),

          const Divider(),

          // Transfer Options
          _buildSection(
            l10n.transferOptions,
            Icons.tune,
            [
              ListItem.open(
                leading: const Icon(Icons.show_chart),
                title: Text('${l10n.encryptionCurve}: ${_sendConfig.curve}'),
                delegate: OpenDelegate(
                  widget: OptionsDialog<String>(
                    title: l10n.encryptionCurve,
                    options: availableCurves,
                    value: _sendConfig.curve,
                    textBuilder: (v) => v,
                    onChanged: (v) {
                      setState(() {
                        _sendConfig = _sendConfig.copyWith(curve: v);
                      });
                    },
                  ),
                ),
              ),
              const Divider(height: 0, indent: 56),
              ListItem.open(
                leading: const Icon(Icons.tag),
                title: Text('${l10n.hashAlgorithm}: ${_sendConfig.hashAlgorithm}'),
                delegate: OpenDelegate(
                  widget: OptionsDialog<String>(
                    title: l10n.hashAlgorithm,
                    options: availableHashAlgos,
                    value: _sendConfig.hashAlgorithm,
                    textBuilder: (v) => v,
                    onChanged: (v) {
                      setState(() {
                        _sendConfig = _sendConfig.copyWith(hashAlgorithm: v);
                      });
                    },
                  ),
                ),
              ),
              const Divider(height: 0, indent: 56),
              ListItem.switchItem(
                leading: const Icon(Icons.compress),
                title: Text(l10n.compression),
                delegate: SwitchDelegate(
                  value: !_sendConfig.noCompress,
                  onChanged: (v) {
                    setState(() {
                      _sendConfig = _sendConfig.copyWith(noCompress: !v);
                    });
                  },
                ),
              ),
              const Divider(height: 0, indent: 56),
              ListItem.switchItem(
                leading: const Icon(Icons.folder_zip),
                title: Text(l10n.zipFolder),
                delegate: SwitchDelegate(
                  value: _sendConfig.zipFolder,
                  onChanged: (v) {
                    setState(() {
                      _sendConfig = _sendConfig.copyWith(zipFolder: v);
                    });
                  },
                ),
              ),
              const Divider(height: 0, indent: 56),
              ListItem.switchItem(
                leading: const Icon(Icons.wifi_off),
                title: Text(l10n.localOnly),
                delegate: SwitchDelegate(
                  value: _sendConfig.onlyLocal,
                  onChanged: (v) {
                    setState(() {
                      _sendConfig = _sendConfig.copyWith(onlyLocal: v);
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
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
