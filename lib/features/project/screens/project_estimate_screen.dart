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

  String formatCurrency(double value) {
    return 'Rp ${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectProvider>();
    final estimate = provider.estimate;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estimasi Project'),
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

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        estimate.project.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Total item: ${estimate.summary.totalItems}'),
                      Text('Priced item: ${estimate.summary.pricedItems}'),
                      Text('Unpriced item: ${estimate.summary.unpricedItems}'),
                      const SizedBox(height: 8),
                      Text(
                        'Total estimasi dibutuhkan: ${formatCurrency(estimate.summary.totalEstimateNeeded)}',
                      ),
                      Text(
                        'Total estimasi terbeli: ${formatCurrency(estimate.summary.totalEstimatePurchased)}',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Progress: ${estimate.summary.progressPercent.toStringAsFixed(2)}%',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Item dengan Harga',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (estimate.priced.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Belum ada item priced'),
                  ),
                )
              else
                ...estimate.priced.map(
                  (item) => Card(
                    child: ListTile(
                      title: Text(item.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Text(
                              'Qty needed: ${item.qtyNeeded} ${item.unit ?? ''}'),
                          Text(
                              'Qty purchased: ${item.qtyPurchased} ${item.unit ?? ''}'),
                          Text(
                              'Harga estimasi: ${formatCurrency(item.priceEstimate)}'),
                          Text(
                              'Subtotal needed: ${formatCurrency(item.subtotalNeeded)}'),
                          Text(
                              'Subtotal purchased: ${formatCurrency(item.subtotalPurchased)}'),
                          Text('Status: ${item.status}'),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              const Text(
                'Item Tanpa Harga',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (estimate.unpriced.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Tidak ada item unpriced'),
                  ),
                )
              else
                ...estimate.unpriced.map(
                  (item) => Card(
                    child: ListTile(
                      title: Text(item.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Text('Qty needed: ${item.qtyNeeded}'),
                          Text('Qty purchased: ${item.qtyPurchased}'),
                          Text('Status: ${item.status}'),
                          Text('Reason: ${item.reason ?? '-'}'),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
