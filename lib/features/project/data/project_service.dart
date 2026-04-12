import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/project_model.dart';
import '../models/project_item_model.dart';
import '../models/project_estimate_model.dart';
import '../models/project_item_model.dart';

class ProjectService {
  final ApiClient _apiClient = ApiClient();

  Future<List<ProjectModel>> getProjects() async {
    final response = await _apiClient.dio.get(ApiEndpoints.projects);
    final data = response.data;

    if (data is List) {
      return data.map((e) => ProjectModel.fromJson(e)).toList();
    }

    throw Exception('Format list project tidak valid');
  }

  Future<ProjectModel> getProjectDetail(int id) async {
    final response = await _apiClient.dio.get(ApiEndpoints.projectDetail(id));
    final data = response.data;

    if (data is Map<String, dynamic>) {
      return ProjectModel.fromJson(data);
    }

    throw Exception('Format detail project tidak valid');
  }

  Future<ProjectEstimateModel> getProjectEstimate(int projectId) async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.projectEstimate(projectId),
    );

    final data = response.data;

    if (data is Map<String, dynamic>) {
      return ProjectEstimateModel.fromJson(data);
    }

    throw Exception('Format estimate project tidak valid');
  }

  Future<ProjectModel> createProject({
    required String title,
    String? projectType,
    double? budgetTarget,
    String? notes,
  }) async {
    final payload = <String, dynamic>{
      'title': title,
    };

    if (projectType != null && projectType.isNotEmpty) {
      payload['project_type'] = projectType;
    }

    if (budgetTarget != null) {
      payload['budget_target'] = budgetTarget;
    }

    if (notes != null && notes.isNotEmpty) {
      payload['notes'] = notes;
    }

    final response = await _apiClient.dio.post(
      ApiEndpoints.projects,
      data: payload,
    );

    final data = response.data;

    if (data is Map<String, dynamic> && data['project'] != null) {
      return ProjectModel.fromJson(data['project']);
    }

    throw Exception('Format response create project tidak valid');
  }

  Future<ProjectItemModel> addProjectItem({
    required int projectId,
    int? materialId,
    String? customName,
    required int qtyNeeded,
    int? qtyPurchased,
    String? status,
    String? notes,
  }) async {
    final payload = <String, dynamic>{
      'qty_needed': qtyNeeded,
    };

    if (materialId != null) payload['material_id'] = materialId;
    if (customName != null && customName.isNotEmpty) {
      payload['custom_name'] = customName;
    }
    if (qtyPurchased != null) payload['qty_purchased'] = qtyPurchased;
    if (status != null && status.isNotEmpty) payload['status'] = status;
    if (notes != null && notes.isNotEmpty) payload['notes'] = notes;

    final response = await _apiClient.dio.post(
      ApiEndpoints.projectItems(projectId),
      data: payload,
    );

    final data = response.data;

    if (data is Map<String, dynamic> && data['item'] != null) {
      return ProjectItemModel.fromJson(data['item']);
    }

    throw Exception('Format response add item tidak valid');
  }
}
