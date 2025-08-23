// lib/data/services/api_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String _baseUrl =
      'https://yourfitmobile-production.up.railway.app'; // <- OK

  static const storage = FlutterSecureStorage();
  final Dio _dio;

  ApiService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: _baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 20),
            headers: {'Content-Type': 'application/json'},
            validateStatus: (c) => c != null && c < 600,
          ),
        ) {
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ));
    }
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.read(key: 'auth_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (err, handler) async {
        if (err.response?.statusCode == 401) {
          await storage.delete(key: 'auth_token');
        }
        handler.next(err);
      },
    ));
  }

  // ---------- AUTH ----------
  Future<Map<String, dynamic>> signup(Map<String, dynamic> userData) async {
    final res = await _dio.post('/api/auth/register', data: {
      ...userData,
      'email': (userData['email'] as String).trim().toLowerCase(),
    });
    return _handleJson(res);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _dio.post('/api/auth/login', data: {
      'email': email.trim().toLowerCase(),
      'password': password,
    });
    return _handleJson(res);
  }

  Future<bool> checkEmailExists(String email) async {
    final res = await _dio.get('/api/auth/check-email', queryParameters: {
      'email': email.trim().toLowerCase(),
    });
    if (res.statusCode == 200) {
      final d = _asMap(res.data);
      if (d.containsKey('exists')) return d['exists'] == true;
    }
    throw Exception('email-check-failed');
  }

  // ---------- HELPERS ----------
  Future<void> saveToken(String token) async =>
      storage.write(key: 'auth_token', value: token);
  Future<void> clearToken() async => storage.delete(key: 'auth_token');

  Map<String, dynamic> _handleJson(Response res) {
    final data = _asMap(res.data);
    if (res.statusCode != null &&
        res.statusCode! >= 200 &&
        res.statusCode! < 300) {
      return data;
    }
    final msg = data['message'] ??
        data['error'] ??
        'HTTP ${res.statusCode}: ${res.statusMessage ?? 'Unknown error'}';
    switch (res.statusCode) {
      case 400:
        throw Exception('Bad request: $msg');
      case 401:
        throw Exception('Unauthorized');
      case 403:
        throw Exception('Forbidden');
      case 404:
        throw Exception('Not found');
      case 409:
        throw Exception('Conflict: $msg');
      case 422:
        throw Exception('Unprocessable: $msg');
      default:
        if (res.statusCode != null && res.statusCode! >= 500) {
          throw Exception('Server error: $msg');
        }
        throw Exception(msg);
    }
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {'raw': data};
  }
}
