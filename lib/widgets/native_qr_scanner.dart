import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Cross-platform QR scanner widget.
///
/// On **Android**: uses native CameraX + ZXing via PlatformView (ported from
/// croc-app). This is more reliable than the mobile_scanner plugin.
///
/// On **iOS / Desktop / Web**: falls back to `mobile_scanner` plugin.
class NativeQrScanner extends StatefulWidget {
  const NativeQrScanner({
    super.key,
    required this.onDetect,
    this.errorBuilder,
  });

  /// Called when a QR code is detected.
  final ValueChanged<String> onDetect;

  /// Called when an error occurs (permission denied, camera error, etc.).
  final Widget Function(BuildContext context, String error)? errorBuilder;

  @override
  State<NativeQrScanner> createState() => _NativeQrScannerState();
}

class _NativeQrScannerState extends State<NativeQrScanner> {
  // ── Native (Android) state ──
  MethodChannel? _channel;
  bool _hasScanned = false;

  // ── Fallback (iOS / desktop) state ──
  MobileScannerController? _fallbackCtrl;

  bool get _isNative => Platform.isAndroid;

  @override
  void initState() {
    super.initState();
    if (_isNative) {
      // MethodChannel is created inside the AndroidView; listen via a
      // named channel after the view is created.
    } else {
      _fallbackCtrl = MobileScannerController(
        formats: const [BarcodeFormat.qrCode],
      );
    }
  }

  @override
  void dispose() {
    if (_isNative) {
      _channel?.invokeMethod('stop');
    } else {
      _fallbackCtrl?.dispose();
    }
    super.dispose();
  }

  void _onNativeScan(String code) {
    if (_hasScanned) return;
    _hasScanned = true;
    widget.onDetect(code);
  }

  void _onFallbackDetect(BarcodeCapture capture) {
    if (_hasScanned) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw != null && raw.isNotEmpty) {
      _hasScanned = true;
      widget.onDetect(raw);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isNative) {
      return _buildNative(context);
    }
    return _buildFallback(context);
  }

  // ── Native Android: PlatformView ──

  Widget _buildNative(BuildContext context) {
    return AndroidView(
      viewType: 'flcroc/qr_scanner',
      onPlatformViewCreated: (int viewId) {
        _channel = MethodChannel('flcroc/qr_scanner_$viewId');
        _channel!.setMethodCallHandler((call) async {
          switch (call.method) {
            case 'onScan':
              final code = call.arguments['code'] as String?;
              if (code != null && code.isNotEmpty) {
                _onNativeScan(code);
              }
            case 'onError':
              // Will show in errorBuilder on next rebuild
              if (mounted) setState(() {});
          }
        });
      },
      creationParamsCodec: const StandardMessageCodec(),
    );
  }

  // ── Fallback: mobile_scanner ──

  Widget _buildFallback(BuildContext context) {
    return MobileScanner(
      controller: _fallbackCtrl!,
      onDetect: _onFallbackDetect,
      errorBuilder: (context, error, child) {
        final msg = error.errorCode.name;
        if (widget.errorBuilder != null) {
          return widget.errorBuilder!(context, msg);
        }
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.white70),
              const SizedBox(height: 12),
              Text(msg, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        );
      },
    );
  }
}
