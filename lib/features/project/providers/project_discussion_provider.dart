import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import 'package:dio/dio.dart';

class DiscussionMessage {
  final int id;
  final String message;
  final int senderId;
  final String senderName;
  final String createdAt;
  final String? fileUrl;
  final String? fileType;
  final String? fileName;

  DiscussionMessage({
    required this.id,
    required this.message,
    required this.senderId,
    required this.senderName,
    required this.createdAt,
    this.fileUrl,
    this.fileType,
    this.fileName,
  });

  factory DiscussionMessage.fromJson(Map<String, dynamic> json) {
    return DiscussionMessage(
      id: int.tryParse(json['id'].toString()) ?? 0,
      message: json['message']?.toString() ?? '',
      senderId: int.tryParse(json['sender_id'].toString()) ?? 0,
      senderName: json['sender']?['name']?.toString() ?? '-',
      createdAt: json['created_at']?.toString() ?? '',
      fileUrl: json['file_url']?.toString(),
      fileType: json['file_type']?.toString(),
      fileName: json['file_name']?.toString(),
    );
  }
}

class ProjectDiscussionProvider extends ChangeNotifier {
  final _dio = ApiClient().dio;

  List<DiscussionMessage> messages = [];
  bool isLoading = false;
  bool isSending = false;
  String? errorMessage;

  Future<void> fetchDiscussion(int projectId) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final res = await _dio.get('/projects/$projectId/discussion');

      debugPrint('RAW DISCUSSION RESPONSE: ${res.data}');

      final rawMessages = res.data['messages'] as List? ?? [];

      messages = rawMessages
          .map((e) => DiscussionMessage.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      errorMessage = 'Gagal memuat diskusi: $e';
      debugPrint(errorMessage);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage(int projectId, String text) async {
    try {
      isSending = true;
      errorMessage = null;
      notifyListeners();

      final res = await _dio.post(
        '/projects/$projectId/discussion/messages',
        data: {'message': text},
      );

      debugPrint('SEND DISCUSSION RESPONSE: ${res.data}');

      final data = res.data['data'];
      if (data != null) {
        messages.add(
          DiscussionMessage.fromJson(Map<String, dynamic>.from(data)),
        );
      }

      await fetchDiscussion(projectId);
      return true;
    } catch (e) {
      errorMessage = 'Gagal mengirim pesan: $e';
      debugPrint(errorMessage);
      return false;
    } finally {
      isSending = false;
      notifyListeners();
    }
  }

  Future<bool> sendImage(int projectId, String filePath) async {
    try {
      isSending = true;
      errorMessage = null;
      notifyListeners();

      final fileName = filePath.split('/').last;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
      });

      final res = await _dio.post(
        '/projects/$projectId/discussion/messages',
        data: formData,
      );

      final data = res.data['data'];

      if (data != null) {
        messages.add(
          DiscussionMessage.fromJson(Map<String, dynamic>.from(data)),
        );
      }

      await fetchDiscussion(projectId);
      return true;
    } catch (e) {
      errorMessage = 'Gagal mengirim gambar: $e';
      debugPrint(errorMessage);
      return false;
    } finally {
      isSending = false;
      notifyListeners();
    }
  }
}
