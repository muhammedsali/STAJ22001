import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kesinti_ariza_mobile/models/fault_model.dart';
import 'package:kesinti_ariza_mobile/providers/fault_provider.dart';
import 'package:kesinti_ariza_mobile/screens/faults/add_fault_screen.dart';
import 'package:kesinti_ariza_mobile/screens/faults/fault_detail_screen.dart';
import 'package:kesinti_ariza_mobile/screens/faults/notifications_screen.dart';

class HomeTab extends ConsumerWidget {
  final int? currentUserId;
  const HomeTab({super.key, required this.currentUserId});

  Widget _buildFaultCard(BuildContext context, FaultModel fault) {
    Color iconBgColor;
    Color iconColor;
    IconData cardIcon;
    Color badgeBgColor;
    Color badgeTextColor;

    final stat = fault.status.toLowerCase();
    if (stat == 'bekliyor') {
      iconBgColor = const Color(0xFFFFEBEE); // Çok açık kırmızı (Görseldeki gibi)
      iconColor = const Color(0xFFE53935);
      cardIcon = Icons.bolt;
      badgeBgColor = const Color(0xFF1565C0); // Görseldeki mavi rozet
      badgeTextColor = Colors.white;
    } else if (stat == 'çözüldü' || stat == 'tamamlandı') {
      iconBgColor = const Color(0xFFE8F5E9);
      iconColor = const Color(0xFF43A047);
      cardIcon = Icons.check_circle_outline;
      badgeBgColor = const Color(0xFF43A047);
      badgeTextColor = Colors.white;
    } else if (stat == 'iptal') {
      iconBgColor = const Color(0xFFF5F5F5);
      iconColor = const Color(0xFF757575);
      cardIcon = Icons.cancel_outlined;
      badgeBgColor = const Color(0xFFE0E0E0);
      badgeTextColor = Colors.black87;
    } else {
      iconBgColor = const Color(0xFFFFF8E1); 
      iconColor = const Color(0xFFF57F17);
      cardIcon = Icons.engineering_outlined;
      badgeBgColor = const Color(0xFFFFC107); 
      badgeTextColor = Colors.black87;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FaultDetailScreen(fault: fault))),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(16)),
                  child: Icon(cardIcon, color: iconColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              fault.title, 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF15406A)),
                              maxLines: 2, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: badgeBgColor, borderRadius: BorderRadius.circular(12)),
                            child: Text(
                              fault.status.toUpperCase(), 
                              style: TextStyle(color: badgeTextColor, fontWeight: FontWeight.bold, fontSize: 10)
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        fault.description, 
                        maxLines: 2, overflow: TextOverflow.ellipsis, 
                        style: const TextStyle(color: Color(0xFF5E6D7E), fontSize: 13, height: 1.4)
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: Color(0xFF9E9E9E)),
                          const SizedBox(width: 4),
                          Text(
                            "${fault.createdAt.day.toString().padLeft(2, '0')}/${fault.createdAt.month.toString().padLeft(2, '0')}/${fault.createdAt.year}", 
                            style: const TextStyle(fontSize: 12, color: Color(0xFF757575), fontWeight: FontWeight.w500)
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF9E9E9E)),
                          const SizedBox(width: 4),
                          const Text("Haritada Gör", style: TextStyle(fontSize: 12, color: Color(0xFF757575), fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final faultsAsyncValue = ref.watch(faultListProvider);

    Widget buildStatBox(String label, String value, Color color) {
      return Column(
        children: [
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF757575), fontWeight: FontWeight.w600)),
        ],
      );
    }

    return Container(
      color: const Color(0xFFF4F7FB), // Görseldeki çok açık gri/mavi arka plan
      child: SafeArea(
        child: faultsAsyncValue.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Hata: $error')),
          data: (faults) {
            
            final int total = faults.length;
            final int waiting = faults.where((f) => f.status.toLowerCase() == 'bekliyor').length;
            final int inProgress = faults.where((f) => f.status.toLowerCase() == 'islemde' || f.status.toLowerCase() == 'devam ediyor').length;
            final int resolved = faults.where((f) => f.status.toLowerCase() == 'çözüldü' || f.status.toLowerCase() == 'tamamlandı').length;
            
            final double resolvedPercent = total > 0 ? (resolved / total) : 0.0;
            final String percentText = total > 0 ? ((resolved / total) * 100).round().toString() : '0';

            List<FaultModel> activeFaults = faults.where((f) {
              final s = f.status.toLowerCase();
              return s == 'bekliyor' || s == 'islemde' || s == 'devam ediyor';
            }).toList();

            activeFaults.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            final List<FaultModel> recentActiveFaults = activeFaults.take(3).toList();

            return RefreshIndicator(
              onRefresh: () => ref.read(faultListProvider.notifier).refreshList(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    // --- GÖRSELDEKİ ÖZEL TEDAŞ LOGOSU VE ZİL İKONU ---
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 20, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 40), // Ortalama dengesi için boşluk
                          // Özel TEDAŞ Metni
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'TEDAŞ',
                                style: TextStyle(color: Color(0xFF1565C0), fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications, color: Color(0xFF001A41), size: 28),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // 1. HERO KART (Görseldeki gibi Lacivert/Sarı)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E4C93), // Görseldeki lacivert
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF1E4C93).withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Arıza Bildir', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          const Text(
                            'Bölgenizdeki elektrik arızalarını anında bize iletin, ekiplerimizi yönlendirelim.', 
                            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4)
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddFaultScreen())),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFC107), // Görseldeki sarı buton
                              foregroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Hızlı Bildirim', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), 
                                SizedBox(width: 8), 
                                Icon(Icons.arrow_forward, size: 20)
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // 2. DASHBOARD KARTI (Görseldeki gibi kenarları daha oval)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.white, 
                          borderRadius: BorderRadius.circular(20), 
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('SİSTEM GENEL DURUMU', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                buildStatBox('Toplam', total.toString(), const Color(0xFF1565C0)),
                                buildStatBox('Bekleyen', waiting.toString(), const Color(0xFFFFC107)),
                                buildStatBox('İşlemde', inProgress.toString(), const Color(0xFF42A5F5)),
                                buildStatBox('Çözülen', resolved.toString(), const Color(0xFF4CAF50)),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: resolvedPercent,
                                    minHeight: 12, // Görseldeki gibi daha kalın bir bar
                                    backgroundColor: const Color(0xFFEEEEEE),
                                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '%$percentText Çözüm', 
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF424242), fontSize: 14)
                                ),
                                const SizedBox(height: 2),
                                const Text('Tüm zamanlar', style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 3. AKTİF KESİNTİLER BAŞLIĞI VE LİSTESİ
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.warning, color: Color(0xFFD32F2F), size: 22),
                              SizedBox(width: 8),
                              Text('Aktif Kesintiler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF212121))),
                            ],
                          ),
                          if (activeFaults.length > 3)
                            TextButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => AllActiveFaultsScreen(activeFaults: activeFaults)));
                              }, 
                              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                              child: const Text('Tümünü Gör', style: TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.bold))
                            ),
                        ],
                      ),
                    ),
                    
                    if (recentActiveFaults.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24.0), 
                        child: Center(child: Text('Bölgenizde şu an aktif bir arıza bulunmuyor. Harika!', style: TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold)))
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        itemCount: recentActiveFaults.length,
                        itemBuilder: (context, index) {
                          return _buildFaultCard(context, recentActiveFaults[index]);
                        },
                      ),
                      
                    const SizedBox(height: 24), // En alta boşluk
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// YENİ EKRAN: TÜM AKTİF KESİNTİLER SAYFASI (Yenilenen tasarımla uyumlu)
// ---------------------------------------------------------
class AllActiveFaultsScreen extends StatelessWidget {
  final List<FaultModel> activeFaults;
  const AllActiveFaultsScreen({super.key, required this.activeFaults});

