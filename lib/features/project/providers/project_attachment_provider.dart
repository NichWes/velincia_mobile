import 'dart:io';
import 'package:flutter/material.dart';
import '../models/project_attachment_model.dart';
import '../data/project_attachment_service.dart';

class ProjectAttachmentProvider extends ChangeNotifier {
  final _service = ProjectAttachmentService();

  List<ProjectAttachment> attachments = [];

  bool isLoading = false;
  bool isUploading = false;
  bool isDeleting = false;
  bool isOpening = false;

  String? errorMessage;

  Future<void> fetchAttachments(int projectId) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final data = await _service.getAttachments(projectId);
      attachments = data
          .map<ProjectAttachment>((e) => ProjectAttachment.fromJson(e))
          .toList();
    } catch (e) {
      errorMessage = _extractApiError(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> upload(int projectId, File file) async {
    try {
      isUploading = true;
      errorMessage = null;
      notifyListeners();

      final data = await _service.uploadAttachment(projectId, file);
      attachments.insert(0, ProjectAttachment.fromJson(data));
      return true;
    } catch (e) {
      errorMessage = _extractApiError(e);
      return false;
    } finally {
      isUploading = false;
      notifyListeners();
    }
  }

  Future<bool> delete(int projectId, int attachmentId) async {
    try {
      isDeleting = true;
      errorMessage = null;
      notifyListeners();

      await _service.deleteAttachment(projectId, attachmentId);
      attachments.removeWhere((e) => e.id == attachmentId);
      return true;
    } catch (e) {
      errorMessage = _extractApiError(e);
      return false;
    } finally {
      isDeleting = false;
      notifyListeners();
    }
  }

  String _extractApiError(dynamic error) {
    try {
      final response = error.response;
      final data = response?.data;

      if (data is Map<String, dynamic>) {
        if (data['errors'] is Map) {
          final errors = data['errors'] as Map;
          if (errors.isNotEmpty) {
            final firstValue = errors.values.first;
            if (firstValue is List && firstValue.isNotEmpty) {
              return firstValue.first.toString();
            }
            return firstValue.toString();
          }
        }

        if (data['message'] != null) {
          return data['message'].toString();
        }
      }

      return 'Terjadi kesalahan. Silakan coba lagi.';
    } catch (_) {
      return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  Future<File?> downloadToLocal(ProjectAttachment attachment) async {
    try {
      isOpening = true;
      errorMessage = null;
      notifyListeners();

      return await _service.downloadToLocal(
        fileUrl: attachment.fileUrl,
        fileName: attachment.fileName,
      );
    } catch (e) {
      errorMessage = _extractApiError(e);
      return null;
    } finally {
      isOpening = false;
      notifyListeners();
    }
  }
}
