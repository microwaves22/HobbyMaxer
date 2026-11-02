import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Default base URL of the HomeSync FastAPI backend.
///
/// Android emulators cannot reach the host's loopback: point them at
/// `http://10.0.2.2:8000` instead.
const String kDefaultBaseUrl = 'http://localhost:8000';

/// Thrown for transport failures and non-2xx backend responses.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Thin JSON HTTP client with automatic `Authorization: Bearer` injection.
///
/// Pass an `http.Client` (e.g. `MockClient`) to test without a server.
class ApiClient {
  ApiClient({
    http.Client? inner,
    this.baseUrl = kDefaultBaseUrl,
    this.tokenProvider,
  }) : _inner = inner ?? http.Client();

  final http.Client _inner;
  final String baseUrl;

  /// Read per request, so sessions can rotate tokens without rebuilding.
  String? Function()? tokenProvider;

  static const _timeout = Duration(seconds: 15);

  Map<String, String> _headers() {
    final headers = <String, String>{'Content-Type': 'application/json'};
    final token = tokenProvider?.call();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  dynamic _decode(http.Response response) {
    if (response.body.isEmpty) return null;
    try {
      return jsonDecode(response.body);
    } catch (_) {
      return response.body;
    }
  }

  Never _throwStatus(http.Response response) {
    var message = 'Request failed (${response.statusCode}).';
    final body = _decode(response);
    if (body is Map && body['detail'] != null) {
      message = body['detail'].toString();
    }
    throw ApiException(message, statusCode: response.statusCode);
  }

  Future<dynamic> _send(Future<http.Response> Function() call) async {
    late final http.Response response;
    try {
      response = await call();
    } on SocketException {
      throw ApiException('Could not reach the server at $baseUrl.');
    } on TimeoutException {
      throw ApiException('The server took too long to respond.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwStatus(response);
    }
    return _decode(response);
  }

  Future<dynamic> get(String path) {
    return _send(
      () => _inner
          .get(Uri.parse('$baseUrl$path'), headers: _headers())
          .timeout(_timeout),
    );
  }

  Future<dynamic> post(String path, {Object? body}) {
    return _send(
      () => _inner
          .post(
            Uri.parse('$baseUrl$path'),
            headers: _headers(),
            body: body == null ? null : jsonEncode(body),
          )
          .timeout(_timeout),
    );
  }

  Future<dynamic> put(String path, {Object? body}) {
    return _send(
      () => _inner
          .put(
            Uri.parse('$baseUrl$path'),
            headers: _headers(),
            body: body == null ? null : jsonEncode(body),
          )
          .timeout(_timeout),
    );
  }

  /// Form-encoded POST (for the OAuth2 login endpoint).
  Future<dynamic> postForm(String path, Map<String, String> fields) {
    final headers = _headers()..remove('Content-Type');
    return _send(
      () => _inner
          .post(Uri.parse('$baseUrl$path'), headers: headers, body: fields)
          .timeout(_timeout),
    );
  }

  /// Multipart POST with one optional file (for photo submissions).
  Future<dynamic> postMultipart(
    String path, {
    Map<String, String>? fields,
    String? fileField,
    String? filePath,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$path'));
    final token = tokenProvider?.call();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    if (fields != null) request.fields.addAll(fields);
    if (fileField != null && filePath != null) {
      request.files.add(await http.MultipartFile.fromPath(fileField, filePath));
    }
    return _send(() async {
      final streamed = await _inner.send(request).timeout(_timeout);
      return http.Response.fromStream(streamed);
    });
  }

  void close() => _inner.close();
}
