import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/report_model.dart';
import '../services/realtime_database_service.dart';

class ReportFormScreen extends StatefulWidget {
  final String category;

  const ReportFormScreen({
    super.key,
    required this.category,
  });

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final RealtimeDatabaseService _databaseService =
      RealtimeDatabaseService();

  final TextEditingController reportController =
      TextEditingController();

  double severity = 5;
  bool isLoading = false;

  @override
  void dispose() {
    reportController.dispose();
    super.dispose();
  }

  Future<void> submitReport() async {
    try {
      setState(() {
        isLoading = true;
      });

      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      final reportId =
          DateTime.now().millisecondsSinceEpoch.toString();

      final report = ReportModel(
        reportId: reportId,
        studentId: currentUser.uid,
        category: widget.category,
        description: reportController.text.trim(),
        userSeverity: severity.toInt(),
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await _databaseService.createReport(report);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('הפנייה נשלחה בהצלחה'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.category),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                'תאר מה קרה',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reportController,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: 'כתוב כאן...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'רמת חומרה: ${severity.toInt()}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Slider(
                value: severity,
                min: 1,
                max: 10,
                divisions: 9,
                label: severity.toInt().toString(),
                onChanged: (value) {
                  setState(() {
                    severity = value;
                  });
                },
              ),
              const Spacer(),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: submitReport,
                      child: const Text(
                        'שלח פנייה',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}