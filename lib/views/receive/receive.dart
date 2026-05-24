import 'package:fl_croc/common/common.dart';
import 'package:fl_croc/controller.dart';
import 'package:fl_croc/core/controller.dart';
import 'package:fl_croc/enum/enum.dart';
import 'package:fl_croc/models/models.dart';
import 'package:fl_croc/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ReceiveView extends ConsumerStatefulWidget {
  const ReceiveView({super.key});

  @override
  ConsumerState<ReceiveView> createState() => _ReceiveViewState();
}

class _ReceiveViewState extends ConsumerState<ReceiveView> {
  final _codeController = TextEditingController();
  bool _isReceiving = false;
  ReceiveConfig _receiveConfig = const ReceiveConfig();

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

    final options = ReceiveOptions(
      codePhrase: code,
      overwrite: _receiveConfig.overwrite,
      onlyLocal: _receiveConfig.onlyLocal,
      outputPath: _receiveConfig.outputPath,
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
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'Receive Files',
      body: ListView(
        children: [
          const SizedBox(height: 32),

          // Code Phrase Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.download,
                      size: 48,
                      color: context.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Enter Code Phrase',
                      style: context.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        hintText: 'e.g., happy-tiger-run',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.vpn_key),
                      ),
                      textAlign: TextAlign.center,
                      style: context.textTheme.headlineSmall?.copyWith(
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isReceiving ? null : _startReceive,
                        icon: const Icon(Icons.download),
                        label: const Text('Start Receive'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Options
          _buildSection(
            'Options',
            Icons.tune,
            [
              ListItem.switchItem(
                leading: const Icon(Icons.file_copy),
                title: const Text('Overwrite'),
                delegate: SwitchDelegate(
                  value: _receiveConfig.overwrite,
                  onChanged: (v) {
                    setState(() {
                      _receiveConfig = _receiveConfig.copyWith(overwrite: v);
                    });
                  },
                ),
              ),
              const Divider(height: 0, indent: 56),
              ListItem.switchItem(
                leading: const Icon(Icons.wifi_off),
                title: const Text('Local Only'),
                delegate: SwitchDelegate(
                  value: _receiveConfig.onlyLocal,
                  onChanged: (v) {
                    setState(() {
                      _receiveConfig = _receiveConfig.copyWith(onlyLocal: v);
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Scan QR Code
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () {
                _openScanner();
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan QR Code'),
            ),
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
