import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/chat_message_model.dart';
import '../models/report_model.dart';
import '../services/realtime_database_service.dart';

class ChatScreen extends StatefulWidget {
  final ReportModel report;

  const ChatScreen({
    super.key,
    required this.report,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final RealtimeDatabaseService _databaseService = RealtimeDatabaseService();
  final TextEditingController messageController = TextEditingController();

  bool isSending = false;

  String formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();

    if (text.isEmpty) return;

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    setState(() {
      isSending = true;
    });

    final appUser = await _databaseService.getUserByUid(currentUser.uid);

    final message = ChatMessageModel(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: currentUser.uid,
      senderRole: appUser?.role ?? 'unknown',
      message: text,
      createdAt: DateTime.now(),
      readBy: {
        currentUser.uid: true,
      },
    );

    await _databaseService.sendChatMessage(
      reportId: widget.report.reportId,
      message: message,
    );

    messageController.clear();

    if (mounted) {
      setState(() {
        isSending = false;
      });
    }
  }

  Future<void> clearChat() async {
    await _databaseService.clearChat(widget.report.reportId);
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  bool isMe(ChatMessageModel message) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return currentUser != null && message.senderId == currentUser.uid;
  }

  String roleText(String role) {
    switch (role) {
      case 'student':
        return 'תלמיד';
      case 'counselor':
        return 'יועצת';
      case 'manager':
        return 'מנהל';
      default:
        return 'משתמש';
    }
  }

  Future<void> confirmClearChat() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('מחיקת הודעות'),
          content: const Text(
            'האם למחוק את כל הודעות הצ׳אט? הפנייה עצמה לא תימחק.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('ביטול'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('מחק'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await clearChat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('צ׳אט - ${widget.report.category}'),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: confirmClearChat,
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<ChatMessageModel>>(
                stream: _databaseService.getChatMessages(
                  widget.report.reportId,
                ),
                builder: (context, snapshot) {
                  final messages = snapshot.data ?? [];

                  if (messages.isEmpty) {
                    return const Center(
                      child: Text('אין הודעות עדיין'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final mine = isMe(message);

                      return Align(
                        alignment: mine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          constraints: const BoxConstraints(maxWidth: 280),
                          decoration: BoxDecoration(
                            color: mine ? Colors.blue : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: mine
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                roleText(message.senderRole),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: mine ? Colors.white : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                message.message,
                                style: TextStyle(
                                  color: mine ? Colors.white : Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                formatTime(message.createdAt),
                                style: TextStyle(
                                  color: mine
                                      ? Colors.white70
                                      : Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: 'כתוב הודעה...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  isSending
                      ? const CircularProgressIndicator()
                      : IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: sendMessage,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}