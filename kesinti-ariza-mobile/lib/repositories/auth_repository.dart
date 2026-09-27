import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/config.dart';

class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthRepository(this._dio, this._storage);

  Future<bool> login(String identifier, String password) async {
    try {
      final response = await _dio.post(
        '${Config.authUrl}/login', 
        data: FormData.fromMap({
          'username': identifier, // E-posta veya GSM
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final String token = response.data['access_token'] ?? response.data['token'];
        await _storage.write(key: 'jwt_token', value: token);
        return true;
      }
      return false;
    } on DioException catch (e) {
      String errorMessage = 'Giriş yapılamadı, bağlantıyı kontrol edin.';
      
      if (e.response != null && e.response?.data != null) {
        if (e.response?.data is Map) {
          errorMessage = e.response?.data['detail'] ?? errorMessage;
        } else {
          errorMessage = 'Sunucu Hatası (${e.response?.statusCode}): Arka plan çöktü.';
        }
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Beklenmedik bir hata oluştu.');
    }
  }

  // GÜNCELLENDİ: Artık full_name yerine firstName, lastName ve gsm gönderiyoruz
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String gsm,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _dio.post(
        '${Config.authUrl}/register', 
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'gsm': gsm,
          'email': email,
          'password': password,
          'role': role, 
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      String errorMessage = 'Kayıt işlemi başarısız oldu.';
      if (e.response != null && e.response?.data != null && e.response?.data is Map) {
         errorMessage = e.response?.data['detail'] ?? errorMessage;
      }
      throw Exception(errorMessage);
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }
}