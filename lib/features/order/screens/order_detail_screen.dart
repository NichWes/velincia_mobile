import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<OrderProvider>().fetchOrderDetail(widget.orderId);
    });
  }

  String _formatCurrency(double value) {
    return 'Rp ${value.toStringAsFixed(0)}';
  }

  Future<void> _handleSubmitOrder() async {
    final provider = context.read<OrderProvider>();

    final result = await provider.submitOrder(widget.orderId);

    if (!mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order berhasil disubmit')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.submitErrorMessage ?? 'Gagal submit order'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    final order = provider.selectedOrder;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Order'),
      ),
      body: Builder(
        builder: (context) {
          if (provider.isLoadingDetail && order == null) {
            return const Center(child: CircularProgressIndicator());
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

          if (order == null) {
            return const Center(
              child: Text('Detail order tidak ditemukan'),
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
                        order.orderCode,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('Project: ${order.project?.title ?? '-'}'),
                      Text('Status: ${order.status}'),
                      Text('Order Type: ${order.orderType}'),
                      Text('Delivery Method: ${order.deliveryMethod}'),
                      Text('Delivery Address: ${order.deliveryAddress ?? '-'}'),
                      const SizedBox(height: 8),
                      Text('Subtotal: ${_formatCurrency(order.subtotal)}'),
                      Text(
                          'Shipping Fee: ${_formatCurrency(order.shippingFee)}'),
                      Text('Total: ${_formatCurrency(order.totalAmount)}'),
                      const SizedBox(height: 8),
                      Text('Payment Type: ${order.paymentType ?? '-'}'),
                      Text(
                          'Transaction Status: ${order.transactionStatus ?? '-'}'),
                      Text('Paid At: ${order.paidAt ?? '-'}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (order.status == 'draft')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        provider.isSubmitting ? null : _handleSubmitOrder,
                    child: provider.isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit Order'),
                  ),
                ),
              if (order.status == 'draft') const SizedBox(height: 16),
              const Text(
                'Item Order',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (order.items.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Belum ada item order'),
                  ),
                )
              else
                ...order.items.map(
                  (item) => Card(
                    child: ListTile(
                      title: Text(item.nameSnapshot),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Text('Qty: ${item.qty}'),
                          Text(
                              'Unit Price: ${_formatCurrency(item.unitPrice)}'),
                          Text(
                              'Line Total: ${_formatCurrency(item.lineTotal)}'),
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
