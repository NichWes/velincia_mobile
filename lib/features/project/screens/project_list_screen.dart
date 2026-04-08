import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Saya'),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<ProjectProvider>().fetchProjects(),
        child: Builder(
          builder: (context) {
            if (provider.isLoadingList && provider.projects.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (provider.listErrorMessage != null &&
                provider.projects.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      provider.listErrorMessage!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }

            if (provider.projects.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('Belum ada project')),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.projects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final project = provider.projects[index];

                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      project.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status: ${project.status}'),
                          const SizedBox(height: 4),
                          Text('Tipe: ${project.projectType ?? '-'}'),
                          const SizedBox(height: 4),
                          Text('Jumlah item: ${project.itemsCount ?? 0}'),
                          const SizedBox(height: 4),
                          Text(
                            'Budget: ${project.budgetTarget?.toStringAsFixed(0) ?? '-'}',
                          ),
                        ],
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider(
                            create: (_) => ProjectProvider(),
                            child: ProjectDetailScreen(projectId: project.id),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
