import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/order_model.dart';
import 'package:dio/dio.dart';

class OrderService {
  final ApiClient _apiClient = ApiClient();

  Future<List<OrderModel>> getOrders() async {
    final response = await _apiClient.dio.get(ApiEndpoints.orders);
    final data = response.data;

    if (data is List) {
      return data.map((e) => OrderModel.fromJson(e)).toList();
    }

    throw Exception('Format list order tidak valid');
  }

  Future<OrderModel> getOrderDetail(int id) async {
    final response = await _apiClient.dio.get(ApiEndpoints.orderDetail(id));
    final data = response.data;

    if (data is Map<String, dynamic>) {
      return OrderModel.fromJson(data);
    }

    throw Exception('Format detail order tidak valid');
  }

  Future<OrderModel> createOrder({
    required int projectId,
    required String orderType,
    required String deliveryMethod,
    String? deliveryAddress,
    required List<Map<String, dynamic>> items,
  }) async {
    final payload = <String, dynamic>{
      'project_id': projectId,
      'order_type': orderType,
      'delivery_method': deliveryMethod,
      'items': items,
    };

    if (deliveryMethod == 'delivery' &&
        deliveryAddress != null &&
        deliveryAddress.isNotEmpty) {
      payload['delivery_address'] = deliveryAddress;
    }

    final response = await _apiClient.dio.post(
      ApiEndpoints.orders,
      data: payload,
    );

    final data = response.data;

    if (data is Map<String, dynamic>) {
      final orderJson = data['order'] ?? data;
      if (orderJson is Map<String, dynamic>) {
        return OrderModel.fromJson(orderJson);
      }
    }

    throw Exception('Format create order tidak valid');
  }

  Future<OrderModel> submitOrder(int orderId) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.submitOrder(orderId),
      );

      final data = response.data;

      if (data is Map<String, dynamic>) {
        final orderJson = data['order'] ?? data;
        if (orderJson is Map<String, dynamic>) {
          return OrderModel.fromJson(orderJson);
        }
      }

      throw Exception('Format submit order tidak valid');
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map<String, dynamic>) {
        final message = data['message'] ?? 'Gagal submit order';
        throw Exception(message);
      }

      throw Exception('Gagal submit order: ${e.message}');
    }
  }
}
