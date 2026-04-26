import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/invoice_model.dart';

class InvoiceService {
  final ApiClient _apiClient = ApiClient();

  Future<InvoiceModel?> getInvoiceByOrder(int orderId) async {
    try {
      final response =
          await _apiClient.dio.get(ApiEndpoints.orderInvoice(orderId));
      final data = response.data;

      if (data is Map && data['invoice'] != null) {
        return InvoiceModel.fromJson(
          Map<String, dynamic>.from(data['invoice']),
          downloadUrl: data['download_url']?.toString(),
        );
      }

      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<InvoiceModel> generateInvoice(int orderId) async {
    final response =
        await _apiClient.dio.post(ApiEndpoints.generateInvoice(orderId));
    final data = response.data;

    return InvoiceModel.fromJson(
      Map<String, dynamic>.from(data['invoice']),
      downloadUrl: data['download_url']?.toString(),
    );
  }

  Future<File> downloadInvoice({
    required int invoiceId,
    required String invoiceNumber,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/$invoiceNumber.pdf';

    await _apiClient.dio.download(
      ApiEndpoints.downloadInvoice(invoiceId),
      filePath,
    );

    return File(filePath);
  }
}
