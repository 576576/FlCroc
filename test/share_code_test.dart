// The sender's QR encodes croc's web receive URL (`https://getcroc.com/?code=…`),
// so a scanned or pasted share code usually arrives as a URL. Handing that whole
// URL to croc would make it look for a peer with that exact code, so every entry
// point runs it through normalizeShareCode() first.
import 'package:fl_croc/common/code.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeShareCode', () {
    test('extracts the code from the web receive URL', () {
      expect(
        normalizeShareCode('https://getcroc.com/?code=bold-cat-1234'),
        'bold-cat-1234',
      );
    });

    test('accepts any host and decodes the parameter', () {
      expect(
        normalizeShareCode('https://other.example/?code=a%2Fb%20c'),
        'a/b c',
      );
    });

    test('passes bare codes through, including ones containing a colon', () {
      expect(normalizeShareCode('  bold-cat-1234 '), 'bold-cat-1234');
      // Uri parses this as scheme "192.168.1.1"; it is still a share code.
      expect(normalizeShareCode('192.168.1.1:9009'), '192.168.1.1:9009');
    });

    test('uses the first non-empty line, so a multi-line clipboard works', () {
      expect(
        normalizeShareCode('\n https://getcroc.com/?code=x7-aa \n trailing'),
        'x7-aa',
      );
    });

    test('keeps a URL without a code parameter as-is', () {
      expect(
        normalizeShareCode('https://example.com/other'),
        'https://example.com/other',
      );
    });

    test('blank input stays blank', () {
      expect(normalizeShareCode('   \n  '), '');
      expect(normalizeShareCode(''), '');
    });
  });
}
