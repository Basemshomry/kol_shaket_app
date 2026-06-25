import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../constants/app_strings.dart';
import '../models/notification_model.dart';
import '../models/report_model.dart';
import '../services/ai_chatbot_service.dart';
import '../services/ai_service.dart';
import '../services/realtime_database_service.dart';
import 'chat_screen.dart';
import '../utils/app_page_route.dart';

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
  final RealtimeDatabaseService _databaseService = RealtimeDatabaseService();
  final AiService _aiService = AiService();
  final AiChatbotService _aiChatbotService = AiChatbotService();

  final TextEditingController reportController = TextEditingController();

  double severity = 5;
  bool isLoading = false;

  @override
  void dispose() {
    reportController.dispose();
    super.dispose();
  }

  Future<Position?> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.locationServicesOff)),
      );
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.locationRequired)),
      );
      return null;
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> submitReport() async {
    try {
      setState(() => isLoading = true);

      final description = reportController.text.trim();

      if (description.isEmpty) {
        throw Exception(AppStrings.descriptionRequired);
      }

      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      final appUser = await _databaseService.getUserByUid(currentUser.uid);

      if (appUser == null) {
        throw Exception('User data not found');
      }

      final position = await getCurrentLocation();

      if (position == null) {
        throw Exception(AppStrings.locationRequired);
      }

      final aiResult = await _aiService.analyzeReport(
        category: widget.category,
        description: description,
        userSeverity: severity.toInt(),
      );

      final reportId = DateTime.now().millisecondsSinceEpoch.toString();

      final report = ReportModel(
        reportId: reportId,
        studentId: currentUser.uid,
        studentFirstName: appUser.firstName,
        studentLastName: appUser.lastName,
        studentClassName: appUser.className,
        studentIdNumber: appUser.idNumber,
        category: widget.category,
        description: description,
        userSeverity: severity.toInt(),
        status: 'pending',
        createdAt: DateTime.now(),
        latitude: position.latitude,
        longitude: position.longitude,
        locationShared: true,
        aiSeverity: aiResult.aiSeverity,
        aiRiskLevel: aiResult.aiRiskLevel,
        aiRecommendation: aiResult.aiRecommendation,
        aiSummary: aiResult.aiSummary,
        aiAnalyzed: true,
      );

      await _databaseService.createReport(report);

      await _aiChatbotService.startBotIfNeeded(report: report);

      await _databaseService.createNotification(
        NotificationModel(
          notificationId: DateTime.now().millisecondsSinceEpoch.toString(),
          title: aiResult.aiSeverity >= 8
              ? AppStrings.severeReportNew
              : AppStrings.newReport,
          body:
              '${appUser.firstName} ${appUser.lastName} - ${widget.category}. ${AppStrings.risk}: ${aiResult.aiRiskLevel}',
          type: aiResult.aiSeverity >= 8 ? 'high_severity' : 'new_report',
          reportId: reportId,
          createdAt: DateTime.now(),
          read: false,
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.reportSent)),
      );

      if (aiResult.aiSeverity >= 8) {
        Navigator.pushReplacement(
          context,
          AppPageRoute(
            page: ChatScreen(
              report: report,
              chatType: 'counselor',
              chatTitle: AppStrings.chatWithAiAssistant,
            ),
          ),
        );
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              AppStrings.describeWhatHappened,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reportController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: AppStrings.writeHere,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              '${AppStrings.severityLevel}: ${severity.toInt()}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            Slider(
              value: severity,
              min: 1,
              max: 10,
              divisions: 9,
              label: severity.toInt().toString(),
              onChanged: (value) {
                setState(() => severity = value);
              },
            ),
            const Spacer(),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: submitReport,
                    child: Text(
                      AppStrings.sendReport,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}