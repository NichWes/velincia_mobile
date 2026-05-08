import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../material/providers/material_provider.dart';
import '../../order/providers/order_provider.dart';
import '../../order/screens/create_order_screen.dart';
import '../screens/project_discussion_screen.dart';
import '../providers/project_provider.dart';
import 'add_project_item_screen.dart';
import 'project_estimate_screen.dart';
import '../providers/project_measurement_provider.dart';
import '../providers/project_attachment_provider.dart';
import '../providers/project_discussion_provider.dart';
import '../widgets/project_measurement_card.dart';
import '../widgets/project_attachment_card.dart';

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
      context.read<ProjectProvider>().fetchProjectEstimate(widget.projectId);
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
      await context
          .read<ProjectProvider>()
          .fetchProjectEstimate(widget.projectId);
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
    await context
        .read<ProjectProvider>()
        .fetchProjectEstimate(widget.projectId);
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

  String _formatCurrency(double? value) {
    if (value == null) return '-';
    return 'Rp ${value.toStringAsFixed(0)}';
  }

  Color _statusBg(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return const Color(0xFFE5E7EB);
      case 'active':
        return const Color(0xFFFFEDD5);
      case 'completed':
        return const Color(0xFFDCFCE7);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color _statusText(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return const Color(0xFF374151);
      case 'active':
        return const Color(0xFFC2410C);
      case 'completed':
        return const Color(0xFF15803D);
      default:
        return const Color(0xFF374151);
    }
  }

  Widget _buildEstimateCard(ProjectProvider provider) {
    final estimate = provider.estimate;

    if (provider.isLoadingEstimate && estimate == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (estimate == null) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Text('Data estimasi belum tersedia'),
      );
    }

    final summary = estimate.summary;
    final progress = (summary.progressPercent / 100).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E293B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF97316).withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estimasi Project',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _estimateItem('Total Kebutuhan',
                  _formatCurrency(summary.totalEstimateNeeded)),
              const SizedBox(width: 12),
              _estimateItem('Sudah Dibeli',
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
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _miniSummaryChip('Item', '${summary.totalItems}'),
              const SizedBox(width: 8),
              _miniSummaryChip('Priced', '${summary.pricedItems}'),
              const SizedBox(width: 8),
              _miniSummaryChip('Unpriced', '${summary.unpricedItems}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _estimateItem(String label, String value) {
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

  Widget _miniSummaryChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _infoBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectProvider>();
    final project = provider.selectedProject;

    final authProvider = context.watch<AuthProvider>();
    final currentUserId = authProvider.user?.id ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('Detail Project'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToAddItem,
        backgroundColor: const Color(0xFFF97316),
        foregroundColor: Colors.white,
        elevation: 8,
        icon: const Icon(
          Icons.add_rounded,
          color: Colors.white,
        ),
        label: const Text(
          'Tambah Item',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
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

          return RefreshIndicator(
            onRefresh: () async {
              await context
                  .read<ProjectProvider>()
                  .fetchProjectDetail(widget.projectId);
              await context
                  .read<ProjectProvider>()
                  .fetchProjectEstimate(widget.projectId);
              await context
                  .read<ProjectMeasurementProvider>()
                  .fetchMeasurements(widget.projectId);
              await context
                  .read<ProjectAttachmentProvider>()
                  .fetchAttachments(widget.projectId);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              project.title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _statusBg(project.status),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              _formatStatus(project.status),
                              style: TextStyle(
                                color: _statusText(project.status),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _infoBox('Tipe Project', project.projectType ?? '-'),
                          _infoBox(
                              'Budget', _formatCurrency(project.budgetTarget)),
                          _infoBox('Jumlah Item', '${project.items.length}'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Catatan',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        project.notes?.isNotEmpty == true
                            ? project.notes!
                            : '-',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildEstimateCard(provider),
                const SizedBox(height: 16),
                ProjectMeasurementCard(projectId: widget.projectId),
                const SizedBox(height: 16),
                ProjectAttachmentCard(projectId: widget.projectId),
                const SizedBox(height: 16),
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Color(0xFFF97316)),
                              foregroundColor: const Color(0xFFF97316),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChangeNotifierProvider.value(
                                    value: context.read<ProjectProvider>(),
                                    child: ProjectEstimateScreen(
                                      projectId: widget.projectId,
                                    ),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.calculate),
                            label: const Text('Estimasi'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: const Color(0xFFF97316),
                              foregroundColor: Colors.white,
                              iconColor: Colors.white,
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: _goToCreateOrder,
                            icon: const Icon(Icons.shopping_cart_checkout),
                            label: const Text('Order'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                iconColor: Colors.white,
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChangeNotifierProvider(
                                      create: (_) =>
                                          ProjectDiscussionProvider(),
                                      child: ProjectDiscussionScreen(
                                        projectId: widget.projectId,
                                        currentUserId: currentUserId,
                                      ),
                                    ),
                                  ),
                                );

                                if (!mounted) return;

                                await context
                                    .read<ProjectProvider>()
                                    .fetchProjectDetail(widget.projectId);
                              },
                              icon: const Icon(Icons.chat_bubble_rounded),
                              label: Text(
                                project.discussionUnreadCount > 0
                                    ? 'Diskusi Project (${project.discussionUnreadCount})'
                                    : 'Diskusi Project',
                              ),
                            ),
                          ),
                          if (project.discussionUnreadCount > 0)
                            Positioned(
                              top: -8,
                              right: -8,
                              child: Container(
                                constraints: const BoxConstraints(
                                  minWidth: 24,
                                  minHeight: 24,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 7),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444),
                                  borderRadius: BorderRadius.circular(999),
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                ),
                                child: Center(
                                  child: Text(
                                    '${project.discussionUnreadCount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Daftar Item',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                if (project.items.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Belum ada item pada project ini'),
                  )
                else
                  ...project.items.map(
                    (item) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.035),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _infoBox('Qty Dibutuhkan', '${item.qtyNeeded}'),
                                _infoBox('Qty Dibeli', '${item.qtyPurchased}'),
                                _infoBox('Status', item.status),
                                if (item.material?.unit != null)
                                  _infoBox('Unit', item.material!.unit!),
                              ],
                            ),
                            if (item.notes != null &&
                                item.notes!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                'Catatan: ${item.notes}',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                            ],
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
