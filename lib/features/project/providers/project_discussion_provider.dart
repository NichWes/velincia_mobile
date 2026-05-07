import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../data/project_discussion_realtime_service.dart';

class DiscussionMessage {
  final int id;
  final String message;
  final int senderId;
  final String senderName;
  final String senderRole;
  final String createdAt;
  final String? fileUrl;
  final String? fileType;
  final String? fileName;

  DiscussionMessage({
    required this.id,
    required this.message,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
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
      senderRole: json['sender']?['role']?.toString() ?? '-',
      createdAt: json['created_at']?.toString() ?? '',
      fileUrl: json['file_url']?.toString(),
      fileType: json['file_type']?.toString(),
      fileName: json['file_name']?.toString(),
    );
  }

  factory DiscussionMessage.fromRealtimeJson(Map<String, dynamic> json) {
    return DiscussionMessage(
      id: int.tryParse(json['id'].toString()) ?? 0,
      message: json['text']?.toString() ?? '',
      senderId: int.tryParse(json['sender_id'].toString()) ?? 0,
      senderName: json['sender_name']?.toString() ?? '-',
      senderRole: json['sender_role']?.toString() ?? '-',
      createdAt:
          json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      fileUrl: json['file_url']?.toString(),
      fileType: json['file_type']?.toString(),
      fileName: json['file_name']?.toString(),
    );
  }
}

class ProjectDiscussionProvider extends ChangeNotifier {
  final _dio = ApiClient().dio;
  final ProjectDiscussionRealtimeService _realtimeService =
      ProjectDiscussionRealtimeService();

  final Set<int> _messageIds = {};

  List<DiscussionMessage> messages = [];
  bool isLoading = false;
  bool isSending = false;
  bool isRealtimeConnected = false;
  String? errorMessage;

  Future<void> fetchDiscussion(int projectId) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final res = await _dio.get('/projects/$projectId/discussion');

      final rawMessages = res.data['messages'] as List? ?? [];

      messages = rawMessages
          .map((e) => DiscussionMessage.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      _syncMessageIds();
    } catch (e) {
      errorMessage = 'Gagal memuat diskusi: $e';
      debugPrint(errorMessage);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startRealtime(int projectId) async {
    try {
      await _realtimeService.subscribeToDiscussion(
        projectId: projectId,
        onConnectionChanged: (connected) {
          isRealtimeConnected = connected;
          notifyListeners();
        },
        onMessage: (data) {
          final msgData = data['message'];

          if (msgData == null) return;

          final newMessage = DiscussionMessage.fromRealtimeJson(
            Map<String, dynamic>.from(msgData),
          );

          addMessageIfNotExists(newMessage);
        },
      );
    } catch (e) {
      isRealtimeConnected = false;
      errorMessage = 'Realtime gagal aktif: $e';
      debugPrint(errorMessage);
      notifyListeners();
    }
  }

  Future<void> stopRealtime() async {
    await _realtimeService.unsubscribe();
    isRealtimeConnected = false;
  }

  Future<bool> sendImageWithText(
    int projectId,
    String filePath,
    String text,
  ) async {
    try {
      isSending = true;
      errorMessage = null;
      notifyListeners();

      final fileName = filePath.split('/').last;

      final formData = FormData.fromMap({
        'message': text,
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
        final newMessage = DiscussionMessage.fromJson(
          Map<String, dynamic>.from(data),
        );

        addMessageIfNotExists(newMessage);
      }

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

  void addMessageIfNotExists(DiscussionMessage message) {
    if (message.id != 0 && _messageIds.contains(message.id)) {
      return;
    }

    messages.add(message);

    if (message.id != 0) {
      _messageIds.add(message.id);
    }

    notifyListeners();
  }

  void _syncMessageIds() {
    _messageIds
      ..clear()
      ..addAll(messages.map((m) => m.id).where((id) => id != 0));
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

      final data = res.data['data'];

      if (data != null) {
        final newMessage = DiscussionMessage.fromJson(
          Map<String, dynamic>.from(data),
        );

        addMessageIfNotExists(newMessage);
      }

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
        final newMessage = DiscussionMessage.fromJson(
          Map<String, dynamic>.from(data),
        );

        addMessageIfNotExists(newMessage);
      }

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
