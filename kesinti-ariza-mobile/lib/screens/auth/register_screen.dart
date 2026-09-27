import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kesinti_ariza_mobile/providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _gsmController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String _selectedRole = 'vatandas'; 
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _gsmController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _kullaniciKaydi() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final gsm = _gsmController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || gsm.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurun.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authStateProvider.notifier).register(
        firstName: firstName,
        lastName: lastName,
        gsm: gsm,
        email: email,
        password: password,
        role: _selectedRole,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kayıt Başarılı! Giriş yapabilirsiniz.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Kayıt Oluştur'),
        centerTitle: true,
      ),
      body: SingleChildScrollView( 
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.person_add_alt_1, size: 80, color: Color(0xFF00529B)),
            const SizedBox(height: 32),

            // Ad Alanı
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'Ad',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 16),

            // Soyad Alanı
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Soyad',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 16),

            // GSM / Telefon Alanı
            TextField(
              controller: _gsmController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'GSM Numarası',
                hintText: '5XXXXXXXXX',
                prefixIcon: Icon(Icons.phone_android),
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 16),

            // E-posta Alanı
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-posta Adresi',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Şifre Alanı
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Şifre',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 16),

            // Rol Seçim Alanı
            DropdownButtonFormField<String>(
              initialValue: _selectedRole, // Güncellendi
              decoration: const InputDecoration(
                labelText: 'Kullanıcı Rolü',
                prefixIcon: Icon(Icons.badge_outlined),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'vatandas', child: Text('Vatandaş (Normal Kullanıcı)')),
                DropdownMenuItem(value: 'saha_ekibi', child: Text('Saha Ekibi / Yetkili Personel')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedRole = value;
                  });
                }
              },
            ),
            
            const SizedBox(height: 32),
            
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _kullaniciKaydi,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00529B),
                  foregroundColor: Colors.white,
                ),
                child: _isLoading 
                  ? const SizedBox(
                      width: 24, 
                      height: 24, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : const Text('Kayıt Ol', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}