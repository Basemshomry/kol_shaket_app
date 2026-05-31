import 'package:firebase_database/firebase_database.dart';

import '../models/app_user.dart';
import '../models/report_model.dart';

class RealtimeDatabaseService {
  final FirebaseDatabase _database =
      FirebaseDatabase.instance;

  Future<void> createUser(AppUser user) async {
    await _database
        .ref('users/${user.uid}')
        .set(user.toMap());
  }

  Future<void> createReport(ReportModel report) async {
    await _database
        .ref('reports/${report.reportId}')
        .set(report.toMap());
  }
}