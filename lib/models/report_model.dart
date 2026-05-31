class ReportModel {
  final String reportId;
  final String studentId;
  final String studentFirstName;
  final String studentLastName;
  final String studentClassName;
  final String studentIdNumber;
  final String category;
  final String description;
  final int userSeverity;
  final String status;
  final DateTime createdAt;

  ReportModel({
    required this.reportId,
    required this.studentId,
    required this.studentFirstName,
    required this.studentLastName,
    required this.studentClassName,
    required this.studentIdNumber,
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
      'studentFirstName': studentFirstName,
      'studentLastName': studentLastName,
      'studentClassName': studentClassName,
      'studentIdNumber': studentIdNumber,
      'category': category,
      'description': description,
      'userSeverity': userSeverity,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ReportModel.fromMap(Map<dynamic, dynamic> map) {
    return ReportModel(
      reportId: map['reportId'] ?? '',
      studentId: map['studentId'] ?? '',
      studentFirstName: map['studentFirstName'] ?? '',
      studentLastName: map['studentLastName'] ?? '',
      studentClassName: map['studentClassName'] ?? '',
      studentIdNumber: map['studentIdNumber'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      userSeverity: map['userSeverity'] ?? 0,
      status: map['status'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}