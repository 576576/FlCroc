import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// QR scanner widget using native CameraX + ZXing on Android via PlatformView.
/// On non-Android platforms, shows an unsupported message.
class NativeQrScanner extends StatefulWidget {
  const NativeQrScanner({
    super.key,
    required this.onDetect,
    this.errorBuilder,
  });

  final ValueChanged<String> onDetect;
  final Widget Function(BuildContext context, String error)? errorBuilder;

  @override
  State<NativeQrScanner> createState() => _NativeQrScannerState();
}

class _NativeQrScannerState extends State<NativeQrScanner> {
  MethodChannel? _channel;
  bool _hasScanned = false;

  @override
  void dispose() {
    _channel?.invokeMethod('stop');
    super.dispose();
  }

  void _onNativeScan(String code) {
    if (_hasScanned) return;
    _hasScanned = true;
    widget.onDetect(code);
  }

  @override
  Widget build(BuildContext context) {
    if (!Platform.isAndroid) {
      final msg = 'QR scanning is only supported on Android';
      if (widget.errorBuilder != null) return widget.errorBuilder!(context, msg);
      return const Center(
        child: Text('QR scanning not supported on this platform',
            style: TextStyle(color: Colors.white70)),
      );
    }
    return AndroidView(
      viewType: 'flcroc/qr_scanner',
      onPlatformViewCreated: (int viewId) {
        _channel = MethodChannel('flcroc/qr_scanner_$viewId');
        _channel!.setMethodCallHandler((call) async {
          switch (call.method) {
            case 'onScan':
              final code = call.arguments['code'] as String?;
              if (code != null && code.isNotEmpty) _onNativeScan(code);
            case 'onError':
              if (mounted) setState(() {});
          }
        });
      },
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}
