import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';

import '../models/project_attachment_model.dart';
import '../providers/project_attachment_provider.dart';
import '../screens/attachment_image_preview_screen.dart';

class ProjectAttachmentCard extends StatelessWidget {
  final int projectId;

  const ProjectAttachmentCard({
    super.key,
    required this.projectId,
  });

  bool _isImage(ProjectAttachment file) {
    return file.mimeType.toLowerCase().startsWith('image') ||
        file.fileName.toLowerCase().endsWith('.jpg') ||
        file.fileName.toLowerCase().endsWith('.jpeg') ||
        file.fileName.toLowerCase().endsWith('.png');
  }

  bool _isPdf(ProjectAttachment file) {
    return file.mimeType.toLowerCase().contains('pdf') ||
        file.fileName.toLowerCase().endsWith('.pdf');
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return '-';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }

  Future<void> _pickFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      allowMultiple: false,
    );

    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final provider = context.read<ProjectAttachmentProvider>();

    final ok = await provider.upload(projectId, file);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Attachment berhasil diupload'
              : provider.errorMessage ?? 'Gagal upload attachment',
        ),
      ),
    );
  }

  Future<void> _openAttachment(
    BuildContext context,
    ProjectAttachment attachment,
  ) async {
    if (_isImage(attachment)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AttachmentImagePreviewScreen(
            imageUrl: attachment.fileUrl,
            title: attachment.fileName,
          ),
        ),
      );
      return;
    }

    final provider = context.read<ProjectAttachmentProvider>();
    final localFile = await provider.downloadToLocal(attachment);

    if (!context.mounted) return;

    if (localFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Gagal membuka file')),
      );
      return;
    }

    await OpenFilex.open(localFile.path);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ProjectAttachment attachment,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus attachment?'),
        content:
            Text('File "${attachment.fileName}" akan dihapus dari project.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final provider = context.read<ProjectAttachmentProvider>();
    final ok = await provider.delete(projectId, attachment.id);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Attachment berhasil dihapus'
              : provider.errorMessage ?? 'Gagal menghapus attachment',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectAttachmentProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Attachment Project',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Upload desain, foto ruangan, atau file PDF.',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      iconColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed:
                        provider.isUploading ? null : () => _pickFile(context),
                    icon: provider.isUploading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.upload_file_rounded, size: 18),
                    label: Text(provider.isUploading ? 'Upload...' : 'Upload'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (provider.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (provider.attachments.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Text(
                    'Belum ada attachment',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.attachments.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.82,
                  ),
                  itemBuilder: (context, index) {
                    final file = provider.attachments[index];

                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: provider.isOpening
                          ? null
                          : () => _openAttachment(context, file),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(18),
                                    ),
                                    child: Container(
                                      width: double.infinity,
                                      color: const Color(0xFFEFF6FF),
                                      child: _isImage(file)
                                          ? Image.network(
                                              file.fileUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  _fileIcon(file),
                                            )
                                          : _fileIcon(file),
                                    ),
                                  ),
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Material(
                                      color: Colors.black.withOpacity(0.52),
                                      borderRadius: BorderRadius.circular(999),
                                      child: InkWell(
                                        borderRadius:
                                            BorderRadius.circular(999),
                                        onTap: provider.isDeleting
                                            ? null
                                            : () =>
                                                _confirmDelete(context, file),
                                        child: const Padding(
                                          padding: EdgeInsets.all(7),
                                          child: Icon(
                                            Icons.delete_rounded,
                                            size: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    file.fileName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    _isPdf(file)
                                        ? 'PDF • ${_formatSize(file.fileSize)}'
                                        : 'Image • ${_formatSize(file.fileSize)}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _fileIcon(ProjectAttachment file) {
    final isPdf = _isPdf(file);

    return Center(
      child: Icon(
        isPdf ? Icons.picture_as_pdf_rounded : Icons.insert_drive_file_rounded,
        size: 46,
        color: isPdf ? const Color(0xFFDC2626) : const Color(0xFF2563EB),
      ),
    );
  }
}
