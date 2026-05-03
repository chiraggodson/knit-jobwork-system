import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> generateJobworkPDF({
    required String jobNo,
    required String partyName,
    required String fabricName,
    required String orderQty,
    required String date,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [

                // HEADER
                pw.Center(
                  child: pw.Text(
                    "JOBWORK ORDER",
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),

                pw.SizedBox(height: 20),

                // DETAILS
                pw.Text("Job No: $jobNo"),
                pw.Text("Party: $partyName"),
                pw.Text("Fabric: $fabricName"),
                pw.Text("Order Qty: $orderQty"),
                pw.Text("Date: $date"),

                pw.SizedBox(height: 30),

                pw.Divider(),

                pw.SizedBox(height: 20),

                pw.Text(
                  "Instructions:",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),

                pw.Text("• Follow quality standards"),
                pw.Text("• Maintain machine settings"),
                pw.Text("• Report issues immediately"),

                pw.Spacer(),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Prepared By"),
                    pw.Text("Authorized Sign"),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );

    // 👇 Opens print dialog / preview
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
}