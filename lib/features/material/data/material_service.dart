import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/material_model.dart';

class MaterialService {
  final ApiClient _apiClient = ApiClient();

  Future<List<MaterialModel>> getMaterials() async {
    final response = await _apiClient.dio.get('/materials');
    final data = response.data;

    if (data is List) {
      return data.map((e) => MaterialModel.fromJson(e)).toList();
    }

    throw Exception('Format list material tidak valid');
  }
}
