import 'package:dio/dio.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final Dio _dio;

  NotificationRepository(this._dio);

  Future<List<NotificationModel>> getMyNotifications() async {
    try {
      // "/api" kısmı silindi, sadece "/notifications/" kaldı
      final response = await _dio.get('/notifications/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Bildirimler alınamadı: $e');
    }
  }

  Future<bool> markAsRead(int notificationId) async {
    try {
      // "/api" kısmı silindi
      final response = await _dio.put('/notifications/$notificationId/read');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}