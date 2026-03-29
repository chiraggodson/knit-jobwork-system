import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:knit_jobwork_app/services/api_service.dart';

class YarnLedgerScreen extends StatefulWidget {
  final String party;
  final DateTime fromDate;
  final DateTime toDate;

  final String? yarn;
  final String? color;
  final String? lot;

  const YarnLedgerScreen({
    super.key,
    required this.party,
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
    
    final uri = Uri.parse(
      "${ApiService.baseUrl}/api/yarn/ledger-report"
      "?party=${widget.party}"
      "&from=${widget.fromDate.toIso8601String()}"
      "&to=${widget.toDate.toIso8601String()}"
      "&yarn=${widget.yarn ?? ''}"
      "&color=${widget.color ?? ''}"
      "&lot=${widget.lot ?? ''}",
    );

    final res = await http.get(uri);

    setState(() {
      ledger = jsonDecode(res.body);
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ledger - ${widget.party}"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          /// 📊 TABLE
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
                            return DataRow(cells: [
                              DataCell(Text(row['date'] ?? "")),
                              DataCell(Text(row['challan_no'] ?? "")),
                              DataCell(Text(row['yarn_name'] ?? "")),
                              DataCell(Text(row['lot_no'] ?? "")),
                              DataCell(Text(
                                  (row['inward'] ?? row['returned'] ?? 0)
                                      .toString())),
                              DataCell(Text(
                                  (row['issued'] ??
                                          row['waste'] ??
                                          row['party_return'] ??
                                          row['setting'] ??
                                          0)
                                      .toString())),
                              DataCell(Text(
                                  (row['running_balance'] ?? 0).toString())),
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