import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/app_user.dart';
import '../models/chat_message_model.dart';
import '../models/notification_model.dart';
import '../models/report_model.dart';

class RealtimeDatabaseService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Future<void> saveFcmToken({
    required String uid,
    required String token,
  }) async {
    await _database.ref('users/$uid/fcmTokens/$token').set(true);
  }

  Future<List<String>> getStaffFcmTokens() async {
    final snapshot = await _database.ref('users').get();
    if (!snapshot.exists || snapshot.value == null) return [];

    final data = snapshot.value as Map<dynamic, dynamic>;
    final tokens = <String>[];

    for (final item in data.values) {
      final user = Map<String, dynamic>.from(item as Map);
      final role = (user['role'] ?? '').toString();

      if (role == 'student') continue;

      final userTokens = user['fcmTokens'];
      if (userTokens is Map) {
        tokens.addAll(userTokens.keys.map((key) => key.toString()));
      }
    }

    return tokens;
  }

  Future<List<String>> getUserFcmTokens(String uid) async {
    final snapshot = await _database.ref('users/$uid/fcmTokens').get();
    if (!snapshot.exists || snapshot.value == null) return [];

    final data = snapshot.value as Map<dynamic, dynamic>;
    return data.keys.map((key) => key.toString()).toList();
  }

  Future<List<Map<String, dynamic>>> getApprovedStudents() async {
    final snapshot = await _database.ref('approved_students').get();
    if (!snapshot.exists || snapshot.value == null) return [];

    final data = snapshot.value as Map<dynamic, dynamic>;

    return data.values.map((item) {
      return Map<String, dynamic>.from(item as Map);
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getApprovedAdmins() async {
    final snapshot = await _database.ref('approved_admins').get();
    if (!snapshot.exists || snapshot.value == null) return [];

    final data = snapshot.value as Map<dynamic, dynamic>;

    return data.values.map((item) {
      return Map<String, dynamic>.from(item as Map);
    }).toList();
  }

  Future<void> deleteApprovedStudent(String idNumber) async {
    await _database.ref('approved_students/$idNumber').remove();
  }

  Future<void> deleteApprovedAdmin(String idNumber) async {
    await _database.ref('approved_admins/$idNumber').remove();
  }

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
    required String className,
  }) async {
    await _database.ref('approved_admins/$idNumber').set({
      'idNumber': idNumber,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'className': className,
    });
  }

  Future<void> addApprovedStudentsBulk(
    List<Map<String, String>> students,
  ) async {
    final updates = <String, dynamic>{};

    for (final student in students) {
      final idNumber = student['idNumber'] ?? '';

      if (idNumber.isEmpty) continue;

      updates['approved_students/$idNumber'] = {
        'idNumber': idNumber,
        'firstName': student['firstName'] ?? '',
        'lastName': student['lastName'] ?? '',
        'className': student['className'] ?? '',
      };
    }

    if (updates.isNotEmpty) {
      await _database.ref().update(updates);
    }
  }

  Future<void> addApprovedAdminsBulk(
    List<Map<String, String>> admins,
  ) async {
    final updates = <String, dynamic>{};

    for (final admin in admins) {
      final idNumber = admin['idNumber'] ?? '';

      if (idNumber.isEmpty) continue;

      updates['approved_admins/$idNumber'] = {
        'idNumber': idNumber,
        'firstName': admin['firstName'] ?? '',
        'lastName': admin['lastName'] ?? '',
        'role': admin['role'] ?? 'counselor',
        'className': admin['className'] ?? '',
      };
    }

    if (updates.isNotEmpty) {
      await _database.ref().update(updates);
    }
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
    await _database.ref('users/${user.uid}').update(user.toMap());
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
    if (currentUser == null) return const Stream.empty();

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

      final reports =
          reportsMap.values.map((item) => ReportModel.fromMap(item)).toList();

      reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reports;
    });
  }

  Stream<List<ReportModel>> getReportsForUser(AppUser user) {
    if (user.role == 'student') {
      return getMyReports();
    }

    return getAllReports().map((reports) {
      if (user.role == 'teacher') {
        return reports
            .where((report) => report.studentClassName == user.className)
            .toList();
      }

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
    required String chatType,
    required ChatMessageModel message,
  }) async {
    await _database
        .ref('chats/$reportId/$chatType/messages/${message.messageId}')
        .set(message.toMap());
  }

  Stream<List<ChatMessageModel>> getChatMessages({
    required String reportId,
    required String chatType,
  }) {
    return _database.ref('chats/$reportId/$chatType/messages').onValue.map(
      (event) {
        final data = event.snapshot.value;
        if (data == null) return <ChatMessageModel>[];

        final messagesMap = data as Map<dynamic, dynamic>;

        final messages = messagesMap.values
            .map((item) => ChatMessageModel.fromMap(item))
            .toList();

        messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        return messages;
      },
    );
  }

  Future<void> clearChat({
    required String reportId,
    required String chatType,
  }) async {
    await _database.ref('chats/$reportId/$chatType/messages').remove();
  }

  Stream<int> getUnreadMessagesCount({
    required String reportId,
    required String chatType,
  }) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const Stream.empty();

    return getChatMessages(reportId: reportId, chatType: chatType)
        .map((messages) {
      return messages.where((message) {
        return message.senderId != currentUser.uid &&
            !message.isReadBy(currentUser.uid);
      }).length;
    });
  }

  Future<void> markChatAsRead({
    required String reportId,
    required String chatType,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final snapshot =
        await _database.ref('chats/$reportId/$chatType/messages').get();

    if (!snapshot.exists || snapshot.value == null) return;

    final messagesMap = snapshot.value as Map<dynamic, dynamic>;

    for (final entry in messagesMap.entries) {
      final messageId = entry.key.toString();
      final messageData = entry.value as Map<dynamic, dynamic>;
      final senderId = messageData['senderId'] ?? '';

      if (senderId != currentUser.uid) {
        await _database
            .ref(
              'chats/$reportId/$chatType/messages/$messageId/readBy/${currentUser.uid}',
            )
            .set(true);
      }
    }
  }

  Future<void> createNotification(NotificationModel notification) async {
    await _database
        .ref('notifications/${notification.notificationId}')
        .set(notification.toMap());
  }

  Stream<List<NotificationModel>> getNotifications() {
    return _database.ref('notifications').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return <NotificationModel>[];

      final notificationsMap = data as Map<dynamic, dynamic>;

      final notifications = notificationsMap.values
          .map((item) => NotificationModel.fromMap(item))
          .toList();

      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notifications;
    });
  }

  Stream<int> getUnreadNotificationsCount() {
    return getNotifications().map((notifications) {
      return notifications.where((item) => !item.read).length;
    });
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _database.ref('notifications/$notificationId/read').set(true);
  }
}
