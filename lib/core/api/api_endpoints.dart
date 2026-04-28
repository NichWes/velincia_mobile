class ApiEndpoints {
  static const String register = '/register';
  static const String login = '/login';
  static const String me = '/me';
  static const String logout = '/logout';

  static const String projects = '/projects';

  static String projectDetail(int id) => '/projects/$id';
  static String projectItems(int projectId) => '/projects/$projectId/items';
  static String projectEstimate(int projectId) =>
      '/projects/$projectId/estimate';

  static const String orders = '/orders';
  static String orderDetail(int id) => '/orders/$id';
  static String submitOrder(int id) => '/orders/$id/submit';

  static String orderInvoice(int orderId) => '/orders/$orderId/invoice';
  static String generateInvoice(int orderId) =>
      '/orders/$orderId/generate-invoice';
  static String downloadInvoice(int invoiceId) =>
      '/invoices/$invoiceId/download';
  static String projectMeasurements(int projectId) =>
      '/projects/$projectId/measurements';
}
