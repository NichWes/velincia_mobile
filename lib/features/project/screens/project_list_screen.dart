import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/utils/status_utils.dart';
import '../../../shared/widgets/app_section_header.dart';
import '../../../shared/widgets/status_badge.dart';
import '../providers/project_provider.dart';
import '../providers/project_measurement_provider.dart';
import 'create_project_screen.dart';
import 'project_detail_screen.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProjectProvider>().fetchProjects();
    });
  }

  Future<void> _goToCreateProject() async {
    final shouldRefresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<ProjectProvider>(),
          child: const CreateProjectScreen(),
        ),
      ),
    );

    if (shouldRefresh == true && mounted) {
      await context.read<ProjectProvider>().fetchProjects();
    }
  }

  String _formatCurrency(double? value) {
    if (value == null) return '-';
    return 'Rp ${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('Project Saya'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToCreateProject,
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 8,
        icon: const Icon(
          Icons.add_rounded,
          color: Colors.white,
        ),
        label: const Text(
          'Project Baru',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<ProjectProvider>().fetchProjects(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const AppSectionHeader(
              title: 'Daftar Project',
              subtitle: 'Pantau kebutuhan material dan progres tiap project',
            ),
            const SizedBox(height: 16),
            if (provider.isLoadingList && provider.projects.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 120),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.listErrorMessage != null &&
                provider.projects.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 120),
                child: Center(
                  child: Text(
                    provider.listErrorMessage!,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else if (provider.projects.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 120),
                child: Center(child: Text('Belum ada project')),
              )
            else
              ...provider.projects.map((project) {
                final statusStyle = projectStatusStyle(project.status);

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
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
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => MultiProvider(
                                  providers: [
                                    ChangeNotifierProvider(
                                        create: (_) => ProjectProvider()
                                          ..fetchProjectDetail(project.id)),
                                    ChangeNotifierProvider(
                                        create: (_) =>
                                            ProjectMeasurementProvider()),
                                  ],
                                  child: ProjectDetailScreen(
                                      projectId: project.id),
                                )),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  project.title,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              StatusBadge(
                                text: project.status,
                                backgroundColor: statusStyle.background,
                                textColor: statusStyle.foreground,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            runSpacing: 10,
                            spacing: 10,
                            children: [
                              _miniInfo('Tipe', project.projectType ?? '-'),
                              _miniInfo('Item', '${project.itemsCount ?? 0}'),
                              _miniInfo('Budget',
                                  _formatCurrency(project.budgetTarget)),
                            ],
                          ),
                          if (project.notes != null &&
                              project.notes!.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            Text(
                              project.notes!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                height: 1.4,
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Text(
                                'Lihat Detail',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(Icons.arrow_forward_rounded,
                                  size: 18, color: Colors.blue.shade700),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _miniInfo(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
}
