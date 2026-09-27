import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:kesinti_ariza_mobile/models/fault_model.dart';
import 'package:kesinti_ariza_mobile/providers/fault_provider.dart';
import 'package:kesinti_ariza_mobile/screens/faults/edit_fault_screen.dart';

class FaultDetailScreen extends ConsumerStatefulWidget {
  final FaultModel fault;

  const FaultDetailScreen({super.key, required this.fault});

  @override
  ConsumerState<FaultDetailScreen> createState() => _FaultDetailScreenState();
}

class _FaultDetailScreenState extends ConsumerState<FaultDetailScreen> {
  int? _currentUserId;
  String? _currentUserRole;
  bool _isLoadingUser = true;
  
  String _address = "Adres çözümleniyor...";
  final Geocoding _geocoding = Geocoding();

  late String _selectedStatus;
  bool _isUpdatingStatus = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.fault.status;
    _getCurrentUserInfo();
    _resolveAddress();
  }

  Future<void> _getCurrentUserInfo() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt_token');

    if (token != null && !JwtDecoder.isExpired(token)) {
      final decoded = JwtDecoder.decode(token);
      setState(() {
        _currentUserId = int.tryParse(decoded['sub'].toString());
        _currentUserRole = decoded['role']?.toString().toLowerCase() ?? 'vatandas';
        _isLoadingUser = false;
      });
    } else {
      setState(() {
        _isLoadingUser = false;
      });
    }
  }

  Future<void> _resolveAddress() async {
    try {
      List<Placemark> placemarks = await _geocoding.placemarkFromCoordinates(
        widget.fault.latitude,
        widget.fault.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _address = '${place.street}, ${place.subLocality}, ${place.locality} / ${place.administrativeArea}';
          _address = _address.replaceAll('null, ', '').replaceAll(', null', '');
        });
      }
    } catch (e) {
      setState(() => _address = 'Adres çözümlenemedi (Koordinat kullanılıyor)');
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'bekliyor':
        return Colors.orange;
      case 'islemde':
      case 'devam ediyor':
        return Colors.blue;
      case 'çözüldü':
      case 'tamamlandı':
        return Colors.green;
      case 'iptal':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

Future<void> _durumuGuncelle() async {
    setState(() => _isUpdatingStatus = true);
    try {
      // Projedeki metodun 3 parametre (id, title, description) veya nesne aldığını varsayarak 
      // durum güncellemesini EditFaultScreen'deki mantıkla veya doğrudan repository ile uyumlu hale getiriyoruz.
      // Eğer projenizde updateFaultStatus yoksa, FaultProvider içindeki update fonksiyonunuza uygun argümanı veriyoruz:
      await ref.read(faultListProvider.notifier).updateFault(
        widget.fault.id, 
        widget.fault.title, 
        widget.fault.description,
        _selectedStatus
         // Üçüncü argüman olarak durumu gönderiyoruz (veya projenizin imza gereksinimi neyse)
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Arıza durumu başarıyla güncellendi!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingStatus = false);
    }
  }

  void _silOnayDiyalogu(BuildContext context, int faultId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Arıza Kaydını Sil'),
        content: const Text('Bu arıza kaydını silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(faultListProvider.notifier).deleteFault(faultId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Arıza başarıyla silindi!'), backgroundColor: Colors.green),
                  );
                  Navigator.pop(context); 
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isOwner = _currentUserId != null && _currentUserId == widget.fault.userId;
    final bool isStaff = _currentUserRole == 'saha_ekibi' || _currentUserRole == 'yonetici' || _currentUserRole == 'admin';
    final dateStr = "${widget.fault.createdAt.day.toString().padLeft(2, '0')}/${widget.fault.createdAt.month.toString().padLeft(2, '0')}/${widget.fault.createdAt.year}";

    final String initialDropdownValue = ['bekliyor', 'islemde', 'tamamlandı', 'iptal'].contains(_selectedStatus.toLowerCase()) 
        ? _selectedStatus.toLowerCase() 
        : 'bekliyor';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Arıza Detayı'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF003A70),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 250,
                    width: double.infinity,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(widget.fault.latitude, widget.fault.longitude),
                        initialZoom: 16.0,
                        interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.kesinti_ariza_mobile',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(widget.fault.latitude, widget.fault.longitude),
                              width: 50,
                              height: 50,
                              child: Icon(Icons.location_on, color: _getStatusColor(widget.fault.status), size: 45),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Transform.translate(
                    offset: const Offset(0, -20),
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Kayıt ID: #${widget.fault.id}',
                                style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(widget.fault.status).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  widget.fault.status.toUpperCase(),
                                  style: TextStyle(
                                    color: _getStatusColor(widget.fault.status),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          Text(
                            widget.fault.title,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF003A70)),
                          ),
                          const SizedBox(height: 8),
                          
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text('Oluşturulma: $dateStr', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                            ],
                          ),
                          
                          const Divider(height: 32, thickness: 1, color: Color(0xFFEEEEEE)),
                          
                          const Text('Arıza Açıklaması', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF003A70))),
                          const SizedBox(height: 8),
                          Text(
                            widget.fault.description,
                            style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
                          ),
                          
                          const Divider(height: 32, thickness: 1, color: Color(0xFFEEEEEE)),
                          
                          const Text('Konum Bilgileri', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF003A70))),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on_outlined, color: Colors.grey, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_address, style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.4)),
                                    const SizedBox(height: 4),
                                    Text('${widget.fault.latitude}, ${widget.fault.longitude}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          if (isStaff) ...[
                            const Divider(height: 48, thickness: 1, color: Color(0xFFEEEEEE)),
                            const Text('Saha Ekibi Yönetim Paneli', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF00529B))),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              initialValue: initialDropdownValue,
                              decoration: const InputDecoration(
                                labelText: 'Arıza Durumunu Güncelle',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.engineering),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'bekliyor', child: Text('Bekliyor')),
                                DropdownMenuItem(value: 'islemde', child: Text('İşlemde / Ekip Yolda')),
                                DropdownMenuItem(value: 'tamamlandı', child: Text('Tamamlandı / Çözüldü')),
                                DropdownMenuItem(value: 'iptal', child: Text('İptal Edildi')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedStatus = val);
                              },
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: _isUpdatingStatus ? null : _durumuGuncelle,
                                icon: _isUpdatingStatus 
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Icon(Icons.save),
                                label: const Text('Durumu Kaydet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00529B),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (!_isLoadingUser && isOwner)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => EditFaultScreen(fault: widget.fault)));
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Düzenle'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF003A70),
                          side: const BorderSide(color: Color(0xFF003A70)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _silOnayDiyalogu(context, widget.fault.id),
                        icon: const Icon(Icons.delete),
                        label: const Text('Sil'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (!_isLoadingUser && !isOwner && !isStaff)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blueGrey.shade50,
              child: SafeArea(
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blueGrey, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Bu arıza başka bir kullanıcıya ait olduğu için düzenleme yetkiniz yoktur.',
                        style: TextStyle(fontSize: 13, color: Colors.blueGrey.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}