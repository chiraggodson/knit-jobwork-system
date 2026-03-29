import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class PartyStockReportScreen extends StatefulWidget {
  const PartyStockReportScreen({super.key});

  @override
  State<PartyStockReportScreen> createState() =>
      _PartyStockReportScreenState();
}

class _PartyStockReportScreenState
    extends State<PartyStockReportScreen> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.getPartyLedger();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = ApiService.getPartyLedger();
    });
  }

  double safeDouble(dynamic v) =>
      double.tryParse(v?.toString() ?? '0') ?? 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Party Stock Movement"),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child:
                    Text("Error: ${snapshot.error}"));
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(
                child: Text("No data"));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final p = data[index];

                final inward =
                    safeDouble(p['yarn_inward']);
                final issued =
                    safeDouble(p['yarn_issued']);
                final returned =
                    safeDouble(p['yarn_returned']);
                final balance =
                    safeDouble(p['balance']);

                final consumptionPercent =
                    inward == 0
                        ? 0
                        : ((issued / inward) * 100)
                            .clamp(0, 100);

                return Container(
                  margin:
                      const EdgeInsets.only(
                          bottom: 18),
                  padding:
                      const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFF1E1E1E),
                    borderRadius:
                        BorderRadius.circular(
                            12),
                    border: Border.all(
                        color: Colors
                            .grey.shade800),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [

                      /// PARTY NAME
                      Text(
                        p['party_name'],
                        style:
                            const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                          height: 20),

                      /// METRICS ROW
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,
                        children: [
                          _metric(
                              "INWARD",
                              inward,
                              Colors.blueAccent),
                          _metric(
                              "ISSUED",
                              issued,
                              const Color(
                                  0xFF00BFA6)),
                          _metric(
                              "RETURNED",
                              returned,
                              Colors.orangeAccent),
                          _metric(
                              "BALANCE",
                              balance,
                              balance >= 0
                                  ? Colors.greenAccent
                                  : Colors.redAccent),
                        ],
                      ),

                      const SizedBox(
                          height: 20),

                      /// CONSUMPTION %
                      Text(
                        "Consumption: ${consumptionPercent.toStringAsFixed(1)}%",
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                          height: 8),

                      Container(
                        height: 12,
                        decoration:
                            BoxDecoration(
                          color: Colors
                              .grey.shade900,
                          borderRadius:
                              BorderRadius
                                  .circular(6),
                        ),
                        child: FractionallySizedBox(
                          widthFactor:
                              consumptionPercent /
                                  100,
                          child: Container(
                            decoration:
                                BoxDecoration(
                              color:
                                  const Color(
                                      0xFF00BFA6),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          6),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _metric(
      String label, double value, Color color) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          value.toStringAsFixed(2),
          style: TextStyle(
            fontSize: 16,
            fontWeight:
                FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
          ),
        ),
      ],
    );
  }
} 