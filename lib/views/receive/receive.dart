import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/controller.dart';
import 'package:fl_croc/core/controller.dart';
import 'package:fl_croc/enum/enum.dart';
import 'package:fl_croc/l10n/l10n.dart';
import 'package:fl_croc/models/models.dart';
import 'package:fl_croc/providers/providers.dart';
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
  void _startReceive() {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isReceiving = true);

    final record = TransferRecord(
      id: appController.generateId(),
      direction: TransferDirection.received,
      status: TransferStatus.transferring,
      files: [const FileItem(name: 'Receiving...', path: '', size: 0)],
      totalSize: 0,
      startTime: DateTime.now(),
      codePhrase: code,
    );

    appController.addTransferRecord(record);

    final relayConfig = ref.read(appSettingProvider).relayConfig;
    final useNoRelay = relayConfig.type == RelayType.noRelay;
    final useCustom = relayConfig.type == RelayType.customRelay;

    final options = ReceiveOptions(
      codePhrase: code,
      overwrite: _receiveConfig.overwrite,
      onlyLocal: useNoRelay,
      outputPath: _receiveConfig.outputPath,
      relayAddress: useCustom ? relayConfig.address : null,
      relayPassword: useCustom ? relayConfig.password : null,
    );

    coreController.receiveFiles(options).listen(
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
          case TransferProgressStatus.completed:
            setState(() => _isReceiving = false);
            appController.updateTransferRecord(
              record.copyWith(
                status: TransferStatus.completed,
                transferredSize: progress.totalSize,
                endTime: DateTime.now(),
              ),
            );
          case TransferProgressStatus.failed:
            setState(() => _isReceiving = false);
            appController.updateTransferRecord(
              record.copyWith(
                status: TransferStatus.failed,
                endTime: DateTime.now(),
              ),
            );
            if (progress.error != null && mounted) {
              context.showSnackBar(progress.error!);
            }
          case TransferProgressStatus.cancelled:
            setState(() => _isReceiving = false);
            appController.updateTransferRecord(
              record.copyWith(
                status: TransferStatus.cancelled,
                endTime: DateTime.now(),
              ),
            );
          case TransferProgressStatus.initializing:
          case TransferProgressStatus.connecting:
            break;
        }
      },
      onError: (e) {
        if (!mounted) return;
        setState(() => _isReceiving = false);
        context.showSnackBar('Receive failed: $e');
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
                    ),
                  ),
                  SizedBox(
                    width: 28, height: 28,
                    child: IconButton(
                      icon: const Icon(Icons.paste, size: 16),
                      onPressed: _pastePhrase,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          if (_isReceiving) _buildStatusChip(l10n),
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
            const SizedBox(height: 24),

            // Options
            _buildSection(
            l10n.options,
            Icons.tune,
            [
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
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
      ),  // ScrollConfiguration
    );    // CommonScaffold
  }

  Widget _buildStatusChip(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.colorScheme.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(l10n.receiveFiles, style: TextStyle(fontSize: 12, color: context.colorScheme.primary, fontWeight: FontWeight.w600)),
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

/// Full-screen QR code scanner page.
/// Returns the scanned code phrase as a String via Navigator.pop.
class _QRScannerPage extends StatefulWidget {
  const _QRScannerPage();

  @override
  State<_QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<_QRScannerPage> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _hasScanned = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue != null) {
      _hasScanned = true;
      Navigator.of(context).pop(barcode!.rawValue!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: Icon(
              _scannerController.torchEnabled ? Icons.flash_on : Icons.flash_off,
            ),
            onPressed: () => _scannerController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_android),
            onPressed: () => _scannerController.switchCamera(),
          ),
        ],
      ),
      body: MobileScanner(
        controller: _scannerController,
        onDetect: _onDetect,
      ),
    );
  }
}
