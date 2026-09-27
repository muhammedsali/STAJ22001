import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';
import 'auth_provider.dart';

// Repository'i sağlayan provider
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return NotificationRepository(apiClient.dio);
});

// Bildirimlerin durumunu yöneten modern AsyncNotifier
class NotificationNotifier extends AsyncNotifier<List<NotificationModel>> {
  @override
  Future<List<NotificationModel>> build() async {
    return _fetchNotifications();
  }

  Future<List<NotificationModel>> _fetchNotifications() async {
    final repository = ref.read(notificationRepositoryProvider);
    return await repository.getMyNotifications();
  }

  // Bildirimleri yenilemek için (Pull-to-refresh)
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchNotifications());
  }

  // Bildirimi okundu olarak işaretleyip arayüzü anında güncelleyen fonksiyon
  Future<void> markAsRead(int id) async {
    final repository = ref.read(notificationRepositoryProvider);
    final success = await repository.markAsRead(id);
    
    if (success && state.hasValue) {
      final currentList = state.value!;
      state = AsyncValue.data(
        currentList.map((n) {
          if (n.id == id) {
            return NotificationModel(
              id: n.id,
              userId: n.userId,
              title: n.title,
              message: n.message,
              isRead: true,
              createdAt: n.createdAt,
            );
          }
          return n;
        }).toList(),
      );
    }
  }
}

// Arayüzden dinleyeceğimiz ana provider
final notificationProvider = AsyncNotifierProvider<NotificationNotifier, List<NotificationModel>>(() {
  return NotificationNotifier();
});