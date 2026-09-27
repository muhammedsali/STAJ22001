import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kesinti_ariza_mobile/core/api_client.dart';
import 'package:kesinti_ariza_mobile/repositories/auth_repository.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) => const FlutterSecureStorage());
final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(storage);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepository(apiClient.dio, storage);
});

class AuthNotifier extends Notifier<bool> {
  
  @override
  bool build() {
    checkToken(); 
    return false;
  }
  Future<void> checkToken() async {
    final repository = ref.read(authRepositoryProvider);
    final token = await repository.getToken();
    if (token != null) {
      state = true; 
    }
  }
  Future<void> login(String identifier, String password) async {
    final repository = ref.read(authRepositoryProvider);
    try {
      final success = await repository.login(identifier, password);
      if (success) {
        state = true;
      }
    } catch (e) {
      state = false;
      rethrow;
    }
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String gsm,
    required String email,
    required String password,
    required String role,
  }) async {
    final repository = ref.read(authRepositoryProvider);
    try {
      await repository.register(
        firstName: firstName,
        lastName: lastName,
        gsm: gsm,
        email: email,
        password: password,
        role: role,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.logout();
    state = false;
  }
}

final authStateProvider = NotifierProvider<AuthNotifier, bool>(() {
  return AuthNotifier();
});