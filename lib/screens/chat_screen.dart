import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../models/chat_message_model.dart';
import '../models/notification_model.dart';
import '../models/report_model.dart';
import '../services/ai_chatbot_service.dart';
import '../services/realtime_database_service.dart';

class ChatScreen extends StatefulWidget {
  final ReportModel report;
  final String chatType;
  final String chatTitle;

  const ChatScreen({
    super.key,
    required this.report,
    required this.chatType,
    required this.chatTitle,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final RealtimeDatabaseService _databaseService = RealtimeDatabaseService();
  final AiChatbotService _aiChatbotService = AiChatbotService();
  final TextEditingController messageController = TextEditingController();

  bool isSending = false;

  @override
  void initState() {
    super.initState();
    _databaseService.markChatAsRead(
      reportId: widget.report.reportId,
      chatType: widget.chatType,
    );
  }

  String formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String roleText(String role) {
    switch (role) {
      case 'student':
        return AppStrings.student;
      case 'counselor':
        return AppStrings.counselor;
      case 'manager':
        return AppStrings.manager;
      case 'teacher':
        return AppStrings.teacher;
      case 'ai_bot':
        return AppStrings.aiAssistant;
      default:
        return AppStrings.schoolStaff;
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() {
      isSending = true;
    });

    try {
      final appUser = await _databaseService.getUserByUid(currentUser.uid);
      final senderRole = appUser?.role ?? 'unknown';

      final message = ChatMessageModel(
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: currentUser.uid,
        senderRole: senderRole,
        message: text,
        createdAt: DateTime.now(),
        readBy: {
          currentUser.uid: true,
        },
      );

      await _databaseService.sendChatMessage(
        reportId: widget.report.reportId,
        chatType: widget.chatType,
        message: message,
      );

      if (senderRole == 'student') {
        await _aiChatbotService.sendBotReply(
          reportId: widget.report.reportId,
          chatType: widget.chatType,
          studentMessage: text,
        );
      } else {
        await _aiChatbotService.disableBot(
          reportId: widget.report.reportId,
          chatType: widget.chatType,
        );
      }

      await _databaseService.createNotification(
        NotificationModel(
          notificationId: DateTime.now().millisecondsSinceEpoch.toString(),
          title: AppStrings.newMessage,
          body: '${roleText(senderRole)}: $text',
          type: 'new_message',
          reportId: widget.report.reportId,
          createdAt: DateTime.now(),
          read: false,
        ),
      );

      messageController.clear();
    } finally {
      if (mounted) {
        setState(() {
          isSending = false;
        });
      }
    }
  }

  Future<void> confirmClearChat() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppStrings.deleteMessages),
          content: Text(AppStrings.deleteMessagesConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppStrings.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(AppStrings.delete),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _databaseService.clearChat(
        reportId: widget.report.reportId,
        chatType: widget.chatType,
      );

      await _aiChatbotService.disableBot(
        reportId: widget.report.reportId,
        chatType: widget.chatType,
      );
    }
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

  Widget messageStatus(ChatMessageModel message, bool mine) {
    if (!mine || message.senderRole == 'ai_bot') {
      return const SizedBox.shrink();
    }

    final bool isRead = message.readBy.length > 1;

    return Text(
      isRead ? '✓✓' : '✓',
      style: TextStyle(
        color: isRead ? Colors.lightGreenAccent : Colors.white70,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Color bubbleColor({
    required bool mine,
    required ChatMessageModel message,
  }) {
    if (message.senderRole == 'ai_bot') {
      return Colors.green.shade100;
    }

    return mine ? Colors.blue : Colors.grey.shade300;
  }

  Color textColor({
    required bool mine,
    required ChatMessageModel message,
  }) {
    if (message.senderRole == 'ai_bot') {
      return Colors.black;
    }

    return mine ? Colors.white : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatTitle),
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
                reportId: widget.report.reportId,
                chatType: widget.chatType,
              ),
              builder: (context, snapshot) {
                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Text(AppStrings.noMessagesYet),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final mine = isMe(message);

                    return Align(
                      alignment:
                          mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        constraints: const BoxConstraints(maxWidth: 280),
                        decoration: BoxDecoration(
                          color: bubbleColor(mine: mine, message: message),
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
                                color: textColor(mine: mine, message: message),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              message.message,
                              style: TextStyle(
                                color: textColor(mine: mine, message: message),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  formatTime(message.createdAt),
                                  style: TextStyle(
                                    color: message.senderRole == 'ai_bot'
                                        ? Colors.black54
                                        : mine
                                            ? Colors.white70
                                            : Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                                if (mine) ...[
                                  const SizedBox(width: 6),
                                  messageStatus(message, mine),
                                ],
                              ],
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
                      hintText: AppStrings.writeMessage,
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
    );
  }
}