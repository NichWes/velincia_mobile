import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../project/providers/project_provider.dart';
import '../../invoice/providers/invoice_provider.dart';
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

  final Map<int, int> _selectedQty = {};
  final Map<int, bool> _selectedItems = {};

  @override
  void initState() {
    super.initState();
    final project = context.read<ProjectProvider>().selectedProject;
    if (project != null) {
      for (final item in project.items) {
        final remaining = item.qtyNeeded - item.qtyPurchased;
        _selectedItems[item.id] = false;
        _selectedQty[item.id] = remaining > 0 ? 1 : 0;
      }
    }
  }

  @override
  void dispose() {
    _deliveryAddressController.dispose();
    super.dispose();
  }

  void _incrementQty(int itemId, int maxQty) {
    setState(() {
      final current = _selectedQty[itemId] ?? 1;
      if (current < maxQty) {
        _selectedQty[itemId] = current + 1;
      }
    });
  }

  void _decrementQty(int itemId) {
    setState(() {
      final current = _selectedQty[itemId] ?? 1;
      if (current > 1) {
        _selectedQty[itemId] = current - 1;
      }
    });
  }

  Future<void> _handleCreateOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final project = context.read<ProjectProvider>().selectedProject;
    final orderProvider = context.read<OrderProvider>();

    if (project == null) return;

    final List<Map<String, dynamic>> itemsPayload = [];

    for (final item in project.items) {
      if (_selectedItems[item.id] != true) continue;

      final qty = _selectedQty[item.id] ?? 0;
      if (qty <= 0) continue;

      itemsPayload.add({
        'project_item_id': item.id,
        'qty': qty,
      });
    }

    if (itemsPayload.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal 1 item untuk dipesan')),
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
      final submittedOrder = await orderProvider.submitOrder(order.id);

      if (!mounted) return;

      if (submittedOrder == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              orderProvider.submitErrorMessage ??
                  'Order dibuat, tetapi belum berhasil lanjut ke pembayaran',
            ),
          ),
        );
      }

      final finalOrder = submittedOrder ?? order;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => OrderProvider()..fetchOrderDetail(finalOrder.id),
              ),
              ChangeNotifierProvider(
                create: (_) =>
                    InvoiceProvider()..fetchInvoiceByOrder(finalOrder.id),
              ),
            ],
            child: OrderDetailScreen(orderId: finalOrder.id),
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

  String _formatCurrency(double? value) {
    if (value == null) return '-';
    return 'Rp ${value.toStringAsFixed(0)}';
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

    final availableItems =
        project.items.where((e) => (e.qtyNeeded - e.qtyPurchased) > 0).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('Buat Order & Bayar'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: const Color(0xFFF97316).withOpacity(0.35)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, color: Color(0xFFF97316)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Review Mode Midtrans: aplikasi ini menggunakan data uji coba dan pembayaran sandbox. Transaksi tidak diproses sebagai pembayaran asli.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF9A3412),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
                    Text(
                      project.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: _orderType,
                      decoration: _inputDecoration('Order Type'),
                      items: const [
                        DropdownMenuItem(
                            value: 'partial', child: Text('Partial')),
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
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: _deliveryMethod,
                      decoration: _inputDecoration('Delivery Method'),
                      items: const [
                        DropdownMenuItem(
                            value: 'pickup', child: Text('Pickup')),
                        DropdownMenuItem(
                            value: 'delivery', child: Text('Delivery')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _deliveryMethod = value;
                          });
                        }
                      },
                    ),
                    if (_deliveryMethod == 'delivery') ...[
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _deliveryAddressController,
                        decoration: _inputDecoration('Alamat Pengiriman'),
                        validator: (value) {
                          if (_deliveryMethod == 'delivery' &&
                              (value == null || value.trim().isEmpty)) {
                            return 'Alamat pengiriman wajib diisi';
                          }
                          return null;
                        },
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Pilih Item yang Mau Dibeli',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              if (availableItems.isEmpty)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Tidak ada item yang bisa dipesan'),
                )
              else
                ...availableItems.map((item) {
                  final remaining = item.qtyNeeded - item.qtyPurchased;
                  final isSelected = _selectedItems[item.id] ?? false;
                  final qty = _selectedQty[item.id] ?? 1;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFF97316)
                            : Colors.grey.shade200,
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.035),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () {
                        setState(() {
                          _selectedItems[item.id] = !isSelected;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  _selectedItems[item.id] = value ?? false;
                                });
                              },
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.displayName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _miniChip('Sisa', '$remaining'),
                                      _miniChip(
                                          'Unit', item.material?.unit ?? '-'),
                                      _miniChip(
                                        'Harga',
                                        _formatCurrency(
                                            item.material?.priceEstimate),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: isSelected
                                            ? () => _decrementQty(item.id)
                                            : null,
                                        icon: const Icon(Icons.remove),
                                      ),
                                      SizedBox(
                                        width: 28,
                                        child: Center(
                                          child: Text(
                                            '$qty',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: isSelected
                                            ? () => _incrementQty(
                                                item.id, remaining)
                                            : null,
                                        icon: const Icon(Icons.add),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                    foregroundColor: Colors.white,
                    iconColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed:
                      orderProvider.isSubmitting ? null : _handleCreateOrder,
                  icon: const Icon(Icons.shopping_cart_checkout),
                  label: orderProvider.isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Lanjut ke Pembayaran',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFF97316), width: 1.3),
      ),
    );
  }

  Widget _miniChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
