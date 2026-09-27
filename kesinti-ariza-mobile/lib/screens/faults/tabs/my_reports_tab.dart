import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kesinti_ariza_mobile/providers/fault_provider.dart';
import 'package:kesinti_ariza_mobile/screens/faults/fault_detail_screen.dart';

class MyReportsTab extends ConsumerWidget {
  final int? currentUserId;
  const MyReportsTab({super.key, required this.currentUserId});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'bekliyor': return Colors.orange;
      case 'çözüldü': case 'tamamlandı': return Colors.green;
      case 'iptal': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final faultsAsyncValue = ref.watch(faultListProvider);

    return faultsAsyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Hata: $error')),
      data: (faults) {
        final displayedFaults = faults.where((f) => f.userId == currentUserId).toList();

        return RefreshIndicator(
          onRefresh: () => ref.read(faultListProvider.notifier).refreshList(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(padding: EdgeInsets.fromLTRB(16, 24, 16, 8), child: Text('Benim Bildirimlerim', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                if (displayedFaults.isEmpty)
                  const Padding(padding: EdgeInsets.all(24.0), child: Center(child: Text('Henüz hiç arıza bildirmediniz.', style: TextStyle(color: Colors.grey))))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: displayedFaults.length,
                    itemBuilder: (context, index) {
                      final fault = displayedFaults[index];
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                        child: InkWell(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FaultDetailScreen(fault: fault))),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: Row(children: [Icon(Icons.bolt, color: _getStatusColor(fault.status)), const SizedBox(width: 8), Expanded(child: Text(fault.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis))])),
                                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: _getStatusColor(fault.status).withAlpha(25), borderRadius: BorderRadius.circular(12)), child: Text(fault.status.toUpperCase(), style: TextStyle(color: _getStatusColor(fault.status), fontWeight: FontWeight.bold, fontSize: 10))),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(fault.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}