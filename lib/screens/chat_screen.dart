import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
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
  final ScrollController scrollController = ScrollController();

  bool isSending = false;

  @override
  void initState() {
    super.initState();

    _databaseService.markChatAsRead(
      reportId: widget.report.reportId,
      chatType: widget.chatType,
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
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

  IconData roleIcon(String role) {
    switch (role) {
      case 'student':
        return Icons.person_rounded;
      case 'counselor':
        return Icons.support_agent_rounded;
      case 'manager':
        return Icons.admin_panel_settings_rounded;
      case 'teacher':
        return Icons.school_rounded;
      case 'ai_bot':
        return Icons.smart_toy_rounded;
      default:
        return Icons.groups_rounded;
    }
  }

  bool isMe(ChatMessageModel message) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return currentUser != null && message.senderId == currentUser.uid;
  }

  Future<void> scrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 120));

    if (!scrollController.hasClients) return;

    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() => isSending = true);

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
      await scrollToBottom();
    } finally {
      if (mounted) setState(() => isSending = false);
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

  Widget messageStatus(ChatMessageModel message, bool mine) {
    if (!mine || message.senderRole == 'ai_bot') {
      return const SizedBox.shrink();
    }

    final bool isRead = message.readBy.length > 1;

    return Text(
      isRead ? '✓✓' : '✓',
      style: TextStyle(
        color: isRead ? AppColors.success : Colors.white70,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget messageBubble(ChatMessageModel message) {
    final mine = isMe(message);
    final isAi = message.senderRole == 'ai_bot';

    final bubbleColor = isAi
        ? AppColors.primaryLight
        : mine
            ? AppColors.primary
            : AppColors.surface;

    final borderColor = isAi
        ? AppColors.primaryLight
        : mine
            ? AppColors.primary
            : AppColors.border;

    final textColor = mine && !isAi ? Colors.white : AppColors.textPrimary;
    final width = MediaQuery.of(context).size.width * 0.74;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment:
            mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!mine) ...[
            CircleAvatar(
              radius: 18,
              backgroundColor:
                  isAi ? AppColors.primary : AppColors.primaryLight,
              child: Icon(
                roleIcon(message.senderRole),
                size: 18,
                color: isAi ? Colors.white : AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: width),
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(mine ? 20 : 6),
                  bottomRight: Radius.circular(mine ? 6 : 20),
                ),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.025),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    roleText(message.senderRole),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: mine && !isAi ? Colors.white70 : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message.message,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15.5,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formatTime(message.createdAt),
                        style: TextStyle(
                          color: mine && !isAi
                              ? Colors.white70
                              : AppColors.textSecondary,
                          fontSize: 11.5,
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
          ),
        ],
      ),
    );
  }

  Widget emptyState() {
    return Center(
      child: Text(
        AppStrings.noMessagesYet,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget inputBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.border),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: messageController,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: AppStrings.writeMessage,
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 48,
              height: 48,
              child: isSending
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    )
                  : ElevatedButton(
                      onPressed: sendMessage,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: const CircleBorder(),
                        minimumSize: const Size(48, 48),
                      ),
                      child: const Icon(Icons.send_rounded, size: 21),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.chatTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
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
                  return emptyState();
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  scrollToBottom();
                });

                return ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return messageBubble(messages[index]);
                  },
                );
              },
            ),
          ),
          inputBar(),
        ],
      ),
    );
  }
}