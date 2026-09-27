import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kesinti_ariza_mobile/models/fault_model.dart';
import 'package:kesinti_ariza_mobile/providers/fault_provider.dart';

class EditFaultScreen extends ConsumerStatefulWidget {
  final FaultModel fault; // Düzenlenecek eski veriyi alıyoruz

  const EditFaultScreen({super.key, required this.fault});

  @override
  ConsumerState<EditFaultScreen> createState() => _EditFaultScreenState();
}

class _EditFaultScreenState extends ConsumerState<EditFaultScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // BÜYÜ BURADA: Ekran açılırken kutuların içini mevcut verilerle dolduruyoruz
    _titleController = TextEditingController(text: widget.fault.title);
    _descriptionController = TextEditingController(text: widget.fault.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _arizaGuncelle() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen başlık ve açıklama girin.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Güncelleme fonksiyonunu çağırıyoruz
      await ref.read(faultListProvider.notifier).updateFault(
        widget.fault.id,
        title,
        description,
        widget.fault.status, // Mevcut durumu koruyoruz
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Arıza başarıyla güncellendi!'),
            backgroundColor: Colors.green,
          ),
        );
        // İşlem başarılıysa düzenleme ekranını kapat
        Navigator.pop(context);
        // Ardından detay ekranını da kapatıp ana listeye dön (Güncel halini görsün)
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
        title: const Text('Arızayı Düzenle'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.edit_document, size: 80, color: Colors.orange),
            const SizedBox(height: 32),

            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Arıza Başlığı',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 16),

            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Arıza Detayı',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 32),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _arizaGuncelle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Güncelleme işlemi olduğu için turuncu
                  foregroundColor: Colors.white,
                ),
                child: _isLoading 
                  ? const SizedBox(
                      width: 24, 
                      height: 24, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : const Text('Güncelle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}