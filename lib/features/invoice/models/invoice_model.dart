class InvoiceModel {
  final int id;
  final int orderId;
  final String invoiceNumber;
  final String? pdfUrl;
  final String? generatedAt;
  final String? downloadUrl;

  InvoiceModel({
    required this.id,
    required this.orderId,
    required this.invoiceNumber,
    this.pdfUrl,
    this.generatedAt,
    this.downloadUrl,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json,
      {String? downloadUrl}) {
    return InvoiceModel(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      invoiceNumber: json['invoice_number']?.toString() ?? '-',
      pdfUrl: json['pdf_url']?.toString(),
      generatedAt: json['generated_at']?.toString(),
      downloadUrl: downloadUrl,
    );
  }
}