  @override
  Widget build(BuildContext context) {
    Widget buildCard(FaultModel fault) {
      Color iconBgColor = fault.status.toLowerCase() == 'bekliyor' ? const Color(0xFFFFEBEE) : const Color(0xFFFFF8E1);
      Color iconColor = fault.status.toLowerCase() == 'bekliyor' ? const Color(0xFFE53935) : const Color(0xFFF57F17);
      IconData cardIcon = fault.status.toLowerCase() == 'bekliyor' ? Icons.bolt : Icons.engineering_outlined;
      Color badgeBgColor = fault.status.toLowerCase() == 'bekliyor' ? const Color(0xFF1565C0) : const Color(0xFFFFC107);
      Color badgeTextColor = fault.status.toLowerCase() == 'bekliyor' ? Colors.white : Colors.black87;

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FaultDetailScreen(fault: fault))),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(16)),
                    child: Icon(cardIcon, color: iconColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(fault.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF15406A)), maxLines: 2, overflow: TextOverflow.ellipsis)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: badgeBgColor, borderRadius: BorderRadius.circular(12)),
                              child: Text(fault.status.toUpperCase(), style: TextStyle(color: badgeTextColor, fontWeight: FontWeight.bold, fontSize: 10)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(fault.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF5E6D7E), fontSize: 13, height: 1.4)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Tüm Aktif Kesintiler'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1565C0),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: activeFaults.length,
        itemBuilder: (context, index) {
          return buildCard(activeFaults[index]);
        },
      ),
    );
  }
}