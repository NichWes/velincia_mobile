import 'package:flutter/material.dart';
import '../data/project_service.dart';
import '../models/project_model.dart';

class ProjectProvider extends ChangeNotifier {
  final ProjectService _projectService = ProjectService();

  bool isLoadingList = false;
  bool isLoadingDetail = false;
  bool isSubmitting = false;

  List<ProjectModel> projects = [];
  ProjectModel? selectedProject;

  String? listErrorMessage;
  String? detailErrorMessage;
  String? submitErrorMessage;

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

  Future<ProjectModel?> createProject({
    required String title,
    String? projectType,
    double? budgetTarget,
    String? notes,
  }) async {
    try {
      isSubmitting = true;
      submitErrorMessage = null;
      notifyListeners();

      final project = await _projectService.createProject(
        title: title,
        projectType: projectType,
        budgetTarget: budgetTarget,
        notes: notes,
      );

      projects.insert(0, project);
      return project;
    } catch (e) {
      submitErrorMessage = 'Gagal membuat project: $e';
      return null;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> addProjectItem({
    required int projectId,
    int? materialId,
    String? customName,
    required int qtyNeeded,
    int? qtyPurchased,
    String? status,
    String? notes,
  }) async {
    try {
      isSubmitting = true;
      submitErrorMessage = null;
      notifyListeners();

      await _projectService.addProjectItem(
        projectId: projectId,
        materialId: materialId,
        customName: customName,
        qtyNeeded: qtyNeeded,
        qtyPurchased: qtyPurchased,
        status: status,
        notes: notes,
      );

      await fetchProjectDetail(projectId);
      return true;
    } catch (e) {
      submitErrorMessage = 'Gagal menambah item: $e';
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  void clearSelectedProject() {
    selectedProject = null;
    detailErrorMessage = null;
    notifyListeners();
  }
}
