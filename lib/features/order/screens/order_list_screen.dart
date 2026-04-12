import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import 'order_detail_screen.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<OrderProvider>().fetchOrders();
    });
  }

  String _formatCurrency(double value) {
    return 'Rp ${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Saya'),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<OrderProvider>().fetchOrders(),
        child: Builder(
          builder: (context) {
            if (provider.isLoadingList && provider.orders.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.listErrorMessage != null && provider.orders.isEmpty) {
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

            if (provider.orders.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('Belum ada order')),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = provider.orders[index];

                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      order.orderCode,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Project: ${order.project?.title ?? '-'}'),
                          const SizedBox(height: 4),
                          Text('Status: ${order.status}'),
                          const SizedBox(height: 4),
                          Text('Type: ${order.orderType}'),
                          const SizedBox(height: 4),
                          Text('Delivery: ${order.deliveryMethod}'),
                          const SizedBox(height: 4),
                          Text('Total: ${_formatCurrency(order.totalAmount)}'),
                        ],
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider(
                            create: (_) => OrderProvider(),
                            child: OrderDetailScreen(orderId: order.id),
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
