import 'package:firebase_database/firebase_database.dart';

import '../models/app_user.dart';

class RealtimeDatabaseService {
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref();

  Future<void> createUser(AppUser user) async {
    await _database
        .child('users')
        .child(user.uid)
        .set(user.toMap());
  }
}