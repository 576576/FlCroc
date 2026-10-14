// QrMatrix is built from the JSON the Go bridge returns (CrocQRCode). A payload
// whose module count does not match its size would otherwise surface as a
// RangeError inside the painter, i.e. as a red screen.
import 'package:fl_croc/core/qr_matrix.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QrMatrix.tryParse', () {
    test('accepts a well-formed payload', () {
      final matrix = QrMatrix.tryParse({'size': 2, 'modules': '1001'});
      expect(matrix, isNotNull);
      expect(matrix!.isDark(0, 0), isTrue);
      expect(matrix.isDark(1, 0), isFalse);
      expect(matrix.isDark(1, 1), isTrue);
    });

    test('rejects a truncated or padded module list', () {
      expect(QrMatrix.tryParse({'size': 2, 'modules': '100'}), isNull);
      expect(QrMatrix.tryParse({'size': 2, 'modules': '10011'}), isNull);
    });

    test('rejects missing or unusable fields', () {
      expect(QrMatrix.tryParse({'modules': '1001'}), isNull);
      expect(QrMatrix.tryParse({'size': 0, 'modules': ''}), isNull);
      expect(QrMatrix.tryParse({'size': '2', 'modules': '1001'}), isNull);
    });
  });
}
