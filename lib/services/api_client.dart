import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../api_config.dart';

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final String? code;

  const ApiException(this.message, {this.statusCode = 0, this.code});

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client}) : _http = client ?? http.Client();

  static final ApiClient shared = ApiClient();
  static const _tokenKey = 'tawaf_api_token';

  final http.Client _http;
  String? _token;
  bool _loadedToken = false;

  bool get hasToken => _token != null && _token!.isNotEmpty;

  Future<void> _ensureToken() async {
    if (_loadedToken) return;
    _loadedToken = true;
    try {
      final preferences = await SharedPreferences.getInstance();
      _token = preferences.getString(_tokenKey);
    } catch (_) {
      _token = null;
    }
  }

  Future<void> setToken(String? value) async {
    _loadedToken = true;
    _token = value;
    try {
      final preferences = await SharedPreferences.getInstance();
      if (value == null || value.isEmpty) {
        await preferences.remove(_tokenKey);
      } else {
        await preferences.setString(_tokenKey, value);
      }
    } catch (_) {}
  }

  Uri _uri(String route, [Map<String, dynamic>? query]) {
    final params = <String, String>{'route': route};
    query?.forEach((key, value) {
      if (value != null) params[key] = value.toString();
    });
    return Uri.parse(ApiConfig.baseUrl).replace(queryParameters: params);
  }

  Future<dynamic> get(String route, {Map<String, dynamic>? query}) =>
      _request('GET', route, query: query);

  Future<dynamic> post(String route, {Map<String, dynamic>? body}) =>
      _request('POST', route, body: body);

  Future<dynamic> patch(String route, {Map<String, dynamic>? body}) =>
      _request('PATCH', route, body: body);

  Future<dynamic> delete(String route, {Map<String, dynamic>? body}) =>
      _request('DELETE', route, body: body);

  Future<dynamic> _request(
    String method,
    String route, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
  }) async {
    await _ensureToken();
    final request = http.Request(method, _uri(route, query));
    request.headers['Accept'] = 'application/json';
    if (_token != null) request.headers['Authorization'] = 'Bearer $_token';
    if (body != null) {
      request.headers['Content-Type'] = 'application/json; charset=UTF-8';
      request.body = jsonEncode(body);
    }
    try {
      final streamed = await _http
          .send(request)
          .timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamed);
      return _decode(response);
    } on TimeoutException {
      throw const ApiException(
        'The server took too long to respond. Please try again.',
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        'Unable to reach the Tawaf server. Check your internet connection.',
      );
    }
  }

  Future<dynamic> multipart(
    String route, {
    required Map<String, String> fields,
    required Map<String, Uint8List> files,
    Map<String, String>? fileNames,
  }) async {
    await _ensureToken();
    final request = http.MultipartRequest('POST', _uri(route));
    request.headers['Accept'] = 'application/json';
    if (_token != null) request.headers['Authorization'] = 'Bearer $_token';
    request.fields.addAll(fields);
    for (final entry in files.entries) {
      request.files.add(
        http.MultipartFile.fromBytes(
          entry.key,
          entry.value,
          filename: fileNames?[entry.key] ?? '${entry.key}.jpg',
        ),
      );
    }
    try {
      final streamed = await request.send().timeout(
        const Duration(seconds: 60),
      );
      final response = await http.Response.fromStream(streamed);
      return _decode(response);
    } on TimeoutException {
      throw const ApiException('The upload took too long. Please try again.');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        'Unable to upload the file to the Tawaf server.',
      );
    }
  }

  dynamic _decode(http.Response response) {
    Map<String, dynamic>? payload;
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) payload = decoded;
    } catch (_) {}

    if (response.statusCode == 401) {
      setToken(null);
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = payload?['error'];
      final message = error is Map
          ? (error['message']?.toString() ?? 'The request failed.')
          : 'The server returned an error (${response.statusCode}).';
      final code = error is Map ? error['code']?.toString() : null;
      throw ApiException(message, statusCode: response.statusCode, code: code);
    }
    if (payload == null) {
      throw const ApiException('The server returned an invalid response.');
    }
    if (payload['success'] != true) {
      final error = payload['error'];
      throw ApiException(
        error is Map
            ? (error['message']?.toString() ?? 'The request failed.')
            : 'The request failed.',
      );
    }
    return payload['data'];
  }
}
