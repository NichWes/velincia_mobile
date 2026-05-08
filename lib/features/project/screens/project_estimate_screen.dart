import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';

class ProjectEstimateScreen extends StatefulWidget {
  final int projectId;

  const ProjectEstimateScreen({
    super.key,
    required this.projectId,
  });

  @override
  State<ProjectEstimateScreen> createState() => _ProjectEstimateScreenState();
}

class _ProjectEstimateScreenState extends State<ProjectEstimateScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProjectProvider>().fetchProjectEstimate(widget.projectId);
    });
  }

  String _formatCurrency(double value) {
    return 'Rp ${value.toStringAsFixed(0)}';
  }

  Widget _miniStat(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.14),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectProvider>();
    final estimate = provider.estimate;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('Estimasi Project'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Builder(
        builder: (context) {
          if (provider.isLoadingEstimate && estimate == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.estimateErrorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  provider.estimateErrorMessage!,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (estimate == null) {
            return const Center(
              child: Text('Data estimasi tidak ditemukan'),
            );
          }

          final summary = estimate.summary;
          final progress = (summary.progressPercent / 100).clamp(0.0, 1.0);

          return RefreshIndicator(
            onRefresh: () => context
                .read<ProjectProvider>()
                .fetchProjectEstimate(widget.projectId),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF0F172A),
                        Color(0xFF1E293B),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF97316).withOpacity(0.18),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        estimate.project.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _miniStat('Total Kebutuhan',
                              _formatCurrency(summary.totalEstimateNeeded)),
                          const SizedBox(width: 12),
                          _miniStat('Sudah Dibeli',
                              _formatCurrency(summary.totalEstimatePurchased)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor: Colors.white.withOpacity(0.22),
                          color: const Color(0xFF86EFAC),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${summary.progressPercent.toStringAsFixed(2)}% selesai',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _infoChip('Total Item', '${summary.totalItems}'),
                          _infoChip('Priced', '${summary.pricedItems}'),
                          _infoChip('Unpriced', '${summary.unpricedItems}'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Item dengan Harga',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                if (estimate.priced.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Belum ada item priced'),
                  )
                else
                  ...estimate.priced.map(
                    (item) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _infoChip('Kebutuhan',
                                    '${item.qtyNeeded} ${item.unit ?? ''}'),
                                _infoChip('Sudah Dibeli',
                                    '${item.qtyPurchased} ${item.unit ?? ''}'),
                                _infoChip('Harga',
                                    _formatCurrency(item.priceEstimate)),
                                _infoChip('Status', item.status),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Subtotal Kebutuhan: ${_formatCurrency(item.subtotalNeeded)}',
                              style: TextStyle(color: Colors.grey.shade800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Subtotal Terbeli: ${_formatCurrency(item.subtotalPurchased)}',
                              style: TextStyle(color: Colors.grey.shade800),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                const Text(
                  'Item Tanpa Harga',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                if (estimate.unpriced.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Tidak ada item unpriced'),
                  )
                else
                  ...estimate.unpriced.map(
                    (item) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _infoChip('Kebutuhan', '${item.qtyNeeded}'),
                                _infoChip(
                                    'Sudah Dibeli', '${item.qtyPurchased}'),
                                _infoChip('Status', item.status),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Reason: ${item.reason ?? '-'}',
                              style: TextStyle(
                                color: Colors.orange.shade800,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
