class NotificationModel {
  final String notificationId;
  final String title;
  final String body;
  final String type;
  final String reportId;
  final DateTime createdAt;
  final bool read;

  NotificationModel({
    required this.notificationId,
    required this.title,
    required this.body,
    required this.type,
    required this.reportId,
    required this.createdAt,
    required this.read,
  });

  Map<String, dynamic> toMap() {
    return {
      'notificationId': notificationId,
      'title': title,
      'body': body,
      'type': type,
      'reportId': reportId,
      'createdAt': createdAt.toIso8601String(),
      'read': read,
    };
  }

  factory NotificationModel.fromMap(Map<dynamic, dynamic> map) {
    return NotificationModel(
      notificationId: map['notificationId'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: map['type'] ?? '',
      reportId: map['reportId'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      read: map['read'] ?? false,
    );
  }
}