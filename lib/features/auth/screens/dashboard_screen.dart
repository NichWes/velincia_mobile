import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: user == null
            ? const Center(child: Text('User tidak ditemukan'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat datang, ${user.name}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Role: ${user.role}'),
                  const SizedBox(height: 8),
                  Text('Email: ${user.email ?? '-'}'),
                  const SizedBox(height: 8),
                  Text('Phone: ${user.phone ?? '-'}'),
                  const SizedBox(height: 8),
                  Text('Company: ${user.companyName ?? '-'}'),
                  const SizedBox(height: 8),
                  Text('Address: ${user.address ?? '-'}'),
                ],
              ),
      ),
    );
  }
}
