import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../project/providers/project_provider.dart';
import '../../project/screens/project_list_screen.dart';
import '../providers/auth_provider.dart';
import '../../order/providers/order_provider.dart';
import '../../order/screens/order_list_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Velincia HPL'),
        actions: [
          IconButton(
            onPressed: () async {
              await context.read<AuthProvider>().logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('User tidak ditemukan'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, ${user.name}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Perusahaan: ${user.companyName ?? '-'}'),
                        const SizedBox(height: 8),
                        Text('Email: ${user.email ?? '-'}'),
                        const SizedBox(height: 8),
                        Text('Alamat: ${user.address ?? '-'}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.folder_open),
                    title: const Text('Project Saya'),
                    subtitle: const Text('Lihat dan cek detail project'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider(
                            create: (_) => ProjectProvider(),
                            child: const ProjectListScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.receipt_long),
                    title: const Text('Order Saya'),
                    subtitle: const Text('Lihat daftar dan status order'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider(
                            create: (_) => OrderProvider(),
                            child: const OrderListScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
