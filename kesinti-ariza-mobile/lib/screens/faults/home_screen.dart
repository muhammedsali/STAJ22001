import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:permission_handler/permission_handler.dart'; 
import 'package:kesinti_ariza_mobile/screens/faults/tabs/home_tab.dart';
import 'package:kesinti_ariza_mobile/screens/faults/tabs/map_tab.dart';
import 'package:kesinti_ariza_mobile/screens/faults/tabs/my_reports_tab.dart';
import 'package:kesinti_ariza_mobile/screens/faults/tabs/profile_tab.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int? _currentUserId;
  int _currentIndex = 0; 

  @override
  void initState() {
    super.initState();
    _getUserIdFromToken();
    _izinleriIsteVeBaslat(); 
  }

  Future<void> _izinleriIsteVeBaslat() async {
    await [
      Permission.location,
      Permission.notification,
    ].request();
  }

  Future<void> _getUserIdFromToken() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt_token');

    if (token != null && !JwtDecoder.isExpired(token)) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      setState(() {
        _currentUserId = int.tryParse(decodedToken['sub'].toString());
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),

      appBar: _currentIndex == 2
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'Bildirimlerim',
                style: TextStyle(
                  color: Color(0xFF1565C0), 
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeTab(currentUserId: _currentUserId),
          MapTab(isActive: _currentIndex == 1),
          MyReportsTab(currentUserId: _currentUserId),
          const ProfileTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: const Color(0xFFFFC107), 
          unselectedItemColor: const Color(0xFF9E9E9E), 
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Ana Sayfa'),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Harita'),
            BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Bildirimlerim'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}