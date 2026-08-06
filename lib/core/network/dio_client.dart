// PayMaye — Dio HTTP Client with full interceptor stack
import 'dart:io';
import 'package:dio/dio.dart';

sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);
}
class NetworkException extends AppException { const NetworkException(super.m); }
class UnauthorizedException extends AppException { const UnauthorizedException() : super('Session expired'); }
class ForbiddenException extends AppException { const ForbiddenException() : super('Insufficient permissions'); }
class NotFoundException extends AppException { const NotFoundException(super.m); }
class ServerException extends AppException {
  final int code;
  const ServerException(super.m, this.code);
}
class ValidationException extends AppException {
  final Map<String, String> fieldErrors;
  const ValidationException(super.m, this.fieldErrors);
}

class ApiClient {
  late final Dio _dio;
  static const _baseUrl = 'https://api.paymaye.app/v1';

  ApiClient({
    required Future<String> Function() getAccessToken,
    required Future<void> Function() onUnauthorized,
  }) {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
    ));

    _dio.interceptors.addAll([
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await getAccessToken();
            options.headers['Authorization'] = 'Bearer $token';
            options.headers['X-Platform'] = Platform.isAndroid ? 'android' : 'ios';
            options.headers['X-App-Version'] = '1.0.0';
          } catch (_) {}
          handler.next(options);
        },
        onError: (err, handler) async {
          if (err.response?.statusCode == 401) await onUnauthorized();
          handler.next(err);
        },
      ),
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (o) => print('[API] $o'),
      ),
    ]);
  }

  Future<T> get<T>(String path, {
    Map<String, dynamic>? params,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final res = await _dio.get(path, queryParameters: params);
      return fromJson(res.data);
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<T> post<T>(String path, {
    required Object data,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final res = await _dio.post(path, data: data);
      return fromJson(res.data);
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  AppException _map(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const NetworkException('No internet connection');
    }
    final code = e.response?.statusCode;
    final body = e.response?.data;
    return switch (code) {
      401 => const UnauthorizedException(),
      403 => const ForbiddenException(),
      404 => NotFoundException(body?['message'] ?? 'Not found'),
      422 => ValidationException(body?['message'] ?? 'Invalid', const {}),
      _ => ServerException(body?['message'] ?? 'Server error', code ?? 0),
    };
  }
}
