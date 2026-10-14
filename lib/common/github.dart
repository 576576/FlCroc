import 'dart:convert';
import 'dart:io';

/// 该仓库的稳定版最新发布（`GET /releases/latest`），取不到时返回 null。
Future<Map<String, dynamic>?> fetchLatestRelease(String repository) async {
  final decoded = await _getJson(repository, '/releases/latest');
  return decoded is Map<String, dynamic> ? decoded : null;
}

/// 该仓库最新的预发布，没有或取不到时返回 null。
///
/// nightly 的 tag 每次构建都是新号（`r<1000+提交数>`），只能取列表里最新的那条。
Future<Map<String, dynamic>?> fetchLatestPrerelease(String repository) async {
  final decoded = await _getJson(repository, '/releases', {'per_page': '10'});
  if (decoded is! List) return null;
  for (final item in decoded) {
    if (item is! Map<String, dynamic>) continue;
    if (item['draft'] == true) continue;
    if (item['prerelease'] == true) return item;
  }
  return null;
}

Future<dynamic> _getJson(
  String repository,
  String path, [
  Map<String, dynamic>? query,
]) async {
  final client = HttpClient();
  try {
    final uri = Uri.https('api.github.com', '/repos/$repository$path', query);
    final request = await client.getUrl(uri);
    request.headers.set('User-Agent', 'FlCroc');
    request.headers.set('Accept', 'application/vnd.github+json');
    final response = await request.close();
    if (response.statusCode != 200) return null;
    final body = await response.transform(utf8.decoder).join();
    return jsonDecode(body);
  } catch (_) {
    return null;
  } finally {
    client.close();
  }
}
