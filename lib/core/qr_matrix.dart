/// A QR code module matrix produced by the Go bridge.
///
/// [modules] holds one character per module in row-major order (`'1'` is a dark
/// module) and already includes go-qrcode's quiet zone, so callers draw it as-is
/// without adding a margin of their own.
class const QrMatrix(this.size, this.modules) {
  final int size;
  final String modules;

  bool isDark(int x, int y) => modules.codeUnitAt(y * size + x) == 0x31;

  /// Parses the `CrocQRCode` JSON payload, or returns null if it is malformed.
  static QrMatrix? tryParse(Map<String, dynamic> json) {
    final size = json['size'];
    final modules = json['modules'];
    if (size is! int || modules is! String) return null;
    if (size <= 0 || modules.length != size * size) return null;
    return QrMatrix(size, modules);
  }
}
