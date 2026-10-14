import 'package:fl_croc/core/core.dart';
import 'package:material_ui/material_ui.dart';

/// Draws a QR code whose module matrix comes from the Go bridge.
///
/// Encoding lives in Go because croc already ships a QR encoder
/// (`skip2/go-qrcode`) and owns the URL the sender's code carries. Rendering the
/// matrix is all that is left for the UI, so this widget has no third-party
/// dependency and no encoding logic of its own.
///
/// Renders nothing when the backend cannot encode (see
/// [CoreInterface.qrCodeMatrix]) or when [data] does not fit in a QR code.
class QrCodeView extends StatefulWidget {
  const QrCodeView({
    super.key,
    required this.data,
    required this.size,
    required this.color,
  });

  /// Text to encode. Use [CoreController.webReceiveUrl] for a share code.
  final String data;

  /// Width and height of the square the code is drawn into.
  final double size;

  /// Colour of the dark modules.
  final Color color;

  @override
  State<QrCodeView> createState() => _QrCodeViewState();
}

class _QrCodeViewState extends State<QrCodeView> {
  // Held in state because the encode crosses into Go and decodes JSON; rebuilding
  // the send page during a transfer must not repeat that.
  QrMatrix? _matrix;

  @override
  void initState() {
    super.initState();
    _matrix = coreController.qrCodeMatrix(widget.data);
  }

  @override
  void didUpdateWidget(QrCodeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _matrix = coreController.qrCodeMatrix(widget.data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final matrix = _matrix;
    if (matrix == null) return SizedBox.square(dimension: widget.size);

    return SizedBox.square(
      dimension: widget.size,
      child: CustomPaint(painter: _QrPainter(matrix, widget.color)),
    );
  }
}

class _QrPainter extends CustomPainter {
  _QrPainter(this.matrix, this.color);

  final QrMatrix matrix;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final module = size.shortestSide / matrix.size;
    final paint = Paint()
      ..color = color
      ..isAntiAlias = false;

    // One path for every dark module: a single draw call instead of one per
    // module, which matters because a QR holds a few hundred of them.
    final path = Path();
    for (var y = 0; y < matrix.size; y++) {
      for (var x = 0; x < matrix.size; x++) {
        if (!matrix.isDark(x, y)) continue;
        path.addRect(Rect.fromLTWH(x * module, y * module, module, module));
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_QrPainter oldDelegate) =>
      oldDelegate.matrix != matrix || oldDelegate.color != color;
}
