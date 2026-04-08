import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/project_model.dart';

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
}
