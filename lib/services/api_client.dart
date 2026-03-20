import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

/// Cliente HTTP para comunicar el frontend Flutter con la API Flask.
/// Usa [ApiConfig.baseUrl] para todas las peticiones.
/// Si hay token ([setAuthToken]), se envía como header Authorization: Bearer.
class ApiClient {
  ApiClient._();

  static final _client = http.Client();
  static String? _authToken;

  static void setAuthToken(String? token) {
    _authToken = token;
  }

  /// True si hay JWT guardado (p. ej. para preferir `GET .../me` frente a `/perfil?email=`).
  static bool get hasAuthToken =>
      _authToken != null && _authToken!.trim().isNotEmpty;

  static Map<String, String> get _headers {
    final h = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null && _authToken!.isNotEmpty) {
      h['Authorization'] = 'Bearer $_authToken';
    }
    return h;
  }

  static String _url(String path) {
    final p = path.startsWith('/') ? path : '/$path';
    return '${ApiConfig.baseUrl}$p';
  }

  /// GET a [path]. Ej: get('/productos')
  static Future<ApiResponse> get(String path) async {
    try {
      final res = await _client
          .get(Uri.parse(_url(path)), headers: _headers)
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));
      return _handleResponse(res);
    } catch (e, st) {
      return ApiResponse.error(e.toString(), stackTrace: st);
    }
  }

  /// POST a [path] con body [data] (se serializa a JSON).
  static Future<ApiResponse> post(String path, [Map<String, dynamic>? data]) async {
    try {
      final body = data != null ? jsonEncode(data) : null;
      final res = await _client
          .post(Uri.parse(_url(path)), headers: _headers, body: body)
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));
      return _handleResponse(res);
    } catch (e, st) {
      return ApiResponse.error(e.toString(), stackTrace: st);
    }
  }

  /// PUT a [path] con body [data].
  static Future<ApiResponse> put(String path, [Map<String, dynamic>? data]) async {
    try {
      final body = data != null ? jsonEncode(data) : null;
      final res = await _client
          .put(Uri.parse(_url(path)), headers: _headers, body: body)
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));
      return _handleResponse(res);
    } catch (e, st) {
      return ApiResponse.error(e.toString(), stackTrace: st);
    }
  }

  /// DELETE a [path].
  static Future<ApiResponse> delete(String path) async {
    try {
      final res = await _client
          .delete(Uri.parse(_url(path)), headers: _headers)
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));
      return _handleResponse(res);
    } catch (e, st) {
      return ApiResponse.error(e.toString(), stackTrace: st);
    }
  }

  static ApiResponse _handleResponse(http.Response res) {
    final ok = res.statusCode >= 200 && res.statusCode < 300;
    dynamic body;
    try {
      body = res.body.isEmpty ? null : jsonDecode(res.body);
    } catch (_) {
      body = res.body;
    }
    if (ok) {
      return ApiResponse.success(res.statusCode, body);
    }
    final String msg = body is Map
        ? (body['message'] ?? body['error'] ?? body['msg'] ?? res.body).toString()
        : res.body;
    return ApiResponse.error(msg, statusCode: res.statusCode, data: body is Map ? body : null);
  }
}

/// Respuesta unificada de la API.
class ApiResponse {
  ApiResponse._({
    this.ok = false,
    this.statusCode,
    this.data,
    this.message,
    this.stackTrace,
  });

  final bool ok;
  final int? statusCode;
  final dynamic data;
  final String? message;
  final StackTrace? stackTrace;

  factory ApiResponse.success(int statusCode, dynamic data) {
    return ApiResponse._(ok: true, statusCode: statusCode, data: data);
  }

  factory ApiResponse.error(String message, {int? statusCode, StackTrace? stackTrace, dynamic data}) {
    return ApiResponse._(
      ok: false,
      statusCode: statusCode,
      message: message,
      stackTrace: stackTrace,
      data: data,
    );
  }
}
