import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'local_storage_service.dart';

class ApiService {
  static ApiService? _instance;
  static ApiService get instance => _instance ??= ApiService._();
  ApiService._();

  static const Duration _requestTimeout = Duration(seconds: 15);

  static String get baseUrl {
    const override = String.fromEnvironment('API_BASE_URL');
    if (override.isNotEmpty) return override;

    if (kIsWeb) return 'http://localhost:3000/api';
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:3000/api';
    return 'http://localhost:3000/api';
  }

  Map<String, String> get _headers {
    final token = LocalStorageService.instance.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String path) async {
    final res = await _withTimeout(() => http.get(Uri.parse('$baseUrl$path'), headers: _headers));
    return _handle(res);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final res = await _withTimeout(() => http.post(
          Uri.parse('$baseUrl$path'),
          headers: _headers,
          body: jsonEncode(body),
        ));
    return _handle(res);
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final res = await _withTimeout(() => http.put(
          Uri.parse('$baseUrl$path'),
          headers: _headers,
          body: jsonEncode(body),
        ));
    return _handle(res);
  }

  Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    final res = await _withTimeout(() => http.patch(
          Uri.parse('$baseUrl$path'),
          headers: _headers,
          body: jsonEncode(body),
        ));
    return _handle(res);
  }

  Future<http.Response> _withTimeout(Future<http.Response> Function() request) async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) {
        throw const ApiException(
          'No internet connection. Please check your network and try again.',
          0,
        );
      }

      return await request().timeout(_requestTimeout);
    } on TimeoutException {
      throw const ApiException(
        'Request timed out. Please check your internet connection and API URL.',
        408,
      );
    } on ApiException {
      rethrow;
    } on http.ClientException catch (e) {
      throw ApiException(
        'Could not connect to server: ${e.message}. Check internet and set API_BASE_URL for real devices.',
        0,
      );
    }
  }

  dynamic _handle(http.Response res) {
    final data = res.body.isNotEmpty ? jsonDecode(res.body) : {};
    if (res.statusCode >= 200 && res.statusCode < 300) return data;
    final msg = (data is Map && data['message'] != null) ? data['message'] : 'Request failed (${res.statusCode})';
    throw ApiException(msg.toString(), res.statusCode);
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  const ApiException(this.message, this.statusCode);
  @override String toString() => message;
}
