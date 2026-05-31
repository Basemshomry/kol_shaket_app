import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/chat_message_model.dart';
import '../models/app_user.dart';
import '../models/report_model.dart';

class RealtimeDatabaseService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Future<void> addApprovedStudent({
    required String idNumber,
    required String firstName,
    required String lastName,
    required String className,
  }) async {
    await _database.ref('approved_students/$idNumber').set({
      'idNumber': idNumber,
      'firstName': firstName,
      'lastName': lastName,
      'className': className,
    });
  }

  Future<void> addApprovedAdmin({
    required String idNumber,
    required String firstName,
    required String lastName,
    required String role,
  }) async {
    await _database.ref('approved_admins/$idNumber').set({
      'idNumber': idNumber,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
    });
  }

  Future<Map<dynamic, dynamic>?> getApprovedStudent(String idNumber) async {
    final snapshot = await _database.ref('approved_students/$idNumber').get();
    if (!snapshot.exists) return null;
    return snapshot.value as Map<dynamic, dynamic>;
  }

  Future<Map<dynamic, dynamic>?> getApprovedAdmin(String idNumber) async {
    final snapshot = await _database.ref('approved_admins/$idNumber').get();
    if (!snapshot.exists) return null;
    return snapshot.value as Map<dynamic, dynamic>;
  }

  Future<void> createUser(AppUser user) async {
    await _database.ref('users/${user.uid}').set(user.toMap());
  }

  Future<AppUser?> getUserByUid(String uid) async {
    final snapshot = await _database.ref('users/$uid').get();
    if (!snapshot.exists) return null;

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    return AppUser.fromMap(data);
  }

  Future<void> createReport(ReportModel report) async {
    await _database.ref('reports/${report.reportId}').set(report.toMap());
  }

  Stream<List<ReportModel>> getMyReports() {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Stream.empty();
    }

    return _database.ref('reports').onValue.map((event) {
      final data = event.snapshot.value;

      if (data == null) return <ReportModel>[];

      final reportsMap = data as Map<dynamic, dynamic>;

      final reports = reportsMap.values
          .map((item) => ReportModel.fromMap(item))
          .where((report) => report.studentId == currentUser.uid)
          .toList();

      reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return reports;
    });
  }

  Stream<List<ReportModel>> getAllReports() {
    return _database.ref('reports').onValue.map((event) {
      final data = event.snapshot.value;

      if (data == null) return <ReportModel>[];

      final reportsMap = data as Map<dynamic, dynamic>;

      final reports = reportsMap.values
          .map((item) => ReportModel.fromMap(item))
          .toList();

      reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return reports;
    });
  }

  Future<void> updateReportStatus({
    required String reportId,
    required String status,
  }) async {
    await _database.ref('reports/$reportId/status').set(status);
  }
  Future<void> sendChatMessage({
  required String reportId,
  required ChatMessageModel message,
}) async {
  await _database
      .ref(
        'chats/$reportId/messages/${message.messageId}',
      )
      .set(message.toMap());
}

Stream<List<ChatMessageModel>> getChatMessages(
  String reportId,
) {
  return _database
      .ref('chats/$reportId/messages')
      .onValue
      .map((event) {
    final data = event.snapshot.value;

    if (data == null) {
      return <ChatMessageModel>[];
    }

    final messagesMap =
        data as Map<dynamic, dynamic>;

    final messages = messagesMap.values
        .map(
          (item) =>
              ChatMessageModel.fromMap(item),
        )
        .toList();

    messages.sort(
      (a, b) =>
          a.createdAt.compareTo(b.createdAt),
    );

    return messages;
  });
}

Future<void> clearChat(
  String reportId,
) async {
  await _database
      .ref('chats/$reportId/messages')
      .remove();
}
}