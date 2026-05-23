import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final List<Map<String, dynamic>> reportCategories = [
    {
      'title': 'בריונות',
      'icon': Icons.warning_amber_rounded,
    },
    {
      'title': 'לחץ נפשי',
      'icon': Icons.psychology,
    },
    {
      'title': 'קשיים חברתיים',
      'icon': Icons.groups,
    },
    {
      'title': 'מצוקה',
      'icon': Icons.sos,
    },
    {
      'title': 'אחר',
      'icon': Icons.more_horiz,
    },
  ];

  void openReport(BuildContext context, String category) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('נבחרה קטגוריה: $category'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('קול שקט'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              const Text(
                'איך אפשר לעזור לך?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'בחר את סוג הפנייה שברצונך לשלוח',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 30),

              Expanded(
                child: ListView.separated(
                  itemCount: reportCategories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final category = reportCategories[index];

                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => openReport(
                        context,
                        category['title'],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              category['icon'],
                              size: 32,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              category['title'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_back_ios),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}