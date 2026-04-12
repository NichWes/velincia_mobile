import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../project/providers/project_provider.dart';
import '../providers/order_provider.dart';
import 'order_detail_screen.dart';

class CreateOrderScreen extends StatefulWidget {
  final int projectId;

  const CreateOrderScreen({
    super.key,
    required this.projectId,
  });

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  String _orderType = 'partial';
  String _deliveryMethod = 'pickup';
  final _deliveryAddressController = TextEditingController();

  final Map<int, TextEditingController> _qtyControllers = {};

  @override
  void initState() {
    super.initState();
    final project = context.read<ProjectProvider>().selectedProject;
    if (project != null) {
      for (final item in project.items) {
        _qtyControllers[item.id] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _qtyControllers.values) {
      controller.dispose();
    }
    _deliveryAddressController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final project = context.read<ProjectProvider>().selectedProject;
    final orderProvider = context.read<OrderProvider>();

    if (project == null) return;

    final List<Map<String, dynamic>> itemsPayload = [];

    for (final item in project.items) {
      final controller = _qtyControllers[item.id];
      final text = controller?.text.trim() ?? '';

      if (text.isEmpty) continue;

      final qty = int.tryParse(text);
      if (qty == null || qty <= 0) continue;

      itemsPayload.add({
        'project_item_id': item.id,
        'qty': qty,
      });
    }

    if (itemsPayload.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi minimal 1 qty item untuk dipesan')),
      );
      return;
    }

    final order = await orderProvider.createOrder(
      projectId: widget.projectId,
      orderType: _orderType,
      deliveryMethod: _deliveryMethod,
      deliveryAddress: _deliveryMethod == 'delivery'
          ? _deliveryAddressController.text.trim()
          : null,
      items: itemsPayload,
    );

    if (!mounted) return;

    if (order != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: orderProvider,
            child: OrderDetailScreen(orderId: order.id),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(orderProvider.submitErrorMessage ?? 'Gagal membuat order'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = context.watch<ProjectProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final project = projectProvider.selectedProject;

    if (project == null) {
      return const Scaffold(
        body: Center(child: Text('Project tidak ditemukan')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Order'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<String>(
                value: _orderType,
                decoration: const InputDecoration(
                  labelText: 'Order Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'partial', child: Text('Partial')),
                  DropdownMenuItem(value: 'full', child: Text('Full')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _orderType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _deliveryMethod,
                decoration: const InputDecoration(
                  labelText: 'Delivery Method',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'pickup', child: Text('Pickup')),
                  DropdownMenuItem(value: 'delivery', child: Text('Delivery')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _deliveryMethod = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              if (_deliveryMethod == 'delivery')
                TextFormField(
                  controller: _deliveryAddressController,
                  decoration: const InputDecoration(
                    labelText: 'Delivery Address',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_deliveryMethod == 'delivery' &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Alamat pengiriman wajib diisi';
                    }
                    return null;
                  },
                ),
              if (_deliveryMethod == 'delivery') const SizedBox(height: 16),
              const Text(
                'Pilih Qty Item',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...project.items.map((item) {
                final remaining = item.qtyNeeded - item.qtyPurchased;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.displayName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('Qty needed: ${item.qtyNeeded}'),
                        Text('Qty purchased: ${item.qtyPurchased}'),
                        Text('Sisa kebutuhan: $remaining'),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _qtyControllers[item.id],
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Qty order',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return null;
                            }

                            final qty = int.tryParse(value.trim());
                            if (qty == null) {
                              return 'Harus angka';
                            }

                            if (qty < 1) {
                              return 'Minimal 1';
                            }

                            if (_orderType == 'full' && qty != remaining) {
                              return 'Untuk full harus sama dengan sisa kebutuhan ($remaining)';
                            }

                            if (_orderType == 'partial' && qty > remaining) {
                              return 'Qty melebihi sisa kebutuhan ($remaining)';
                            }

                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed:
                      orderProvider.isSubmitting ? null : _handleCreateOrder,
                  child: orderProvider.isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Buat Order'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
