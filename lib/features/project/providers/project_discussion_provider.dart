import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';

class DiscussionMessage {
  final int id;
  final String message;
  final int senderId;
  final String senderName;
  final String createdAt;

  DiscussionMessage({
    required this.id,
    required this.message,
    required this.senderId,
    required this.senderName,
    required this.createdAt,
  });

  factory DiscussionMessage.fromJson(Map<String, dynamic> json) {
    return DiscussionMessage(
      id: int.tryParse(json['id'].toString()) ?? 0,
      message: json['message']?.toString() ?? '',
      senderId: int.tryParse(json['sender_id'].toString()) ?? 0,
      senderName: json['sender']?['name']?.toString() ?? '-',
      createdAt: json['created_at']?.toString() ?? '',
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
}
