class OrderModel {
  final int id;
  final int projectId;
  final int userId;
  final String orderCode;
  final String orderType;
  final String status;
  final String deliveryMethod;
  final String? deliveryAddress;
  final double subtotal;
  final double shippingFee;
  final double totalAmount;
  final String? paymentUrl;
  final String? paymentToken;
  final String? transactionStatus;
  final String? paymentType;
  final String? fraudStatus;
  final String? paidAt;
  final String? createdAt;
  final OrderProjectModel? project;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.orderCode,
    required this.orderType,
    required this.status,
    required this.deliveryMethod,
    this.deliveryAddress,
    required this.subtotal,
    required this.shippingFee,
    required this.totalAmount,
    this.paymentUrl,
    this.paymentToken,
    this.transactionStatus,
    this.paymentType,
    this.fraudStatus,
    this.paidAt,
    this.createdAt,
    this.project,
    this.items = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      projectId: json['project_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      orderCode: json['order_code']?.toString() ?? '-',
      orderType: json['order_type']?.toString() ?? '-',
      status: json['status']?.toString() ?? '-',
      deliveryMethod: json['delivery_method']?.toString() ?? '-',
      deliveryAddress: json['delivery_address']?.toString(),
      subtotal: double.tryParse(json['subtotal'].toString()) ?? 0,
      shippingFee: double.tryParse(json['shipping_fee'].toString()) ?? 0,
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0,
      paymentUrl: json['payment_url']?.toString(),
      paymentToken: json['payment_token']?.toString(),
      transactionStatus: json['transaction_status']?.toString(),
      paymentType: json['payment_type']?.toString(),
      fraudStatus: json['fraud_status']?.toString(),
      paidAt: json['paid_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      project: json['project'] != null
          ? OrderProjectModel.fromJson(json['project'])
          : null,
      items: json['items'] is List
          ? (json['items'] as List)
              .map((e) => OrderItemModel.fromJson(e))
              .toList()
          : [],
    );
  }
}

class OrderProjectModel {
  final int id;
  final String title;
  final String? projectType;
  final String? status;

  OrderProjectModel({
    required this.id,
    required this.title,
    this.projectType,
    this.status,
  });

  factory OrderProjectModel.fromJson(Map<String, dynamic> json) {
    return OrderProjectModel(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? '-',
      projectType: json['project_type']?.toString(),
      status: json['status']?.toString(),
    );
  }
}

class OrderItemModel {
  final int id;
  final int orderId;
  final int? projectItemId;
  final int? materialId;
  final String nameSnapshot;
  final int qty;
  final double unitPrice;
  final double lineTotal;

  OrderItemModel({
    required this.id,
    required this.orderId,
    this.projectItemId,
    this.materialId,
    required this.nameSnapshot,
    required this.qty,
    required this.unitPrice,
    required this.lineTotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      projectItemId: json['project_item_id'],
      materialId: json['material_id'],
      nameSnapshot: json['name_snapshot']?.toString() ?? '-',
      qty: json['qty'] ?? 0,
      unitPrice: double.tryParse(json['unit_price'].toString()) ?? 0,
      lineTotal: double.tryParse(json['line_total'].toString()) ?? 0,
    );
  }
}
