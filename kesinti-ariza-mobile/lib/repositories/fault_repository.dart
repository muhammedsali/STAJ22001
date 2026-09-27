import 'package:dio/dio.dart';
import '../core/config.dart';
import '../models/fault_model.dart';

class FaultRepository {
  final Dio _dio;

  // Dışarıdan yetkilendirilmiş (Interceptor'lı) Dio kuryemizi alıyoruz
  FaultRepository(this._dio);

  /// Backend'den tüm arıza kayıtlarını liste olarak çeker
  Future<List<FaultModel>> getFaults() async {
    try {
      // Backend'deki endpoint'inin tam adı neyse ona göre düzeltmelisin (Örn: /api/faults veya /faults/)
      final response = await _dio.get('${Config.baseUrl}/faults/');
      
      if (response.statusCode == 200) {
        // Gelen yanıt bir liste (Array) olduğu için, her bir elemanı FaultModel'e çevirip listeye ekliyoruz
        final List<dynamic> data = response.data;
        return data.map((json) => FaultModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      final errorMessage = e.response?.data['detail'] ?? 'Arızalar yüklenirken bir bağlantı hatası oluştu.';
      throw Exception(errorMessage);
    }
  }

  /// Yeni bir arıza bildirimi oluşturur (POST)
  Future<bool> createFault(String title, String description, double latitude, double longitude) async {
    try {
      final response = await _dio.post(
        '${Config.baseUrl}/faults/', 
        data: {
          'title': title,
          'description': description,
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      // Başarılı yaratılma durumu (200 OK veya 201 Created)
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      final errorMessage = e.response?.data['detail'] ?? 'Arıza bildirimi gönderilemedi.';
      throw Exception(errorMessage);
    }
  }

/// Belirtilen ID'ye sahip arızayı siler (DELETE)
  Future<bool> deleteFault(int id) async {
    try {
      final response = await _dio.delete('${Config.baseUrl}/faults/$id');

      // Silme işlemi genelde 200 (OK) veya 204 (No Content) döner
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      final errorMessage = e.response?.data['detail'] ?? 'Arıza silinirken bir hata oluştu.';
      throw Exception(errorMessage);
    }
  }

  /// Mevcut bir arızayı günceller (PUT)
  Future<bool> updateFault(int id, String title, String description, String status) async {
    try {
      // Backend'deki PUT /faults/{id} adresine değişecek verileri yolluyoruz
      final response = await _dio.put(
        '${Config.baseUrl}/faults/$id',
        data: {
          'title': title,
          'description': description,
          'status': status, // YENİ: Seçilen durum bilgisi de artık backend'e gidiyor!
        },
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      final errorMessage = e.response?.data['detail'] ?? 'Arıza güncellenirken bir hata oluştu.';
      throw Exception(errorMessage);
    }
  }
}