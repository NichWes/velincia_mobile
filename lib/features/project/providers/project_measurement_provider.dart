import 'package:flutter/material.dart';
import '../data/project_measurement_service.dart';
import '../models/project_measurement_model.dart';

class ProjectMeasurementProvider extends ChangeNotifier {
  final ProjectMeasurementService _service = ProjectMeasurementService();

  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;

  List<ProjectMeasurementModel> measurements = [];
  ProjectMeasurementSummary summary = ProjectMeasurementSummary();

  Future<void> fetchMeasurements(int projectId) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final result = await _service.getMeasurements(projectId);
      measurements = result.measurements;
      summary = result.summary;
    } catch (e) {
      errorMessage = 'Gagal memuat ukuran project: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveMeasurement({
    required int projectId,
    required String keyName,
    required double value,
    String unit = 'cm',
  }) async {
    try {
      isSaving = true;
      errorMessage = null;
      notifyListeners();

      await _service.saveMeasurement(
        projectId: projectId,
        keyName: keyName,
        value: value,
        unit: unit,
      );

      await fetchMeasurements(projectId);
      return true;
    } catch (e) {
      errorMessage = 'Gagal menyimpan ukuran: $e';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
