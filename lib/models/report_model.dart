class ReportModel {
  final String reportId;
  final String studentId;
  final String category;
  final String description;
  final int userSeverity;
  final String status;
  final DateTime createdAt;

  ReportModel({
    required this.reportId,
    required this.studentId,
    required this.category,
    required this.description,
    required this.userSeverity,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'reportId': reportId,
      'studentId': studentId,
      'category': category,
      'description': description,
      'userSeverity': userSeverity,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}