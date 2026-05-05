import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

pw.Widget buildHeader() {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [

      /// TOP ROW
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("GSTIN : 03BEDPK9456C1ZP",
                  style: pw.TextStyle(fontSize: 10)),
              pw.Text("PAN NO : BEDPK9456C",
                  style: pw.TextStyle(fontSize: 10)),
            ],
          ),

          pw.Text(
            "State : 03-Punjab",
            style: pw.TextStyle(fontSize: 10),
          ),
        ],
      ),

      pw.SizedBox(height: 10),

      /// COMPANY NAME
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

      /// SUBTITLE
      pw.Center(
        child: pw.Text(
          "DEALS IN ALL TYPE OF KNITTED CLOTH & GARMENTS ETC.",
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),

      pw.SizedBox(height: 8),

      /// BLUE LINE
      pw.Container(
        height: 3,
        color: PdfColors.blue900,
      ),

      /// RED ADDRESS BAR
      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        color: PdfColors.red800,
        child: pw.Text(
          "PLOT NO.52 TAJPUR ROAD, MAHAVIR JAIN COLONY, BHAMIA KHURD, LUDHIANA "
          "Ph.: (O)99159-01133  Mobile: 98150-03806",
          style: pw.TextStyle(
            color: PdfColors.white,
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),

      pw.SizedBox(height: 10),
    ],
  );
}