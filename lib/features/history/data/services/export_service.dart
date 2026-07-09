import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/models/study_activity.dart';
import 'package:intl/intl.dart';

class ExportService {
  Future<void> exportToPdf(List<StudyActivity> activities) async {
    final pdf = pw.Document();

    // Summary Calculation
    int totalSessions = activities.where((a) => a.type == ActivityType.studySession).length;
    int totalTests = activities.where((a) => a.type == ActivityType.test || a.type == ActivityType.mockTest).length;
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('StudyAI Learning Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.Text(DateFormat('MMMM yyyy').format(DateTime.now())),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text('Performance Summary', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Bullet(text: 'Total Study Sessions: $totalSessions'),
          pw.Bullet(text: 'Tests Attempted: $totalTests'),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue600),
            headers: ['Type', 'Activity', 'Date', 'Duration', 'Result'],
            data: activities.map((a) => [
              a.type.name.toUpperCase(),
              a.title,
              DateFormat('MMM dd').format(a.startTime),
              a.duration != null ? _formatDuration(a.duration!) : '-',
              a.score != null ? '${a.score}/${a.totalMarks}' : (a.status ?? '-'),
            ]).toList(),
          ),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/StudyAI_Report_${DateTime.now().millisecondsSinceEpoch}.pdf");
    await file.writeAsBytes(await pdf.save());
    await Share.shareXFiles([XFile(file.path)], text: 'My Monthly Study Progress Report');
  }

  Future<void> exportToExcel(List<StudyActivity> activities) async {
    final excel = Excel.createExcel();
    final sheet = excel['Study Logs'];

    sheet.appendRow([
      TextCellValue('Category'),
      TextCellValue('Activity Name'),
      TextCellValue('Timestamp'),
      TextCellValue('Duration (Mins)'),
      TextCellValue('Status/Score'),
    ]);

    for (var a in activities) {
      sheet.appendRow([
        TextCellValue(a.type.name),
        TextCellValue(a.title),
        TextCellValue(DateFormat('yyyy-MM-dd HH:mm').format(a.startTime)),
        IntCellValue(a.duration?.inMinutes ?? 0),
        TextCellValue(a.score != null ? '${a.score}/${a.totalMarks}' : (a.status ?? '')),
      ]);
    }

    final output = await getTemporaryDirectory();
    final fileBytes = excel.save();
    if (fileBytes != null) {
      final file = File("${output.path}/StudyAI_History_${DateTime.now().millisecondsSinceEpoch}.xlsx")
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
      await Share.shareXFiles([XFile(file.path)], text: 'Exported Study History Data');
    }
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
    return '${d.inMinutes}m';
  }
}
