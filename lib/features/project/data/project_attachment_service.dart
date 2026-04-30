import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/api/api_client.dart';

class ProjectAttachmentService {
  final Dio _dio = ApiClient().dio;

  Future<List> getAttachments(int projectId) async {
    final res = await _dio.get('/projects/$projectId/attachments');
    return res.data['data'];
  }

  Future uploadAttachment(int projectId, File file) async {
    final fileName = file.path.split('/').last;

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });

    final res = await _dio.post(
      '/projects/$projectId/attachments',
      data: formData,
    );

    return res.data['data'];
  }

  Future<void> deleteAttachment(int projectId, int attachmentId) async {
    await _dio.delete('/projects/$projectId/attachments/$attachmentId');
  }

  Future<File> downloadToLocal({
    required String fileUrl,
    required String fileName,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/$fileName';

    await _dio.download(fileUrl, path);

    return File(path);
  }
}
