import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:kesinti_ariza_mobile/providers/auth_provider.dart';
import 'package:kesinti_ariza_mobile/screens/faults/home_screen.dart';
import 'package:kesinti_ariza_mobile/screens/auth/register_screen.dart'; 

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Değişken adını daha genel yaptım (email veya gsm olabilir)
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false; 

  @override
  void initState() {
    super.initState();
    _izinleriIste();
  }

  Future<void> _izinleriIste() async {
    await [
      Permission.location,
      Permission.notification,
    ].request();
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _kullaniciGirisi() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen e-posta/GSM ve şifrenizi girin.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Auth provider'daki login fonksiyonuna eposta/gsm bilgisini gönderiyoruz
      await ref.read(authStateProvider.notifier).login(identifier, password);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Giriş Başarılı!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
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
        title: const Text('Kesinti ve Arıza Takip'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.bolt, size: 80, color: Color(0xFF00529B)),
            const SizedBox(height: 32),

            // E-posta veya GSM Giriş Alanı
            TextField(
              controller: _identifierController,
              keyboardType: TextInputType.text, // Hem e-posta hem telefon için esnek klavye
              decoration: const InputDecoration(
                labelText: 'E-posta veya GSM Numarası',
                hintText: 'ornek@email.com veya 5XXXXXXXXX',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Şifre',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 32),
            
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _kullaniciGirisi,
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
                  : const Text('Giriş Yap', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            
            const SizedBox(height: 16), 
            
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                );
              },
              child: const Text('Hesabın yok mu? Hemen Kayıt Ol'),
            ),
          ],
        ),
      ),
    );
  }
}