import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'dart:io';

class PdfExportService {
  static Future<void> exportUserList(List<dynamic> users) async {
    try {
      final pdf = pw.Document();
      final font = pw.Font.helvetica();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          footer: (pw.Context context) {
            return pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(top: 16),
              child: pw.Text(
                'Page ${context.pageNumber}',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 12,
                ),
              ),
            );
          },
          build: (pw.Context context) => [
            _buildHeader(font),
            pw.SizedBox(height: 20),
            _buildUserTable(users, font),
          ],
        ),
      );

      const String downloadsPath = '/storage/emulated/0/Download';
      final directory = Directory(downloadsPath);

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final String timestamp = DateTime.now().toString().split('.')[0].replaceAll(':', '-');
      final String fileName = 'user_list_$timestamp.pdf';
      final file = File('${directory.path}/$fileName');

      final bytes = await pdf.save();
      await file.writeAsBytes(bytes);
      await OpenFile.open(file.path);

    } catch (e) {
      throw Exception('Failed to generate PDF: $e');
    }
  }

  static pw.Widget _buildHeader(pw.Font font) {
    return pw.Header(
      level: 0,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'User List',
            style: pw.TextStyle(
              font: font,
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            DateTime.now().toString().split('.')[0],
            style: pw.TextStyle(
              font: font,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildUserTable(List<dynamic> users, pw.Font font) {
    final headers = ['ID', 'Name', 'Role', 'Mobile', 'Email', 'City', 'State'];

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(2.5),
        5: const pw.FlexColumnWidth(1.5),
        6: const pw.FlexColumnWidth(1.5),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: headers.map((header) =>
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  header,
                  style: pw.TextStyle(
                    font: font,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
          ).toList(),
        ),
        ...users.map((user) =>
            pw.TableRow(
              children: [
                _buildTableCell(user.id.toString(), font),
                _buildTableCell(user.name, font),
                _buildTableCell(user.role, font),
                _buildTableCell(user.mobileNumber, font),
                _buildTableCell(user.email, font),
                _buildTableCell(user.city, font),
                _buildTableCell(user.state, font),
              ],
            ),
        ),
      ],
    );
  }

  static pw.Widget _buildTableCell(String? text, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text ?? 'N/A',
        style: pw.TextStyle(
          font: font,
          fontSize: 10,
        ),
      ),
    );
  }
}