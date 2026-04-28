import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/project_measurement_model.dart';

class ProjectMeasurementResponse {
  final List<ProjectMeasurementModel> measurements;
  final ProjectMeasurementSummary summary;

  ProjectMeasurementResponse({
    required this.measurements,
    required this.summary,
  });
}

class ProjectMeasurementService {
  final ApiClient _apiClient = ApiClient();

  Future<ProjectMeasurementResponse> getMeasurements(int projectId) async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.projectMeasurements(projectId),
    );

    final data = response.data;
    final list = (data['data'] as List? ?? [])
        .map((e) => ProjectMeasurementModel.fromJson(e))
        .toList();

    return ProjectMeasurementResponse(
      measurements: list,
      summary: ProjectMeasurementSummary.fromJson(data['summary']),
    );
  }

  Future<ProjectMeasurementResponse> saveMeasurement({
    required int projectId,
    required String keyName,
    required double value,
    String unit = 'cm',
  }) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.projectMeasurements(projectId),
      data: {
        'key': keyName,
        'value': value,
        'unit': unit,
      },
    );

    final data = response.data;

    return ProjectMeasurementResponse(
      measurements: data['data'] == null
          ? []
          : [ProjectMeasurementModel.fromJson(data['data'])],
      summary: ProjectMeasurementSummary.fromJson(data['summary']),
    );
  }
}
