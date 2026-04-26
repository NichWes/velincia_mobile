import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../invoice/providers/invoice_provider.dart';
import '../../invoice/screens/invoice_preview_screen.dart';
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

class _OrderDetailScreenState extends State<OrderDetailScreen>
    with WidgetsBindingObserver {
  bool _isOpeningPayment = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    Future.microtask(() {
      _loadAll();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadAll();
    }
  }

  Future<void> _loadAll() async {
    await context.read<OrderProvider>().fetchOrderDetail(widget.orderId);

    if (!mounted) return;

    final order = context.read<OrderProvider>().selectedOrder;
    if (order != null && _canHaveInvoice(order.status)) {
      await context.read<InvoiceProvider>().fetchInvoiceByOrder(widget.orderId);
    }
  }

  Future<void> _loadOrderDetail() async {
    await context.read<OrderProvider>().fetchOrderDetail(widget.orderId);

    if (!mounted) return;

    final order = context.read<OrderProvider>().selectedOrder;
    if (order != null && _canHaveInvoice(order.status)) {
      await context.read<InvoiceProvider>().fetchInvoiceByOrder(widget.orderId);
    }
  }

  bool _canHaveInvoice(String status) {
    return [
      'paid',
      'processing',
      'shipped',
      'ready_pickup',
      'completed',
    ].contains(status);
  }

  String _formatCurrency(double value) {
    return 'Rp ${value.toStringAsFixed(0)}';
  }

  String _formatStatusLabel(String status) {
    return status.replaceAll('_', ' ').toUpperCase();
  }

  String _formatDateTime(String? value) {
    if (value == null || value.isEmpty) return '-';

    try {
      final date = DateTime.parse(value).toLocal();
      return '${date.day.toString().padLeft(2, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.year} '
          '${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return value;
    }
  }

  Color _statusBg(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return const Color(0xFFE5E7EB);
      case 'waiting_admin':
        return const Color(0xFFFFEDD5);
      case 'waiting_payment':
        return const Color(0xFFFEF3C7);
      case 'paid':
        return const Color(0xFFDBEAFE);
      case 'processing':
        return const Color(0xFFE0E7FF);
      case 'shipped':
        return const Color(0xFFCFFAFE);
      case 'ready_pickup':
        return const Color(0xFFFCE7F3);
      case 'completed':
        return const Color(0xFFDCFCE7);
      case 'cancelled':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color _statusText(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return const Color(0xFF374151);
      case 'waiting_admin':
        return const Color(0xFFEA580C);
      case 'waiting_payment':
        return const Color(0xFFD97706);
      case 'paid':
        return const Color(0xFF2563EB);
      case 'processing':
        return const Color(0xFF4F46E5);
      case 'shipped':
        return const Color(0xFF0891B2);
      case 'ready_pickup':
        return const Color(0xFFBE185D);
      case 'completed':
        return const Color(0xFF15803D);
      case 'cancelled':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF374151);
    }
  }

  Future<void> _handleSubmitOrder() async {
    final provider = context.read<OrderProvider>();
    final result = await provider.submitOrder(widget.orderId);

    if (!mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order berhasil disubmit')),
      );
      await _loadAll();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.submitErrorMessage ?? 'Gagal submit order'),
        ),
      );
    }
  }

  Future<void> _openPayment(String url) async {
    setState(() {
      _isOpeningPayment = true;
    });

    try {
      final uri = Uri.parse(url);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Membuka halaman pembayaran...')),
        );
      }

      final success = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak bisa membuka payment')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka payment: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningPayment = false;
        });
      }
    }
  }

  Future<void> _handleGenerateInvoice() async {
    final invoiceProvider = context.read<InvoiceProvider>();

    final result = await invoiceProvider.generateInvoice(widget.orderId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result != null
              ? 'Invoice berhasil dibuat'
              : invoiceProvider.errorMessage ?? 'Gagal membuat invoice',
        ),
      ),
    );
  }

  Future<void> _handlePreviewInvoice() async {
    final invoiceProvider = context.read<InvoiceProvider>();

    final File? file = await invoiceProvider.downloadInvoice();

    if (!mounted) return;

    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(invoiceProvider.errorMessage ?? 'Gagal membuka invoice'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InvoicePreviewScreen(
          file: file,
          title: invoiceProvider.invoice?.invoiceNumber ?? 'Invoice',
        ),
      ),
    );
  }

  Future<void> _handleOpenInvoiceExternal() async {
    final invoiceProvider = context.read<InvoiceProvider>();

    final File? file = await invoiceProvider.downloadInvoice();

    if (!mounted) return;

    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(invoiceProvider.errorMessage ?? 'Gagal membuka invoice'),
        ),
      );
      return;
    }

    await OpenFilex.open(file.path);
  }

  Widget _timelineStep({
    required String label,
    required bool isActive,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color:
                    isActive ? const Color(0xFF22C55E) : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 34,
                color:
                    isActive ? const Color(0xFF22C55E) : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? Colors.black : Colors.grey.shade500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline(String status) {
    final steps = [
      'draft',
      'waiting_admin',
      'waiting_payment',
      'paid',
      'processing',
    ];

    List<String> finalSteps;
    if (status == 'completed') {
      finalSteps = [...steps, 'completed'];
    } else if (status == 'cancelled') {
      finalSteps = [...steps, 'cancelled'];
    } else if (status == 'shipped') {
      finalSteps = [...steps, 'shipped'];
    } else if (status == 'ready_pickup') {
      finalSteps = [...steps, 'ready_pickup'];
    } else {
      finalSteps = steps;
    }

    int currentIndex = finalSteps.indexOf(status);
    if (currentIndex == -1) {
      currentIndex = steps.indexOf(status);
    }

    return Column(
      children: finalSteps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isActive = index <= currentIndex && currentIndex != -1;

        return _timelineStep(
          label: step.replaceAll('_', ' ').toUpperCase(),
          isActive: isActive,
          isLast: index == finalSteps.length - 1,
        );
      }).toList(),
    );
  }

  Widget _infoTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
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

  Widget _invoiceSection(String orderStatus) {
    if (!_canHaveInvoice(orderStatus)) {
      return const SizedBox.shrink();
    }

    return Consumer<InvoiceProvider>(
      builder: (context, invoiceProvider, _) {
        final invoice = invoiceProvider.invoice;

        return Container(
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
              const Text(
                'Invoice',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              if (invoiceProvider.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: LinearProgressIndicator(),
                )
              else if (invoice == null) ...[
                Text(
                  'Invoice belum tersedia. Kamu bisa generate invoice setelah order sudah dibayar.',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      iconColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: invoiceProvider.isGenerating
                        ? null
                        : _handleGenerateInvoice,
                    icon: const Icon(Icons.receipt_long_rounded),
                    label: Text(
                      invoiceProvider.isGenerating
                          ? 'Membuat invoice...'
                          : 'Generate Invoice',
                    ),
                  ),
                ),
              ] else ...[
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.description_rounded,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        invoice.invoiceNumber,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                if (invoice.generatedAt != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Dibuat: ${_formatDateTime(invoice.generatedAt)}',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: invoiceProvider.isDownloading
                            ? null
                            : _handlePreviewInvoice,
                        icon: const Icon(Icons.visibility_rounded),
                        label: const Text('Preview'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          iconColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: invoiceProvider.isDownloading
                            ? null
                            : _handleOpenInvoiceExternal,
                        icon: const Icon(Icons.download_rounded),
                        label: Text(
                          invoiceProvider.isDownloading
                              ? 'Loading...'
                              : 'Buka PDF',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    final order = provider.selectedOrder;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('Detail Order'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Builder(
        builder: (context) {
          if (provider.isLoadingDetail && order == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.detailErrorMessage != null && order == null) {
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

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: _loadOrderDetail,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
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
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  order.orderCode,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _statusBg(order.status),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  _formatStatusLabel(order.status),
                                  style: TextStyle(
                                    color: _statusText(order.status),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Informasi Order',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: Colors.grey.shade900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _infoTile('Project', order.project?.title ?? '-'),
                              _infoTile('Order Type', order.orderType),
                              _infoTile('Delivery', order.deliveryMethod),
                              _infoTile('Alamat', order.deliveryAddress ?? '-'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Informasi Pembayaran',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: Colors.grey.shade900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _infoTile(
                                'Subtotal',
                                _formatCurrency(order.subtotal),
                              ),
                              _infoTile(
                                'Shipping Fee',
                                _formatCurrency(order.shippingFee),
                              ),
                              _infoTile(
                                'Total',
                                _formatCurrency(order.totalAmount),
                              ),
                              _infoTile(
                                'Payment Type',
                                order.paymentType ?? '-',
                              ),
                              _infoTile(
                                'Transaction',
                                order.transactionStatus ?? '-',
                              ),
                              _infoTile(
                                'Paid At',
                                _formatDateTime(order.paidAt),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _invoiceSection(order.status),
                    if (_canHaveInvoice(order.status))
                      const SizedBox(height: 16),
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
                          const Text(
                            'Status Timeline',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildTimeline(order.status),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (order.status == 'draft')
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed:
                              provider.isSubmitting ? null : _handleSubmitOrder,
                          child: provider.isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Submit Order'),
                        ),
                      ),
                    if (order.status == 'draft') const SizedBox(height: 16),
                    if (order.paymentUrl != null &&
                        order.status == 'waiting_payment')
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: const Color(0xFF16A34A),
                            foregroundColor: Colors.white,
                            iconColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: _isOpeningPayment
                              ? null
                              : () => _openPayment(order.paymentUrl!),
                          icon: const Icon(Icons.payments_rounded),
                          label: const Text('Bayar Sekarang'),
                        ),
                      ),
                    if (order.paymentUrl != null &&
                        order.status == 'waiting_payment')
                      const SizedBox(height: 16),
                    const Text(
                      'Item Order',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (order.items.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Belum ada item order'),
                      )
                    else
                      ...order.items.map(
                        (item) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.035),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.nameSnapshot,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    _infoTile('Qty', '${item.qty}'),
                                    _infoTile(
                                      'Unit Price',
                                      _formatCurrency(item.unitPrice),
                                    ),
                                    _infoTile(
                                      'Line Total',
                                      _formatCurrency(item.lineTotal),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (_isOpeningPayment)
                Container(
                  color: Colors.black.withOpacity(0.18),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 14),
                        Text(
                          'Membuka halaman pembayaran...',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
