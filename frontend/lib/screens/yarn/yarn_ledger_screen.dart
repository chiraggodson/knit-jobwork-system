import 'package:flutter/material.dart';
import 'package:knit_jobwork_app/services/api_service.dart';

class YarnLedgerScreen extends StatefulWidget {
final int partyId;
final String partyName;
final DateTime fromDate;
final DateTime toDate;

final String? yarn;
final String? color;
final String? lot;

const YarnLedgerScreen({
super.key,
required this.partyId,
required this.partyName,
required this.fromDate,
required this.toDate,
this.yarn,
this.color,
this.lot,
});

@override
State<YarnLedgerScreen> createState() => _YarnLedgerScreenState();
}

class _YarnLedgerScreenState extends State<YarnLedgerScreen> {
List ledger = [];
bool loading = false;

@override
void initState() {
super.initState();
fetchLedger();
}

Future<void> fetchLedger() async {
setState(() => loading = true);


try {
  final data = await ApiService.getPartyYarnLedger(widget.partyId);

  setState(() {
    ledger = data;
    loading = false;
  });
} catch (e) {
  print("LEDGER ERROR: $e");

  setState(() {
    ledger = [];
    loading = false;
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Failed to load ledger")),
  );
}


}

double parseNum(dynamic val) {
if (val == null) return 0;
return double.tryParse(val.toString()) ?? 0;
}

String formatDate(dynamic date) {
if (date == null) return "";
return date.toString().split('T')[0];
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: Text("Ledger - ${widget.partyName}"),
),
body: Column(
children: [
const SizedBox(height: 10),


      Expanded(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : ledger.isEmpty
                ? const Center(child: Text("No Data"))
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text("Date")),
                        DataColumn(label: Text("Challan")),
                        DataColumn(label: Text("Yarn")),
                        DataColumn(label: Text("Lot")),
                        DataColumn(label: Text("In")),
                        DataColumn(label: Text("Out")),
                        DataColumn(label: Text("Balance")),
                      ],
                      rows: ledger.map<DataRow>((row) {
                        final inward = parseNum(row['inward']);
                        final returned = parseNum(row['returned']);

                        final issued = parseNum(row['issued']);
                        final outward = parseNum(row['outward']);
                        final waste = parseNum(row['waste']);
                        final partyReturn = parseNum(row['party_return']);
                        final setting = parseNum(row['setting']);

                        final totalIn = inward + returned;
                        final totalOut = outward > 0
                            ? outward
                            : issued + waste + partyReturn + setting;

                        return DataRow(cells: [
                          DataCell(Text(formatDate(row['date']))),
                          DataCell(Text(row['challan_no']?.toString() ?? "")),
                          DataCell(Text(row['yarn_name']?.toString() ?? "")),
                          DataCell(Text(row['lot_no']?.toString() ?? "")),
                          DataCell(Text(totalIn.toString())),
                          DataCell(Text(totalOut.toString())),
                          DataCell(Text(
                              row['running_balance']?.toString() ?? "0")),
                        ]);
                      }).toList(),
                    ),
                  ),
      ),
    ],
  ),
);


}
}
