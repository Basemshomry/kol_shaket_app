import 'package:excel/excel.dart' as ex;
import 'package:file_picker/file_picker.dart' as fp;
import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../services/realtime_database_service.dart';

class ExcelImportScreen extends StatefulWidget {
  const ExcelImportScreen({super.key});

  @override
  State<ExcelImportScreen> createState() => _ExcelImportScreenState();
}

class _ExcelImportScreenState extends State<ExcelImportScreen> {
  final RealtimeDatabaseService _databaseService = RealtimeDatabaseService();

  bool isLoading = false;
  String resultMessage = '';

  String cellValue(dynamic cell) {
    final value = cell?.value;
    return value == null ? '' : value.toString().trim();
  }

  Future<List<List<String>>> pickAndReadExcel() async {
    final result = await fp.FilePicker.platform.pickFiles(
      type: fp.FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );

    if (result == null || result.files.single.bytes == null) return [];

    final excel = ex.Excel.decodeBytes(result.files.single.bytes!);

    if (excel.tables.isEmpty) return [];

    final sheet = excel.tables[excel.tables.keys.first];

    if (sheet == null) return [];

    final rows = <List<String>>[];

    for (final row in sheet.rows) {
      final values = row.map(cellValue).toList();
      if (values.any((value) => value.isNotEmpty)) {
        rows.add(values);
      }
    }

    return rows;
  }

  List<List<String>> removeHeaderIfExists(List<List<String>> rows) {
    if (rows.isEmpty) return rows;

    final firstRow = rows.first.map((e) => e.toLowerCase()).toList();

    final looksLikeHeader = firstRow.any(
      (cell) =>
          cell.contains('id') ||
          cell.contains('first') ||
          cell.contains('last') ||
          cell.contains('class') ||
          cell.contains('role') ||
          cell.contains('תז') ||
          cell.contains('תעודת'),
    );

    return looksLikeHeader ? rows.skip(1).toList() : rows;
  }

  Future<void> importStudents() async {
    try {
      setState(() {
        isLoading = true;
        resultMessage = '';
      });

      final rows = removeHeaderIfExists(await pickAndReadExcel());
      final students = <Map<String, String>>[];

      for (final row in rows) {
        if (row.length < 4) continue;

        students.add({
          'idNumber': row[0],
          'firstName': row[1],
          'lastName': row[2],
          'className': row[3],
        });
      }

      await _databaseService.addApprovedStudentsBulk(students);

      setState(() {
        resultMessage = AppStrings.text(
          he: 'יובאו ${students.length} תלמידים בהצלחה',
          en: '${students.length} students imported successfully',
          ar: 'تم استيراد ${students.length} طلاب بنجاح',
        );
      });
    } catch (e) {
      setState(() {
        resultMessage = AppStrings.text(
          he: 'שגיאה בייבוא תלמידים: $e',
          en: 'Student import error: $e',
          ar: 'خطأ في استيراد الطلاب: $e',
        );
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> importStaff() async {
    try {
      setState(() {
        isLoading = true;
        resultMessage = '';
      });

      final rows = removeHeaderIfExists(await pickAndReadExcel());
      final admins = <Map<String, String>>[];

      for (final row in rows) {
        if (row.length < 4) continue;

        admins.add({
          'idNumber': row[0],
          'firstName': row[1],
          'lastName': row[2],
          'role': row[3],
          'className': row.length >= 5 ? row[4] : '',
        });
      }

      await _databaseService.addApprovedAdminsBulk(admins);

      setState(() {
        resultMessage = AppStrings.text(
          he: 'יובאו ${admins.length} אנשי צוות בהצלחה',
          en: '${admins.length} staff members imported successfully',
          ar: 'تم استيراد ${admins.length} من أعضاء الطاقم بنجاح',
        );
      });
    } catch (e) {
      setState(() {
        resultMessage = AppStrings.text(
          he: 'שגיאה בייבוא צוות: $e',
          en: 'Staff import error: $e',
          ar: 'خطأ في استيراد الطاقم: $e',
        );
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget instructionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.text(
                he: 'מבנה קובץ תלמידים:',
                en: 'Students file structure:',
                ar: 'مبنى ملف الطلاب:',
              ),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text('idNumber | firstName | lastName | className'),
            const SizedBox(height: 16),
            Text(
              AppStrings.text(
                he: 'מבנה קובץ צוות:',
                en: 'Staff file structure:',
                ar: 'مبنى ملف الطاقم:',
              ),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text('idNumber | firstName | lastName | role | className'),
            const SizedBox(height: 8),
            const Text('role: counselor / manager / teacher'),
          ],
        ),
      ),
    );
  }

  Widget actionButton({
    required String text,
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    return SizedBox(
      height: 55,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: Icon(icon),
        label: Text(text, style: const TextStyle(fontSize: 17)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.excelImport),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            instructionsCard(),
            const SizedBox(height: 24),
            actionButton(
              text: AppStrings.text(
                he: 'ייבוא תלמידים מקובץ Excel',
                en: 'Import students from Excel',
                ar: 'استيراد الطلاب من Excel',
              ),
              icon: Icons.school,
              onPressed: importStudents,
            ),
            const SizedBox(height: 16),
            actionButton(
              text: AppStrings.text(
                he: 'ייבוא צוות מקובץ Excel',
                en: 'Import staff from Excel',
                ar: 'استيراد الطاقم من Excel',
              ),
              icon: Icons.admin_panel_settings,
              onPressed: importStaff,
            ),
            const SizedBox(height: 30),
            if (isLoading) const Center(child: CircularProgressIndicator()),
            if (resultMessage.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    resultMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}