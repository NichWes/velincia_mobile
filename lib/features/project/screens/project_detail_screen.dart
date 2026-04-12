import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../material/providers/material_provider.dart';
import '../providers/project_provider.dart';
import 'add_project_item_screen.dart';
import 'project_estimate_screen.dart';
import '../../order/providers/order_provider.dart';
import '../../order/screens/create_order_screen.dart';

class ProjectDetailScreen extends StatefulWidget {
  final int projectId;

  const ProjectDetailScreen({
    super.key,
    required this.projectId,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProjectProvider>().fetchProjectDetail(widget.projectId);
    });
  }

  Future<void> _goToAddItem() async {
    final shouldRefresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(
              value: context.read<ProjectProvider>(),
            ),
            ChangeNotifierProvider(
              create: (_) => MaterialProvider(),
            ),
          ],
          child: AddProjectItemScreen(projectId: widget.projectId),
        ),
      ),
    );

    if (shouldRefresh == true && mounted) {
      await context
          .read<ProjectProvider>()
          .fetchProjectDetail(widget.projectId);
    }
  }

  Future<void> _goToCreateOrder() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(
              value: context.read<ProjectProvider>(),
            ),
            ChangeNotifierProvider(
              create: (_) => OrderProvider(),
            ),
          ],
          child: CreateOrderScreen(projectId: widget.projectId),
        ),
      ),
    );

    if (!mounted) return;
    await context.read<ProjectProvider>().fetchProjectDetail(widget.projectId);
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'draft':
        return 'Draft';
      case 'active':
        return 'Active';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectProvider>();
    final project = provider.selectedProject;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Project'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddItem,
        child: const Icon(Icons.add),
      ),
      body: Builder(
        builder: (context) {
          if (provider.isLoadingDetail && project == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.detailErrorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  provider.detailErrorMessage!,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (project == null) {
            return const Center(
              child: Text('Data project tidak ditemukan'),
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
                        project.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Status: ${_formatStatus(project.status)}'),
                      const SizedBox(height: 8),
                      Text('Tipe Project: ${project.projectType ?? '-'}'),
                      const SizedBox(height: 8),
                      Text(
                        'Budget Target: ${project.budgetTarget?.toStringAsFixed(0) ?? '-'}',
                      ),
                      const SizedBox(height: 8),
                      Text('Catatan: ${project.notes ?? '-'}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Daftar Item',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (project.items.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Belum ada item pada project ini'),
                  ),
                )
              else
                ...project.items.map(
                  (item) => Card(
                    child: ListTile(
                      title: Text(item.displayName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Text('Qty dibutuhkan: ${item.qtyNeeded}'),
                          Text('Qty dibeli: ${item.qtyPurchased}'),
                          Text('Status: ${item.status}'),
                          if (item.material?.unit != null)
                            Text('Unit: ${item.material!.unit}'),
                          if (item.notes != null && item.notes!.isNotEmpty)
                            Text('Catatan: ${item.notes}'),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider.value(
                          value: context.read<ProjectProvider>(),
                          child: ProjectEstimateScreen(
                              projectId: widget.projectId),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.calculate),
                  label: const Text('Lihat Estimasi'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _goToCreateOrder,
                  icon: const Icon(Icons.shopping_cart_checkout),
                  label: const Text('Buat Order'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
