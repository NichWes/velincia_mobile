import 'package:flutter/material.dart';
import '../data/order_service.dart';
import '../models/order_model.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();

  bool isLoadingList = false;
  bool isLoadingDetail = false;
  bool isSubmitting = false;

  List<OrderModel> orders = [];
  OrderModel? selectedOrder;

  String? listErrorMessage;
  String? detailErrorMessage;
  String? submitErrorMessage;

  Future<void> fetchOrders() async {
    try {
      isLoadingList = true;
      listErrorMessage = null;
      notifyListeners();

      orders = await _orderService.getOrders();
    } catch (e) {
      listErrorMessage = 'Gagal memuat order: $e';
    } finally {
      isLoadingList = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrderDetail(int id) async {
    try {
      isLoadingDetail = true;
      detailErrorMessage = null;
      notifyListeners();

      selectedOrder = await _orderService.getOrderDetail(id);
    } catch (e) {
      detailErrorMessage = 'Gagal memuat detail order: $e';
    } finally {
      isLoadingDetail = false;
      notifyListeners();
    }
  }

  Future<OrderModel?> createOrder({
    required int projectId,
    required String orderType,
    required String deliveryMethod,
    String? deliveryAddress,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      isSubmitting = true;
      submitErrorMessage = null;
      notifyListeners();

      final order = await _orderService.createOrder(
        projectId: projectId,
        orderType: orderType,
        deliveryMethod: deliveryMethod,
        deliveryAddress: deliveryAddress,
        items: items,
      );

      selectedOrder = order;
      return order;
    } catch (e) {
      submitErrorMessage = 'Gagal membuat order: $e';
      return null;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<OrderModel?> submitOrder(int orderId) async {
    try {
      isSubmitting = true;
      submitErrorMessage = null;
      notifyListeners();

      final order = await _orderService.submitOrder(orderId);
      selectedOrder = order;
      return order;
    } catch (e) {
      submitErrorMessage = 'Gagal submit order: $e';
      return null;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  void clearSelectedOrder() {
    selectedOrder = null;
    detailErrorMessage = null;
    notifyListeners();
  }
}
