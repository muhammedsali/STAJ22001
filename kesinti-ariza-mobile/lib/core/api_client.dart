import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kesinti_ariza_mobile/core/config.dart';

class ApiClient {
  late final Dio dio;
  final FlutterSecureStorage _storage;

  ApiClient(this._storage) {
    dio = Dio(
      BaseOptions(
        baseUrl: Config.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          
          final token = await _storage.read(key: 'jwt_token');
          
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          return handler.next(options);
        },
      ),
    );
  }
}