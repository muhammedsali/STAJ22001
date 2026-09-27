import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kesinti_ariza_mobile/providers/notification_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Provider'ı dinleyerek verileri alıyoruz (Yükleniyor, Hata veya Veri durumu)
    final notificationsAsync = ref.watch(notificationProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0058BC)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Bildirimler',
          style: TextStyle(color: Color(0xFF191C1E), fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return _buildEmptyState();
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(notificationProvider.notifier).refresh(),
            color: const Color(0xFF003A70),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFE0E3E6)),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                
                // Tarihi "GG.AA.YYYY HH:MM" formatına çeviriyoruz
                final date = notification.createdAt;
                final formattedDate = "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  // Okunmamış bildirimlere açık mavi bir arka plan veriyoruz
                  tileColor: notification.isRead ? Colors.white : const Color(0xFFE8F0FE),
                  leading: CircleAvatar(
                    backgroundColor: notification.isRead ? const Color(0xFFF0F0F0) : const Color(0xFFD8E2FF),
                    child: Icon(
                      notification.isRead ? Icons.notifications_none : Icons.notifications_active,
                      color: notification.isRead ? Colors.grey : const Color(0xFF003A70),
                    ),
                  ),
                  title: Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                      color: const Color(0xFF191C1E),
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(
                        notification.message,
                        style: const TextStyle(color: Color(0xFF4A4A4A), fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formattedDate,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF717786)),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Tıklanınca eğer okunmamışsa, okundu olarak işaretle
                    if (!notification.isRead) {
                      ref.read(notificationProvider.notifier).markAsRead(notification.id);
                    }
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF003A70)),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text('Bildirimler yüklenirken hata oluştu', style: TextStyle(fontSize: 16)),
              TextButton(
                onPressed: () => ref.read(notificationProvider.notifier).refresh(),
                child: const Text('Tekrar Dene'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'Henüz bir bildiriminiz yok.',
            style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}