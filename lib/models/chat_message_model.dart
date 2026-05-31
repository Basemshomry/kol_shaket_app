class ChatMessageModel {
  final String messageId;
  final String senderId;
  final String senderRole;
  final String message;
  final DateTime createdAt;
  final Map<String, dynamic> readBy;

  ChatMessageModel({
    required this.messageId,
    required this.senderId,
    required this.senderRole,
    required this.message,
    required this.createdAt,
    required this.readBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'senderRole': senderRole,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'readBy': readBy,
    };
  }

  factory ChatMessageModel.fromMap(Map<dynamic, dynamic> map) {
    return ChatMessageModel(
      messageId: map['messageId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderRole: map['senderRole'] ?? '',
      message: map['message'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      readBy: map['readBy'] == null
          ? {}
          : Map<String, dynamic>.from(map['readBy'] as Map),
    );
  }

  bool isReadBy(String uid) {
    return readBy[uid] == true;
  }
}