import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart'; // YENİ: Yerel hafıza için eklendi
import 'package:kesinti_ariza_mobile/providers/auth_provider.dart';
import 'package:kesinti_ariza_mobile/screens/auth/login_screen.dart';
import 'package:kesinti_ariza_mobile/screens/faults/change_password_screen.dart';
import 'package:kesinti_ariza_mobile/screens/faults/personal_info_screen.dart'; 

class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> {
  bool _notificationsEnabled = true;
  String _userRole = 'Yükleniyor...';
  String _userIdStr = '-';
  String _firstName = '';
  String _lastName = '';
  String _gsm = '';

  @override
  void initState() {
    super.initState();
    _getUserInfoFromToken();
    _loadNotificationPreference(); // Hafızadaki tercihi yükle
  }

  // Kullanıcının bildirim tercihini yerel hafızadan okuma
  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  // Bildirim tercihini değiştirip kaydetme
  Future<void> _toggleNotifications(bool value) async {
    setState(() {
      _notificationsEnabled = value;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value ? 'Bildirimler açıldı.' : 'Bildirimler kapatıldı.',
          ),
          backgroundColor: value ? const Color(0xFF1565C0) : Colors.grey.shade800,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _getUserInfoFromToken() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt_token');

    if (token != null && !JwtDecoder.isExpired(token)) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      setState(() {
        _userIdStr = decodedToken['sub']?.toString() ?? '-';
        _firstName = decodedToken['first_name']?.toString() ?? '';
        _lastName = decodedToken['last_name']?.toString() ?? '';
        _gsm = decodedToken['gsm']?.toString() ?? 'Belirtilmemiş';

        String rawRole = decodedToken['role']?.toString() ?? 'Vatandaş';
        if (rawRole == 'saha_ekibi') rawRole = 'Saha Ekibi';
        if (rawRole == 'yonetici') rawRole = 'Yönetici';
        
        _userRole = rawRole;
      });
    }
  }

  void _cikisYapOnayi() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
            Text('Çıkış Yap'),
          ],
        ),
        content: const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hayır', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authStateProvider.notifier).logout();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
            child: const Text('Evet, Çıkış Yap'),
          ),
        ],
      ),
    );
  }

  void _navigateToPersonalInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonalInfoScreen(
          userIdStr: _userIdStr,
          userRole: _userRole,
          firstName: _firstName,
          lastName: _lastName,
          gsm: _gsm,
        ),
      ),
    );
  }

  void _showHelpCenter() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_center, color: Color(0xFF003A70)),
            SizedBox(width: 8),
            Text('Yardım Merkezi'),
          ],
        ),
        content: const Text(
          'Bu uygulama TEDAŞ Elektrik Arıza ve Kesinti Takip sistemi için geliştirilmiştir.\n\n'
          '• Arıza bildirmek için Ana Sayfa’daki "Hızlı Bildirim" butonunu kullanabilirsiniz.\n'
          '• Harita sekmesinden bölgenizdeki diğer arızaları inceleyebilirsiniz.',
          style: TextStyle(height: 1.4),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Anladım', style: TextStyle(color: Color(0xFF003A70), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showContactUs() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.support_agent, color: Color(0xFF003A70)),
            SizedBox(width: 8),
            Text('Bize Ulaşın'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📞 Çağrı Merkezi: 186', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('✉️ E-posta: destek@tedas.gov.tr', style: TextStyle(fontSize: 15)),
            SizedBox(height: 8),
            Text('🌐 Web: www.tedas.gov.tr', style: TextStyle(fontSize: 15)),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Kapat', style: TextStyle(color: Color(0xFF003A70), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade600, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
              ),
            ),
            if (trailing != null) 
              trailing 
            else 
              const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 6.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String fullName = "$_firstName $_lastName".trim();
    if (fullName.isEmpty) fullName = "Kullanıcı";

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                const CircleAvatar(
                  radius: 46,
                  backgroundColor: Color(0xFFE0E3E6),
                  backgroundImage: NetworkImage('https://cdn-icons-png.flaticon.com/512/3135/3135715.png'),
                ),
                const SizedBox(height: 12),
                Text(
                  fullName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF003A70)),
                ),
                const SizedBox(height: 2),
                Text(
                  _userRole,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),

            const SizedBox(height: 10),
            _buildSectionHeader('HESAP AYARLARI'),
            _buildMenuItem(icon: Icons.badge_outlined, title: 'Kişisel Bilgiler', onTap: _navigateToPersonalInfo),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            _buildMenuItem(
              icon: Icons.lock_outline, 
              title: 'Şifre Değiştir', 
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                );
              },
            ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),

            _buildSectionHeader('TERCİHLER'),
            _buildMenuItem(
              icon: Icons.notifications_none,
              title: 'Bildirim Ayarları',
              trailing: Switch.adaptive(
                value: _notificationsEnabled,
                activeTrackColor: const Color(0xFF003A70),
                onChanged: _toggleNotifications, // Bağlantı sağlandı
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),

            _buildSectionHeader('DESTEK'),
            _buildMenuItem(icon: Icons.help_outline, title: 'Yardım Merkezi', onTap: _showHelpCenter),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            _buildMenuItem(icon: Icons.support_agent, title: 'Bize Ulaşın', onTap: _showContactUs),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _cikisYapOnayi,
                icon: const Icon(Icons.logout, color: Colors.red, size: 20),
                label: const Text(
                  'Çıkış Yap', 
                  style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFEBEE), 
                  foregroundColor: Colors.red,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.red.shade200, width: 1),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}