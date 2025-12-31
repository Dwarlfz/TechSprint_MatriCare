import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class ReportService {
  final pw.Document pdf = pw.Document();

  /// simplistic weekly report generator
  Future<String> generateSimpleReport(Map<String, dynamic> patientData, List<Map<String, dynamic>> vitals) async {
    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, child: pw.Text('MatriCare Report')),
          pw.Paragraph(text: 'Patient: ${patientData['name'] ?? 'Unknown'}'),
          pw.Paragraph(text: 'Email: ${patientData['email'] ?? ''}'),
          pw.SizedBox(height: 12),
          pw.Text('Vitals:'),
          pw.Table.fromTextArray(
            headers: ['Time', 'Type', 'Value'],
            data: vitals.map((v) => [v['time'] ?? '', v['type'] ?? '', v['value'] ?? '']).toList(),
          )
        ],
      ),
    );

    final bytes = await pdf.save();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/matricare_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(bytes);
    return file.path;
  }
}
