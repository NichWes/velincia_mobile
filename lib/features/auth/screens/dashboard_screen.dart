import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../order/providers/order_provider.dart';
import '../../order/screens/order_list_screen.dart';
import '../../project/providers/project_provider.dart';
import '../../project/screens/project_list_screen.dart';
import '../../../shared/widgets/app_section_header.dart';
import '../../../shared/widgets/quick_action_card.dart';
import '../providers/auth_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: user == null
          ? const Center(child: Text('User tidak ditemukan'))
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {},
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
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Halo, ${user.name}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(999),
                                onTap: () async {
                                  await context.read<AuthProvider>().logout();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.16),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.logout,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            user.companyName ?? 'Velincia HPL',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    user.address ?? '-',
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const AppSectionHeader(
                      title: 'Akses Cepat',
                      subtitle: 'Pilih fitur utama yang ingin kamu gunakan',
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        QuickActionCard(
                          icon: Icons.folder_open_rounded,
                          title: 'Project',
                          subtitle: 'Kelola kebutuhan material project',
                          color: const Color(0xFFF97316),
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
                        const SizedBox(width: 12),
                        QuickActionCard(
                          icon: Icons.receipt_long_rounded,
                          title: 'Order',
                          subtitle: 'Pantau pesanan dan status pembayaran',
                          color: const Color(0xFF0F172A),
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
                      ],
                    ),
                    const SizedBox(height: 24),
                    const AppSectionHeader(
                      title: 'Ringkasan Akun',
                      subtitle: 'Informasi akun contractor yang sedang aktif',
                    ),
                    const SizedBox(height: 14),
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
                        children: [
                          _infoTile(
                              Icons.email_outlined, 'Email', user.email ?? '-'),
                          const Divider(height: 24),
                          _infoTile(Icons.business_outlined, 'Perusahaan',
                              user.companyName ?? '-'),
                          const Divider(height: 24),
                          _infoTile(Icons.location_city_outlined, 'Alamat',
                              user.address ?? '-'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xFFFFEDD5),
          child: Icon(icon, color: const Color(0xFFF97316), size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
