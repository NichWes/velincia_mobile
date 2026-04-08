import 'package:flutter/material.dart';
import '../data/project_service.dart';
import '../models/project_model.dart';

class ProjectProvider extends ChangeNotifier {
  final ProjectService _projectService = ProjectService();

  bool isLoadingList = false;
  bool isLoadingDetail = false;

  List<ProjectModel> projects = [];
  ProjectModel? selectedProject;

  String? listErrorMessage;
  String? detailErrorMessage;

  Future<void> fetchProjects() async {
    try {
      isLoadingList = true;
      listErrorMessage = null;
      notifyListeners();

      projects = await _projectService.getProjects();
    } catch (e) {
      listErrorMessage = 'Gagal memuat project: $e';
    } finally {
      isLoadingList = false;
      notifyListeners();
    }
  }

  Future<void> fetchProjectDetail(int id) async {
    try {
      isLoadingDetail = true;
      detailErrorMessage = null;
      notifyListeners();

      selectedProject = await _projectService.getProjectDetail(id);
    } catch (e) {
      detailErrorMessage = 'Gagal memuat detail project: $e';
    } finally {
      isLoadingDetail = false;
      notifyListeners();
    }
  }

  void clearSelectedProject() {
    selectedProject = null;
    detailErrorMessage = null;
    notifyListeners();
  }
}
