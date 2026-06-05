class AiAnalysisResult {
  final int aiSeverity;
  final String aiRiskLevel;
  final String aiRecommendation;
  final String aiSummary;

  AiAnalysisResult({
    required this.aiSeverity,
    required this.aiRiskLevel,
    required this.aiRecommendation,
    required this.aiSummary,
  });
}

class AiService {
  Future<AiAnalysisResult> analyzeReport({
    required String category,
    required String description,
    required int userSeverity,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final text = description.toLowerCase();
    int aiSeverity = userSeverity;

    if (text.contains('מפחד') ||
        text.contains('מאיים') ||
        text.contains('איומים') ||
        text.contains('חרם') ||
        text.contains('בריונות') ||
        text.contains('אלימות') ||
        text.contains('פגיעה') ||
        text.contains('מצוקה') ||
        text.contains('לחץ')) {
      aiSeverity = userSeverity < 8 ? 8 : userSeverity;
    }

    String riskLevel;
    String recommendation;

    if (aiSeverity >= 8) {
      riskLevel = 'גבוה';
      recommendation =
          'מומלץ שצוות בית הספר יבדוק את הפנייה בהקדם ויפתח שיחה עם התלמיד.';
    } else if (aiSeverity >= 5) {
      riskLevel = 'בינוני';
      recommendation = 'מומלץ לעקוב אחרי הפנייה ולפנות לתלמיד בזמן הקרוב.';
    } else {
      riskLevel = 'נמוך';
      recommendation = 'הפנייה אינה נראית דחופה, אך עדיין מומלץ לבדוק אותה.';
    }

    return AiAnalysisResult(
      aiSeverity: aiSeverity,
      aiRiskLevel: riskLevel,
      aiRecommendation: recommendation,
      aiSummary: 'ניתוח מערכת: פנייה בנושא $category עם רמת סיכון $riskLevel.',
    );
  }
}