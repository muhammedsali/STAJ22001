import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fault_model.dart';
import '../repositories/fault_repository.dart';
import 'auth_provider.dart'; // apiClientProvider'ı kullanabilmek için

// 1. FaultRepository'yi sağlayan Provider
final faultRepositoryProvider = Provider<FaultRepository>((ref) {
  // İçinde Token basma özelliği (Interceptor) olan ApiClient'ı alıyoruz
  final apiClient = ref.watch(apiClientProvider);
  return FaultRepository(apiClient.dio);
});

// 2. Arıza Listesini asenkron (internet üzerinden) yöneten Notifier
class FaultListNotifier extends AsyncNotifier<List<FaultModel>> {
  
  @override
  Future<List<FaultModel>> build() async {
    // Ekran ilk açıldığında otomatik olarak verileri çeker
    return _fetchFaults();
  }

  Future<List<FaultModel>> _fetchFaults() async {
    final repository = ref.read(faultRepositoryProvider);
    return await repository.getFaults();
  }

  // İleride POST (Yeni Arıza Ekleme) işlemi yaptığımızda listeyi yenilemek için kullanacağız
  Future<void> refreshList() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchFaults());
  }

  // YENİ EKLENEN KISIM: Arıza Bildirimi (POST)
  /// Yeni arıza ekler ve başarılı olursa listeyi otomatik yeniler
  Future<void> createFault(String title, String description, double latitude, double longitude) async {
    final repository = ref.read(faultRepositoryProvider);
    try {
      final success = await repository.createFault(title, description, latitude, longitude);
      
      // Veritabanına başarıyla kaydedildiyse, listeyi baştan çekerek Ana Ekranı güncelliyoruz
      if (success) {
        await refreshList();
      }
    } catch (e) {
      // Hatayı UI tarafında yakalamak için fırlatıyoruz
      rethrow;
    }
  }

  // SİLME İŞLEMİ DE ARTIK SINIFIN İÇİNDE!
  /// Arızayı siler ve başarılı olursa listeyi günceller
  Future<void> deleteFault(int id) async {
    final repository = ref.read(faultRepositoryProvider);
    try {
      final success = await repository.deleteFault(id);
      
      // Silme başarılıysa listeyi yenile
      if (success) {
        await refreshList();
      }
    } catch (e) {
      rethrow;
    }
  }

/// Arızayı günceller ve başarılı olursa listeyi yeniler
  Future<void> updateFault(int id, String title, String description, String status) async {
    final repository = ref.read(faultRepositoryProvider);
    try {
      final success = await repository.updateFault(id, title, description, status);
      
      // Güncelleme başarılıysa listeyi yenile
      if (success) {
        await refreshList();
      }
    } catch (e) {
      rethrow;
    }
  }

} // Sınıfı kapatan asıl parantez artık en altta!

// UI tarafında dinleyeceğimiz ana sağlayıcı
final faultListProvider = AsyncNotifierProvider<FaultListNotifier, List<FaultModel>>(() {
  return FaultListNotifier();
});