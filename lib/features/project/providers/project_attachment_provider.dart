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
      errorMessage = 'Gagal memuat attachment: $e';
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
      errorMessage = 'Gagal upload file: $e';
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
      errorMessage = 'Gagal menghapus attachment: $e';
      return false;
    } finally {
      isDeleting = false;
      notifyListeners();
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
      errorMessage = 'Gagal membuka file: $e';
      return null;
    } finally {
      isOpening = false;
      notifyListeners();
    }
  }
}
