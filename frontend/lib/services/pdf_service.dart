import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/job_item.dart';

class PdfService {
  static Future<void> generateJobworkPDF({
    required String jobNo,
    required String partyName,
    required List<JobItem> items,
    required String date,
  }) async {
    final pdf = pw.Document();

    /// ✅ CALCULATE TOTAL OUTSIDE UI
    double totalQty = items.fold(
      0,
      (sum, item) => sum + (double.tryParse(item.quantity) ?? 0),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [

                /// HEADER
                _buildHeader(),

                pw.SizedBox(height: 10),

                /// TITLE
                pw.Center(
                  child: pw.Text(
                    "JOBWORK ORDER",
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),

                pw.SizedBox(height: 15),

                /// BASIC DETAILS
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                  ),
                  child: pw.Table(
                    columnWidths: {
                    0: const pw.FlexColumnWidth(4),
                    1: const pw.FlexColumnWidth(2),
                    2: const pw.FlexColumnWidth(2),
                    3: const pw.FlexColumnWidth(2),
                  },
                    children: [
                      _styledRow("Job No", jobNo),
                      _styledRow("Party Name", partyName),
                      _styledRow("Date", date),
                      _styledRow("Fabric", items.isNotEmpty ? items.first.fabric : "-"),
                      _styledRow("GSM", items.isNotEmpty ? items.first.gsm : "-"),
                      _styledRow("Width", items.isNotEmpty ? items.first.width : "-"),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),

                /// JOB ITEMS TABLE
                pw.Text(
                  "Job Details",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),

                pw.SizedBox(height: 10),

                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                  columnWidths: {
                
                    0: const pw.FlexColumnWidth(4),
                    1: const pw.FlexColumnWidth(2),
                    2: const pw.FlexColumnWidth(2),
                    3: const pw.FlexColumnWidth(2),
                    
          
                  },
                  children: [

                    /// HEADER
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                      
                        _cell("Yarn"),      
_cell("Required"),
_cell("Issued"),
_cell("Balance"),

                      ],
                    ),

                    /// DATA
                    ...items.map((item) => pw.TableRow(
                        children: [
                          _cell(item.yarn),
                          _cell(item.quantity),
                          _cell(item.issued ?? "0"),
                          _cell(item.balance ?? "0"),
                        ],
                      )),
                  ],
                ),

                pw.SizedBox(height: 10),

                /// TOTAL
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    "Total Qty: ${totalQty.toStringAsFixed(2)}",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),

                pw.SizedBox(height: 20),

                /// INSTRUCTIONS
                pw.Text(
                  "Instructions",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),

                pw.SizedBox(height: 6),

                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("• Follow quality standards"),
                    pw.Text("• Maintain machine settings"),
                    pw.Text("• Report issues immediately"),
                  ],
                ),

                pw.SizedBox(height: 20),

                /// REMARKS
                pw.Text(
                  "Remarks",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),

                pw.SizedBox(height: 6),

                pw.Container(
                  height: 60,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                  ),
                ),

                pw.Spacer(),

                /// SIGNATURE
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _signature("Prepared By"),
                    _signature("Authorized Sign"),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  /// HEADER
  static pw.Widget _buildHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("GSTIN : 03BEDPK9456C1ZP", style: const pw.TextStyle(fontSize: 10)),
                pw.Text("PAN NO : BEDPK9456C", style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
            pw.Text("State : 03-Punjab", style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Center(
          child: pw.Text(
            "B & B KNIT FAB",
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Center(
          child: pw.Text(
            "DEALS IN ALL TYPE OF KNITTED CLOTH & GARMENTS ETC.",
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Container(height: 3, color: PdfColors.blue900),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(vertical: 6),
          color: PdfColors.red800,
          child: pw.Text(
            "PLOT NO.52 TAJPUR ROAD, MAHAVIR JAIN COLONY, BHAMIA KHURD, LUDHIANA "
            "Ph.: (O)99159-01133  Mobile: 98150-03806",
            style: pw.TextStyle(color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
        ),
      ],
    );
  }

  /// TABLE ROW
  static pw.TableRow _styledRow(String title, String value) {
  return pw.TableRow(
    children: [
      pw.Container(
        color: PdfColors.grey200,
        padding: const pw.EdgeInsets.all(8),
        child: pw.Text(
          title,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: pw.Text(value),
      ),
    ],
  );
}

  /// CELL
  static pw.Widget _cell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 9)),
    );
  }

  /// SIGNATURE
  static pw.Widget _signature(String title) {
    return pw.Column(
      children: [
        pw.Text(title),
        pw.SizedBox(height: 25),
        pw.Container(width: 120, height: 1, color: PdfColors.black),
      ],
    );
  }
}