import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/utils/status_utils.dart';
import '../../../shared/widgets/app_section_header.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../invoice/providers/invoice_provider.dart';
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
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('Order Saya'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<OrderProvider>().fetchOrders(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const AppSectionHeader(
              title: 'Riwayat Order',
              subtitle:
                  'Lihat status pesanan, pembayaran, invoice, dan progres order',
            ),
            const SizedBox(height: 16),
            if (provider.isLoadingList && provider.orders.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 120),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.listErrorMessage != null &&
                provider.orders.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 120),
                child: Center(
                  child: Text(
                    provider.listErrorMessage!,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else if (provider.orders.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 120),
                child: Center(child: Text('Belum ada order')),
              )
            else
              ...provider.orders.map((order) {
                final style = orderStatusStyle(order.status);

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
                                create: (_) => OrderProvider(),
                              ),
                              ChangeNotifierProvider(
                                create: (_) => InvoiceProvider(),
                              ),
                            ],
                            child: OrderDetailScreen(orderId: order.id),
                          ),
                        ),
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
                                  order.orderCode,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              StatusBadge(
                                text: order.status,
                                backgroundColor: style.background,
                                textColor: style.foreground,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            order.project?.title ?? '-',
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _chipInfo(Icons.layers_outlined, order.orderType),
                              _chipInfo(Icons.local_shipping_outlined,
                                  order.deliveryMethod),
                              _chipInfo(Icons.payments_outlined,
                                  _formatCurrency(order.totalAmount)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Text(
                                'Lihat Detail',
                                style: TextStyle(
                                  color: const Color(0xFFF97316),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                                color: Colors.deepPurple.shade700,
                              ),
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

  Widget _chipInfo(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
