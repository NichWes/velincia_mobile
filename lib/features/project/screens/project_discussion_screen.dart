import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/project_discussion_provider.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'discussion_image_preview_screen.dart';

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
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await context
          .read<ProjectDiscussionProvider>()
          .fetchDiscussion(widget.projectId);

      _scrollToBottom();
    });

    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      if (!mounted) return;

      final provider = context.read<ProjectDiscussionProvider>();
      final oldCount = provider.messages.length;

      await provider.fetchDiscussion(widget.projectId);

      final newCount = provider.messages.length;
      if (newCount > oldCount) {
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickAndSendImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      allowMultiple: false,
    );

    if (result == null || result.files.single.path == null) return;

    final path = result.files.single.path!;

    final ok = await context
        .read<ProjectDiscussionProvider>()
        .sendImage(widget.projectId, path);

    if (!mounted) return;

    if (!ok) {
      final error = context.read<ProjectDiscussionProvider>().errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Gagal mengirim gambar')),
      );
      return;
    }

    _scrollToBottom();
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
    if (text.isEmpty) return;

    _controller.clear();

    final ok = await context
        .read<ProjectDiscussionProvider>()
        .sendMessage(widget.projectId, text);

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

    debugPrint('TOTAL MESSAGES: ${provider.messages.length}');
    debugPrint('CURRENT USER ID: ${widget.currentUserId}');

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text(
          'Diskusi Project',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
      ),
      body: Column(
        children: [
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
                  msg.senderName,
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
                color: isMe ? const Color(0xFF2563EB) : Colors.white,
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
        top: false,
        child: Row(
          children: [
            IconButton(
              onPressed: provider.isSending ? null : _pickAndSendImage,
              icon: const Icon(
                Icons.image_rounded,
                color: Color(0xFF2563EB),
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
                  hintText: 'Tulis pesan ke admin...',
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
                      : const Color(0xFF2563EB),
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
      ),
    );
  }
}
