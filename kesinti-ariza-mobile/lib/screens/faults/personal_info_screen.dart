import 'package:flutter/material.dart';

class PersonalInfoScreen extends StatelessWidget {
  final String userIdStr;
  final String userRole;
  final String firstName;
  final String lastName;
  final String gsm;

  const PersonalInfoScreen({
    super.key,
    required this.userIdStr,
    required this.userRole,
    required this.firstName,
    required this.lastName,
    required this.gsm,
  });

  @override
  Widget build(BuildContext context) {
    String fullName = "$firstName $lastName".trim();
    if (fullName.isEmpty) fullName = "Kullanıcı";

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
          'Kişisel Bilgiler',
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
                  const CircleAvatar(
                    radius: 48,
                    backgroundColor: Color(0xFFD8E2FF),
                    child: Icon(Icons.person, size: 48, color: Color(0xFF001A41)),
                  ),
                  const SizedBox(height: 12),
                  // Sabit isim yerine dinamik birleşen Ad Soyad
                  Text(
                    fullName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF003A70)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userRole.toUpperCase(),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF717786)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Bilgi Kartı
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
                children: [
                  _buildInfoRow(Icons.badge_outlined, 'Ad', firstName.isEmpty ? '-' : firstName),
                  const Divider(height: 24, color: Color(0xFFE0E3E6)),
                  _buildInfoRow(Icons.badge, 'Soyad', lastName.isEmpty ? '-' : lastName),
                  const Divider(height: 24, color: Color(0xFFE0E3E6)),
                  _buildInfoRow(Icons.phone_android, 'GSM / Telefon', gsm.isEmpty ? '-' : gsm),
                  const Divider(height: 24, color: Color(0xFFE0E3E6)),
                  _buildInfoRow(Icons.fingerprint, 'Kullanıcı ID', '#$userIdStr'),
                  const Divider(height: 24, color: Color(0xFFE0E3E6)),
                  _buildInfoRow(Icons.security, 'Sistem Rolü', userRole),
                  const Divider(height: 24, color: Color(0xFFE0E3E6)),
                  _buildInfoRow(Icons.business, 'Bağlı Kurum', 'TEDAŞ Genel Müdürlüğü'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF0058BC), size: 22),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF717786))),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF191C1E))),
            ],
          ),
        ),
      ],
    );
  }
}