import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:kesinti_ariza_mobile/providers/fault_provider.dart';

class AddFaultScreen extends ConsumerStatefulWidget {
  const AddFaultScreen({super.key});

  @override
  ConsumerState<AddFaultScreen> createState() => _AddFaultScreenState();
}

class _AddFaultScreenState extends ConsumerState<AddFaultScreen> {
  int _currentStep = 0; 
  String? _selectedFaultType; 
  final _descriptionController = TextEditingController();
  
  bool _isLoading = false;
  bool _isLoadingLocation = false;
  Position? _currentPosition;
  String _currentAddress = '';
  
  // DÜZELTME: geocoding 5.0+ için nesne tanımı eklendi
  final Geocoding _geocoding = Geocoding();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      // DÜZELTME: Nesne üzerinden çağrıldı
      List<Placemark> placemarks = await _geocoding.placemarkFromCoordinates(
        position.latitude, 
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _currentAddress = '${place.street}, ${place.subLocality}, ${place.locality} / ${place.administrativeArea}';
          _currentAddress = _currentAddress.replaceAll('null, ', '').replaceAll(', null', '');
        });
      }
    } catch (e) {
      setState(() => _currentAddress = 'Açık adres çözümlenemedi (Koordinat kullanılıyor)');
    }
  }

  Future<void> _getKonumGuvenli() async {
    setState(() => _isLoadingLocation = true);
    
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen konum servisini açın.')));
      setState(() => _isLoadingLocation = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Konum izni reddedildi.')));
        setState(() => _isLoadingLocation = false);
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('İzin kalıcı reddedildi.'), action: SnackBarAction(label: 'AYARLAR', onPressed: () => Geolocator.openAppSettings())));
      setState(() => _isLoadingLocation = false);
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() => _currentPosition = position);
    
    await _getAddressFromLatLng(position);
    
    setState(() => _isLoadingLocation = false);
  }

  Future<void> _arizaBildir() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(faultListProvider.notifier).createFault(
        _selectedFaultType!, 
        _descriptionController.text.trim(),
        _currentPosition!.latitude, 
        _currentPosition!.longitude, 
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Arıza başarıyla bildirildi!'), backgroundColor: Colors.green),
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildStep0() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'Bildirimde bulunmak istediğiniz ihbar\ntürünü seçiniz.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
        const SizedBox(height: 32),
        
        const Row(
          children: [
            Icon(Icons.light_mode_outlined, size: 24, color: Colors.black87),
            SizedBox(width: 8),
            Text('Aydınlatma İhbarları', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
        const Divider(thickness: 1, height: 24),
        _buildCheckboxOption('Yanmayan Sokak Lambası'),
        _buildCheckboxOption('Sökülmüş/Kırılmış Lamba'),
        _buildCheckboxOption('Önceden Mevcut Olan Direklere İlişkin Eksiklikler'),
        
        const SizedBox(height: 32),
        
        const Row(
          children: [
            Icon(Icons.electric_bolt, size: 24, color: Colors.black87),
            SizedBox(width: 8),
            Text('Elektrik Kesintisi İhbarları', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
        const Divider(thickness: 1, height: 24),
        _buildCheckboxOption('Bölgemde/Çevremde Elektrik Yok'),
        _buildCheckboxOption('Evimde Elektrik Yok'),
        _buildCheckboxOption('Voltaj Düşüklüğü/Dalgalanması'),
        _buildCheckboxOption('Tehlikeli Durum Yönlendirmesi (186)'),
      ],
    );
  }

  Widget _buildCheckboxOption(String title) {
    bool isSelected = _selectedFaultType == title;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFaultType = title;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                border: Border.all(color: isSelected ? const Color(0xFF00A2E8) : Colors.grey.shade400, width: 2),
                color: isSelected ? const Color(0xFF00A2E8) : Colors.transparent,
              ),
              child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 250,
          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.shade100)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _isLoadingLocation
                ? const Center(child: CircularProgressIndicator())
                : _currentPosition == null
                    ? Center(
                        child: TextButton.icon(
                          onPressed: _getKonumGuvenli, 
                          icon: const Icon(Icons.location_on), 
                          label: const Text('Konumumu Bul')
                        )
                      )
                    : FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                          initialZoom: 16.0,
                          interactionOptions: const InteractionOptions(flags: InteractiveFlag.none), 
                        ),
                        children: [
                          TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.kesinti_ariza_mobile'),
                          MarkerLayer(
                            markers: [Marker(point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude), width: 50, height: 50, child: const Icon(Icons.location_pin, size: 50, color: Color(0xFF00529B)))],
                          ),
                        ],
                      ),
          ),
        ),
        
        const SizedBox(height: 24),
        const Text('Tespit Edilen Adres', style: TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
          child: _isLoadingLocation 
              ? const Center(child: CircularProgressIndicator())
              : Text(
                  _currentPosition != null ? _currentAddress : 'Konum alınamadı. Lütfen tekrar deneyin.',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ekstra Detaylar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Ekiplerimizin sorunu daha hızlı çözmesi için varsa ek bilgi girebilirsiniz (Zorunlu Değil).', style: TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 16),
        TextField(
          controller: _descriptionController,
          maxLines: 5,
          decoration: const InputDecoration(labelText: 'Açıklama (İsteğe Bağlı)', hintText: 'Örn: Direk numarası T-45', alignLabelWithHint: true, prefixIcon: Icon(Icons.description), border: OutlineInputBorder()),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('İhbar Özeti', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00529B))),
          const Divider(),
          const SizedBox(height: 8),
          const Text('İhbar Türü', style: TextStyle(color: Colors.grey, fontSize: 12)),
          Text(_selectedFaultType ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          if (_descriptionController.text.isNotEmpty) ...[
            const Text('Açıklama', style: TextStyle(color: Colors.grey, fontSize: 12)),
            Text(_descriptionController.text, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
          ],
          const Text('Konum', style: TextStyle(color: Colors.grey, fontSize: 12)),
          Text(_currentAddress, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Row(
        children: [
          _buildStepItem(0, 'Tür'),
          Expanded(child: Divider(color: _currentStep >= 1 ? const Color(0xFF00529B) : Colors.grey.shade300, thickness: 2)),
          _buildStepItem(1, 'Konum'),
          Expanded(child: Divider(color: _currentStep >= 2 ? const Color(0xFF00529B) : Colors.grey.shade300, thickness: 2)),
          _buildStepItem(2, 'Ekstra'),
          Expanded(child: Divider(color: _currentStep >= 3 ? const Color(0xFF00529B) : Colors.grey.shade300, thickness: 2)),
          _buildStepItem(3, 'Onay'),
        ],
      ),
    );
  }

  Widget _buildStepItem(int stepIndex, String title) {
    bool isActive = _currentStep >= stepIndex;
    return Column(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: isActive ? const Color(0xFF00529B) : Colors.grey.shade300,
          child: Text('${stepIndex + 1}', style: TextStyle(color: isActive ? Colors.white : Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(color: isActive ? const Color(0xFF00529B) : Colors.grey, fontSize: 10, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni İhbar'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              _buildStepIndicator(),
              
              Expanded(
                child: SingleChildScrollView(
                  child: _currentStep == 0 
                      ? _buildStep0() 
                      : _currentStep == 1 
                          ? _buildStep1() 
                          : _currentStep == 2 
                              ? _buildStep2()
                              : _buildStep3(),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  children: [
                    if (_currentStep > 0) ...[
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          height: 50,
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : () => setState(() => _currentStep--),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF00A2E8),
                              side: const BorderSide(color: Color(0xFF00A2E8)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                            ),
                            child: const Text('GERİ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : () {
                            if (_currentStep == 0 && _selectedFaultType == null) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen bir ihbar türü seçin.')));
                              return;
                            }
                            if (_currentStep == 1 && _currentPosition == null) {
                              _getKonumGuvenli();
                              return;
                            }

                            if (_currentStep == 3) {
                              _arizaBildir();
                            } else {
                              setState(() => _currentStep++);
                              if (_currentStep == 1 && _currentPosition == null) {
                                _getKonumGuvenli();
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00A2E8),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                          ),
                          child: _isLoading
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text(
                                  _currentStep == 3 ? 'GÖNDER' : 'DEVAM', 
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}