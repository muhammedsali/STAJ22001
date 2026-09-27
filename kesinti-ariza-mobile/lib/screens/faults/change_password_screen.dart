import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  int _passwordStrength = 0; 

  // Dinamik kural kontrol değişkenleri
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasDigit = false;

  void _validatePassword(String val) {
    setState(() {
      _hasMinLength = val.length >= 8;
      _hasUppercase = val.contains(RegExp(r'[A-Z]'));
      _hasDigit = val.contains(RegExp(r'[0-9]'));

      if (val.isEmpty) {
        _passwordStrength = 0;
      } else if (val.length < 6) {
        _passwordStrength = 1;
      } else if (val.length < 10) {
        _passwordStrength = 2;
      } else {
        _passwordStrength = 3;
      }
    });
  }

  void _updatePassword() {
    if (_oldPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurun.'), backgroundColor: Colors.red),
      );
      return;
    }

    if (!_hasMinLength || !_hasUppercase || !_hasDigit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yeni şifreniz gereksinimleri karşılamıyor!'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yeni şifreler birbiriyle uyuşmuyor!'), backgroundColor: Colors.red),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Şifreniz başarıyla güncellendi!'), backgroundColor: Colors.green),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
          'Şifre Değiştir',
          style: TextStyle(color: Color(0xFF191C1E), fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD8E2FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_reset, size: 32, color: Color(0xFF001A41)),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Hesabınızın güvenliği için lütfen güçlü bir şifre belirleyin.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF414755), fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Form Kartı
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E3E6)),
                boxShadow: const [
                  BoxShadow(color: Color(0x0D000000), blurRadius: 20, offset: Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mevcut Şifre', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF414755))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _oldPasswordController,
                    obscureText: _obscureOld,
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock, color: Color(0xFF717786)),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureOld ? Icons.visibility : Icons.visibility_off, color: const Color(0xFF717786)),
                        onPressed: () => setState(() => _obscureOld = !_obscureOld),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFE9EDF2),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF0058BC), width: 1.5)),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(color: Color(0xFFE0E3E6)),
                  ),

                  const Text('Yeni Şifre', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF414755))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _newPasswordController,
                    obscureText: _obscureNew,
                    onChanged: _validatePassword,
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.key, color: Color(0xFF717786)),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureNew ? Icons.visibility : Icons.visibility_off, color: const Color(0xFF717786)),
                        onPressed: () => setState(() => _obscureNew = !_obscureNew),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFE9EDF2),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF0058BC), width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Güç Çubukları
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: _passwordStrength >= 1 ? (_passwordStrength == 1 ? Colors.red : const Color(0xFF14B8A6)) : const Color(0xFFE0E3E6),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: _passwordStrength >= 2 ? const Color(0xFF14B8A6) : const Color(0xFFE0E3E6),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: _passwordStrength >= 3 ? const Color(0xFF14B8A6) : const Color(0xFFE0E3E6),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Text('Şifre gücü', style: TextStyle(fontSize: 11, color: Color(0xFF717786), fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text('Yeni Şifre (Tekrar)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF414755))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.password, color: Color(0xFF717786)),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off, color: const Color(0xFF717786)),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFE9EDF2),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF0058BC), width: 1.5)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // DİNAMİK ŞİFRE GEREKSİNİMLERİ KUTUSU
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Şifre Gereksinimleri:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF191C1E))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle, 
                        size: 16, 
                        color: _hasMinLength ? Colors.green : const Color(0xFF717786)
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'En az 8 karakter uzunluğunda olmalı', 
                        style: TextStyle(
                          fontSize: 11, 
                          color: _hasMinLength ? Colors.green.shade700 : const Color(0xFF414755),
                          fontWeight: _hasMinLength ? FontWeight.bold : FontWeight.normal,
                        )
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle, 
                        size: 16, 
                        color: _hasUppercase ? Colors.green : const Color(0xFF717786)
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'En az bir büyük harf içermeli', 
                        style: TextStyle(
                          fontSize: 11, 
                          color: _hasUppercase ? Colors.green.shade700 : const Color(0xFF414755),
                          fontWeight: _hasUppercase ? FontWeight.bold : FontWeight.normal,
                        )
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle, 
                        size: 16, 
                        color: _hasDigit ? Colors.green : const Color(0xFF717786)
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'En az bir rakam içermeli', 
                        style: TextStyle(
                          fontSize: 11, 
                          color: _hasDigit ? Colors.green.shade700 : const Color(0xFF414755),
                          fontWeight: _hasDigit ? FontWeight.bold : FontWeight.normal,
                        )
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Güncelle Butonu
            SizedBox(
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0058BC),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
                onPressed: _updatePassword,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Şifreyi Güncelle', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Icon(Icons.check_circle, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}