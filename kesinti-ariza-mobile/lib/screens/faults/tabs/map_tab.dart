import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart'; 
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart'; 
import 'package:kesinti_ariza_mobile/models/fault_model.dart';
import 'package:kesinti_ariza_mobile/providers/fault_provider.dart';
import 'package:kesinti_ariza_mobile/screens/faults/fault_detail_screen.dart';

class MapTab extends ConsumerStatefulWidget {
  final bool isActive; 

  const MapTab({super.key, required this.isActive});

  @override
  ConsumerState<MapTab> createState() => _MapTabState();
}

class _MapTabState extends ConsumerState<MapTab> {
  final MapController _mapController = MapController(); 
  bool _isLocating = false; 
  bool _hasAutoLocated = false; 
  LatLng? _myLocationPin; 

  // YENİ: Aktif filtre seçeneğini tutan değişken (Varsayılan: Tümü)
  String _selectedFilter = 'Tümü';

  @override
  void didUpdateWidget(covariant MapTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive && !_hasAutoLocated) {
      _hasAutoLocated = true; 
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _goToMyLocation();
        }
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'bekliyor': return Colors.orange;
      case 'islemde': case 'devam ediyor': return Colors.blue;
      case 'çözüldü': case 'tamamlandı': return Colors.green;
      case 'iptal': return Colors.red;
      default: return Colors.grey;
    }
  }

  Future<void> _goToMyLocation() async {
    setState(() => _isLocating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen cihazınızın konum servisini açın.')));
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      final position = await Geolocator.getCurrentPosition();
      final myLatLng = LatLng(position.latitude, position.longitude);
      
      _mapController.move(myLatLng, 15.0);
      setState(() => _myLocationPin = myLatLng);
    } catch (e) {
      // Hata olursa atla
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _showFaultSummary(FaultModel fault) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        fault.title,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF003A70)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(fault.status).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        fault.status.toUpperCase(),
                        style: TextStyle(color: _getStatusColor(fault.status), fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  fault.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black87, height: 1.4),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx); 
                      Navigator.push(context, MaterialPageRoute(builder: (context) => FaultDetailScreen(fault: fault)));
                    },
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text('Detayları Gör', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003A70),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final faultsAsyncValue = ref.watch(faultListProvider);

    return faultsAsyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Hata: $error')),
      data: (faults) {
        // İptal edilenleri en baştan elliyoruz
        final activeFaults = faults.where((f) => f.status.toLowerCase() != 'iptal').toList();
        
        // YENİ: Seçilen filtreye göre haritada gösterilecek arızaları süzüyoruz
        final filteredFaults = activeFaults.where((f) {
          if (_selectedFilter == 'Tümü') return true;
          if (_selectedFilter == 'Bekliyor') return f.status.toLowerCase() == 'bekliyor';
          if (_selectedFilter == 'İşlemde') return f.status.toLowerCase() == 'islemde' || f.status.toLowerCase() == 'devam ediyor';
          if (_selectedFilter == 'Tamamlandı') return f.status.toLowerCase() == 'tamamlandı' || f.status.toLowerCase() == 'çözüldü';
          return true;
        }).toList();
        
        LatLng initialCenter = const LatLng(39.92077, 32.85411);
        if (_myLocationPin != null) {
          initialCenter = _myLocationPin!;
        } else if (filteredFaults.isNotEmpty) {
          initialCenter = LatLng(filteredFaults.first.latitude, filteredFaults.first.longitude);
        }

        return Stack(
          children: [
            FlutterMap(
              mapController: _mapController, 
              options: MapOptions(
                initialCenter: initialCenter, 
                initialZoom: _myLocationPin != null || filteredFaults.isNotEmpty ? 12.0 : 6.0
              ),
              children: [
                TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.kesinti_ariza_mobile'),
                MarkerLayer(
                  markers: [
                    ...filteredFaults.map((fault) => Marker(
                      point: LatLng(fault.latitude, fault.longitude),
                      width: 50, height: 50,
                      child: GestureDetector(
                        onTap: () => _showFaultSummary(fault),
                        child: Icon(Icons.location_on, color: _getStatusColor(fault.status), size: 45),
                      ),
                    )),
                    if (_myLocationPin != null)
                      Marker(
                        point: _myLocationPin!,
                        width: 60, height: 60,
                        child: Column(children: [
                          const Icon(Icons.person_pin_circle, color: Colors.red, size: 40),
                          Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.red, width: 1)), child: const Text('Siz', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 10))),
                        ]),
                      ),
                  ],
                ),
              ],
            ),
            
            // YENİ: Üst Panel - Özet Kartı ve Filtre Çipleri Yan Yana / Alt Alta
            Positioned(
              top: 16, left: 16, right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Özet Kartı
                  Card(
                    elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start, 
                            children: [
                              const Text('AKTİF DURUM', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)), 
                              const SizedBox(height: 4), 
                              Text(_selectedFilter == 'Tümü' ? 'Tüm Arızalar' : 'Filtreli Görünüm', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF003A70)))
                            ]
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), 
                            decoration: BoxDecoration(color: Colors.red.withAlpha(20), borderRadius: BorderRadius.circular(8)), 
                            child: Column(
                              children: [
                                // Kart üzerindeki sayıyı da anlık gösterilen veriye göre güncelliyoruz
                                Text('${filteredFaults.length}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)), 
                                const Text('Gösterilen', style: TextStyle(fontSize: 12, color: Colors.red))
                              ]
                            )
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // 2. Filtreleme Çipleri (Sağa Sola Kaydırılabilir)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Tümü', 'Bekliyor', 'İşlemde', 'Tamamlandı'].map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(
                              filter, 
                              style: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF003A70),
                                fontWeight: FontWeight.bold,
                              )
                            ),
                            selected: isSelected,
                            selectedColor: const Color(0xFF003A70),
                            backgroundColor: Colors.white,
                            checkmarkColor: Colors.white,
                            elevation: 4,
                            shadowColor: Colors.black12,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            onSelected: (selected) {
                              setState(() => _selectedFilter = filter);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            
            Positioned(
              right: 16, bottom: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton.small(heroTag: 'btnMyLocation', backgroundColor: Colors.white, onPressed: _isLocating ? null : _goToMyLocation, child: _isLocating ? const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.my_location, color: Color(0xFF003A70))),
                  const SizedBox(height: 12),
                  FloatingActionButton.small(heroTag: 'btnZoomIn', backgroundColor: Colors.white, onPressed: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1), child: const Icon(Icons.add, color: Color(0xFF003A70))),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(heroTag: 'btnZoomOut', backgroundColor: Colors.white, onPressed: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1), child: const Icon(Icons.remove, color: Color(0xFF003A70))),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}