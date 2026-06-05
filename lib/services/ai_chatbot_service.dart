import 'package:firebase_database/firebase_database.dart';

import '../models/chat_message_model.dart';
import '../models/report_model.dart';

class AiChatbotService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Future<void> startBotIfNeeded({
    required ReportModel report,
  }) async {
    if (report.aiSeverity < 8) return;

    const chatType = 'counselor';

    await _database.ref('ai_chatbots/${report.reportId}/$chatType').set({
      'active': true,
      'startedAt': DateTime.now().toIso8601String(),
    });

    final message = ChatMessageModel(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'ai_bot',
      senderRole: 'ai_bot',
      message:
          'שלום, קיבלתי את הפנייה שלך. צוות בית הספר קיבל עדכון ויענה בהקדם. עד אז, נסה להישאר במקום בטוח ולכתוב כאן אם אתה צריך עזרה נוספת.',
      createdAt: DateTime.now(),
      readBy: {
        'ai_bot': true,
      },
    );

    await _database
        .ref('chats/${report.reportId}/$chatType/messages/${message.messageId}')
        .set(message.toMap());
  }

  Future<bool> isBotActive({
    required String reportId,
    required String chatType,
  }) async {
    final snapshot =
        await _database.ref('ai_chatbots/$reportId/$chatType/active').get();

    return snapshot.value == true;
  }

  Future<void> disableBot({
    required String reportId,
    required String chatType,
  }) async {
    await _database.ref('ai_chatbots/$reportId/$chatType/active').set(false);
  }

  Future<void> sendBotReply({
    required String reportId,
    required String chatType,
    required String studentMessage,
  }) async {
    final active = await isBotActive(
      reportId: reportId,
      chatType: chatType,
    );

    if (!active) return;

    final reply = _buildReply(studentMessage);

    final message = ChatMessageModel(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'ai_bot',
      senderRole: 'ai_bot',
      message: reply,
      createdAt: DateTime.now(),
      readBy: {
        'ai_bot': true,
      },
    );

    await _database
        .ref('chats/$reportId/$chatType/messages/${message.messageId}')
        .set(message.toMap());
  }

  String _buildReply(String text) {
    final lowerText = text.toLowerCase();

    if (lowerText.contains('כן') ||
        lowerText.contains('בטוח') ||
        lowerText.contains('בסדר')) {
      return 'תודה שכתבת. צוות בית הספר קיבל את הפנייה. אם משהו משתנה, כתוב כאן.';
    }

    if (lowerText.contains('לא') ||
        lowerText.contains('מפחד') ||
        lowerText.contains('מאיים') ||
        lowerText.contains('דחוף')) {
      return 'אני מבין שזה לא פשוט. נסה להישאר ליד מבוגר אחראי או במקום ציבורי בבית הספר עד שאיש צוות יענה.';
    }

    return 'קיבלתי את ההודעה שלך. צוות בית הספר עודכן ויענה בהקדם.';
  }
}