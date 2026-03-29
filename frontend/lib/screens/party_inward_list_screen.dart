import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PartyInwardListScreen extends StatefulWidget {
  final int partyId;
  final String partyName;

  const PartyInwardListScreen({
    super.key,
    required this.partyId,
    required this.partyName,
  });

  @override
  State<PartyInwardListScreen> createState() =>
      _PartyInwardListScreenState();
}

class _PartyInwardListScreenState
    extends State<PartyInwardListScreen> {

  late Future<List<dynamic>> inwardFuture;

  @override
  void initState() {
    super.initState();
    inwardFuture =
        ApiService.getYarnLotsByParty(widget.partyId);
  }

  String _monthName(int month) {
    const months = [
      "",
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[month];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(widget.partyName),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: inwardFuture,
        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator());
          }

          if (!snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const Center(
                child: Text("No yarn inward found"));
          }

          final lots = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lots.length,
            itemBuilder: (context, index) {

              final l = lots[index];

              final yarnName = l['yarn_name'] ?? '-';
              final lotNo = l['lot_no'] ?? '-';
              final challan = l['challan_no'] ?? '-';
              final balance =
                  double.tryParse(l['balance'].toString()) ?? 0;
              final inwardQty =
                  double.tryParse(
                      l['quantity_received']?.toString() ?? '0') ?? 0;

              final inwardDate =
                  DateTime.tryParse(
                      l['inward_date']?.toString() ?? '');

              String formattedDate = '';
              if (inwardDate != null) {
                formattedDate =
                    "${inwardDate.day.toString().padLeft(2, '0')} "
                    "${_monthName(inwardDate.month)} "
                    "${inwardDate.year}";
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.grey.shade800),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    /// YARN NAME
                    Text(
                      yarnName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// LOT + CHALLAN
                    Text(
                      "Lot: $lotNo  |  Challan: $challan",
                      style: const TextStyle(
                          color: Colors.grey),
                    ),

                    const SizedBox(height: 10),

                    /// INWARD QTY
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        const Text("Inward Qty"),
                        Text(
                          "${inwardQty.toStringAsFixed(2)} kg",
                          style: const TextStyle(
                              fontWeight:
                                  FontWeight.bold),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    /// BALANCE
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        const Text("Balance"),
                        Text(
                          "${balance.toStringAsFixed(2)} kg",
                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            color: balance > 0
                                ? const Color(
                                    0xFF00BFA6)
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),

                    if (formattedDate.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ]
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}