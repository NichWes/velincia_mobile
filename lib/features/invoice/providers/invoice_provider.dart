import 'dart:io';

import 'package:flutter/material.dart';
import '../data/invoice_service.dart';
import '../models/invoice_model.dart';

class InvoiceProvider extends ChangeNotifier {
  final InvoiceService _service = InvoiceService();

  bool isLoading = false;
  bool isGenerating = false;
  bool isDownloading = false;

  InvoiceModel? invoice;
  String? errorMessage;
  File? downloadedFile;

  Future<void> fetchInvoiceByOrder(int orderId) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      invoice = await _service.getInvoiceByOrder(orderId);
    } catch (e) {
      errorMessage = 'Gagal memuat invoice: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<InvoiceModel?> generateInvoice(int orderId) async {
    try {
      isGenerating = true;
      errorMessage = null;
      notifyListeners();

      invoice = await _service.generateInvoice(orderId);
      return invoice;
    } catch (e) {
      errorMessage = 'Gagal generate invoice: $e';
      return null;
    } finally {
      isGenerating = false;
      notifyListeners();
    }
  }

  Future<File?> downloadInvoice() async {
    if (invoice == null) return null;

    try {
      isDownloading = true;
      errorMessage = null;
      notifyListeners();

      downloadedFile = await _service.downloadInvoice(
        invoiceId: invoice!.id,
        invoiceNumber: invoice!.invoiceNumber,
      );

      return downloadedFile;
    } catch (e) {
      errorMessage = 'Gagal download invoice: $e';
      return null;
    } finally {
      isDownloading = false;
      notifyListeners();
    }
  }
}
