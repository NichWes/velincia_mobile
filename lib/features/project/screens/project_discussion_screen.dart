import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_discussion_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'discussion_image_preview_screen.dart';
import 'dart:io';

class ProjectDiscussionScreen extends StatefulWidget {
  final int projectId;
  final int currentUserId;

  const ProjectDiscussionScreen({
    super.key,
    required this.projectId,
    required this.currentUserId,
  });

  @override
  State<ProjectDiscussionScreen> createState() =>
      _ProjectDiscussionScreenState();
}

class _ProjectDiscussionScreenState extends State<ProjectDiscussionScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  File? _selectedImage;

  int _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final provider = context.read<ProjectDiscussionProvider>();

      await provider.fetchDiscussion(widget.projectId);
      await provider.startRealtime(widget.projectId);

      _lastMessageCount = provider.messages.length;
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    context.read<ProjectDiscussionProvider>().stopRealtime();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 120), () {
        if (!mounted) return;

        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      allowMultiple: false,
    );

    if (result == null || result.files.single.path == null) return;

    setState(() {
      _selectedImage = File(result.files.single.path!);
    });
  }

  String _formatTime(String dateTime) {
    if (dateTime.isEmpty) return '';

    final parsed = DateTime.tryParse(dateTime);
    if (parsed == null) return '';

    final local = parsed.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    final image = _selectedImage;

    if (text.isEmpty && image == null) return;

    _controller.clear();

    setState(() {
      _selectedImage = null;
    });

    bool ok = false;

    if (image != null) {
      ok = await context
          .read<ProjectDiscussionProvider>()
          .sendImageWithText(widget.projectId, image.path, text);
    } else {
      ok = await context
          .read<ProjectDiscussionProvider>()
          .sendMessage(widget.projectId, text);
    }

    if (!mounted) return;

    if (!ok) {
      final error = context.read<ProjectDiscussionProvider>().errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Gagal mengirim pesan')),
      );
      return;
    }

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectDiscussionProvider>();

    if (provider.messages.length != _lastMessageCount) {
      _lastMessageCount = provider.messages.length;
      _scrollToBottom();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                color: Color(0xFF2563EB),
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Diskusi Project',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: provider.isRealtimeConnected
                              ? const Color(0xFF22C55E)
                              : Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        provider.isRealtimeConnected
                            ? 'Realtime aktif'
                            : 'Menghubungkan realtime...',
                        style: TextStyle(
                          fontSize: 11,
                          color: provider.isRealtimeConnected
                              ? const Color(0xFF16A34A)
                              : Colors.orange.shade700,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _infoBanner(provider),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.messages.isEmpty
                    ? _emptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                        itemCount: provider.messages.length,
                        itemBuilder: (context, index) {
                          final msg = provider.messages[index];
                          final isMe = msg.senderId == widget.currentUserId;

                          return _chatBubble(msg, isMe);
                        },
                      ),
          ),
          _inputBar(),
        ],
      ),
    );
  }

  Widget _infoBanner(ProjectDiscussionProvider provider) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF2563EB),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              provider.isRealtimeConnected
                  ? 'Chat terhubung langsung dengan admin. Balasan akan muncul otomatis.'
                  : 'Chat tetap bisa digunakan. Jika realtime belum aktif, pesan akan muncul setelah dimuat ulang.',
              style: const TextStyle(
                color: Color(0xFF1E3A8A),
                fontWeight: FontWeight.w600,
                height: 1.35,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: Color(0xFF2563EB),
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada pesan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mulai diskusi dengan admin Velincia HPL tentang ukuran, material, atau detail project.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chatBubble(DiscussionMessage msg, bool isMe) {
    final hasImage = msg.fileUrl != null && msg.fileUrl!.isNotEmpty;
    final hasText = msg.message.trim().isNotEmpty;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.76,
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 4),
                child: Text(
                  msg.senderRole == 'admin'
                      ? 'Admin Velincia HPL'
                      : msg.senderName,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            Container(
              padding: EdgeInsets.all(hasImage ? 6 : 12),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 5),
                  bottomRight: Radius.circular(isMe ? 5 : 18),
                ),
                border:
                    isMe ? null : Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasImage)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DiscussionImagePreviewScreen(
                              imageUrl: msg.fileUrl!,
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          msg.fileUrl!,
                          width: 220,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Container(
                            width: 220,
                            height: 140,
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(Icons.broken_image_rounded),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (hasImage && hasText) const SizedBox(height: 8),
                  if (hasText)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: hasImage ? 6 : 0,
                        vertical: hasImage ? 2 : 0,
                      ),
                      child: Text(
                        msg.message,
                        style: TextStyle(
                          color: isMe ? Colors.white : const Color(0xFF111827),
                          fontSize: 14,
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: EdgeInsets.only(
                      right: hasImage ? 6 : 0,
                      left: hasImage ? 6 : 0,
                      bottom: hasImage ? 2 : 0,
                    ),
                    child: Text(
                      _formatTime(msg.createdAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: isMe
                            ? Colors.white.withOpacity(0.82)
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputBar() {
    final provider = context.watch<ProjectDiscussionProvider>();

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_selectedImage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        _selectedImage!,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Gambar siap dikirim. Kamu bisa menambahkan pesan sebelum klik kirim.',
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: provider.isSending
                          ? null
                          : () {
                              setState(() {
                                _selectedImage = null;
                              });
                            },
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                IconButton(
                  onPressed: provider.isSending ? null : _pickImage,
                  icon: const Icon(
                    Icons.image_rounded,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => provider.isSending ? null : _send(),
                    decoration: InputDecoration(
                      hintText: _selectedImage == null
                          ? 'Tulis pesan ke admin...'
                          : 'Tambahkan caption...',
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: provider.isSending ? null : _send,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: provider.isSending
                          ? Colors.grey.shade400
                          : const Color(0xFF1E293B),
                      shape: BoxShape.circle,
                    ),
                    child: provider.isSending
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 21,
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
