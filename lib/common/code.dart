/// Normalises whatever the user pasted or scanned into a share code.
///
/// The sender's QR encodes croc's web receive URL (`https://getcroc.com/?code=…`)
/// because that is what `croc --qr` shows, so a scanned or pasted value is usually
/// a URL and the share code is its `code` query parameter. Handing the whole URL
/// to croc would make it look for a peer with that exact code instead.
///
/// Anything without a scheme is returned as the first non-empty line, so bare
/// codes — including ones that merely contain a colon — pass through unchanged.
String normalizeShareCode(String raw) {
  final line = raw
      .split('\n')
      .map((l) => l.trim())
      .firstWhere((l) => l.isNotEmpty, orElse: () => '');
  if (line.isEmpty) return line;

  final uri = Uri.tryParse(line);
  if (uri == null || !uri.hasScheme) return line;

  final code = uri.queryParameters['code']?.trim();
  return (code == null || code.isEmpty) ? line : code;
}
