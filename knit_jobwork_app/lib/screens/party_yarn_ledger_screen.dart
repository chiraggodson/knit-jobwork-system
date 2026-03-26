import 'package:flutter/material.dart';


class PartyYarnLedgerScreen extends StatelessWidget {
  final String party;
  final DateTime fromDate;
  final DateTime toDate;
  final String? yarn;
  final String? color;
  final String? lot;

  const PartyYarnLedgerScreen({
    super.key,
    required this.party,
    required this.fromDate,
    required this.toDate,
    this.yarn,
    this.color,
    this.lot,
  });

  @override
  Widget build(BuildContext context) {

    // 🔹 TEMP DATA (replace with API)
    final data = [
      {
        "date": "12 Mar",
        "challan": "CH-101",
        "yarn": "Cotton 30s",
        "color": "Red",
        "lot": "L001",
        "boxes": 10,
        "qty": 250
      }
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Ledger - $party"),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text("Date")),
            DataColumn(label: Text("Challan")),
            DataColumn(label: Text("Yarn")),
            DataColumn(label: Text("Color")),
            DataColumn(label: Text("Lot")),
            DataColumn(label: Text("Boxes")),
            DataColumn(label: Text("Qty")),
          ],
          rows: data.map((row) {
            return DataRow(cells: [
              DataCell(Text(row["date"].toString())),
              DataCell(Text(row["challan"].toString())),
              DataCell(Text(row["yarn"].toString())),
              DataCell(Text(row["color"].toString())),
              DataCell(Text(row["lot"].toString())),
              DataCell(Text(row["boxes"].toString())),
              DataCell(Text(row["qty"].toString())),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}