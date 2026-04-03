import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class DispatchScreen extends StatefulWidget {
  final int jobId;
  final Map<String, dynamic>? dispatchData;

  const DispatchScreen({
    super.key,
    required this.jobId,
    this.dispatchData,
  });

  @override
  State<DispatchScreen> createState() => _DispatchScreenState();
}

class _DispatchScreenState extends State<DispatchScreen> {

  List<dynamic> rolls = [];
  List<String> selectedRolls = [];

  String jobNo = "";
  double producedQty = 0;
  double dispatchedQty = 0;

  bool loading = true;
  bool dispatching = false;

  String _safeString(dynamic val) {
    return val?.toString() ?? "";
  }

  @override
  void initState() {
    super.initState();
    loadRolls();
  }

  Future<void> loadRolls() async {
    try {

      final data = await ApiService.getDispatchRolls(widget.jobId);

      print("DISPATCH API RESPONSE: $data");

      /// 🔥 SUPPORT BOTH OLD + NEW API STRUCTURE

      if (data is List && data.isNotEmpty && data[0] is Map && data[0]['rolls'] != null) {
        // NEW STRUCTURE
        final item = data[0];

        setState(() {
          jobNo = item['job_no']?.toString() ?? "";

          producedQty =
              double.tryParse(item['produced_qty'].toString()) ?? 0;

          dispatchedQty =
              double.tryParse(item['dispatched_qty'].toString()) ?? 0;

          rolls = item['rolls'] ?? [];

          loading = false;
        });

      } else {
        // OLD STRUCTURE (your working one)
        setState(() {
          rolls = data;
          loading = false;
        });
      }

    } catch (e) {
      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void toggleRoll(String rollNo) {
    setState(() {
      if (selectedRolls.contains(rollNo)) {
        selectedRolls.remove(rollNo);
      } else {
        selectedRolls.add(rollNo);
      }
    });
  }

  Future<void> dispatch() async {

    if (selectedRolls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select at least one roll")),
      );
      return;
    }

    setState(() => dispatching = true);

    try {

      final selectedData = rolls
          .where((r) => selectedRolls.contains(_safeString(r['roll_no'])))
          .map((r) => {
                "roll_no": _safeString(r['roll_no']),
                "quantity": r['quantity']
              })
          .toList();

      /// 🔥 FINAL ERP PAYLOAD
      final payload = {
        "job_id": widget.jobId,
        "challan_no": widget.dispatchData?['challan_no'],
        "date": widget.dispatchData?['date'],
        "party_po": widget.dispatchData?['party_po'],
        "design_no": widget.dispatchData?['design_no'],
        "fabric": widget.dispatchData?['fabric'],
        "lot_no": widget.dispatchData?['lot_no'],
        "color": widget.dispatchData?['color'],
        "rolls": selectedData,
      };

      await ApiService.createDispatch(payload);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Dispatch saved successfully")),
      );

      Navigator.pop(context, true);

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );

    }

    if (mounted) setState(() => dispatching = false);
  }

  @override
  Widget build(BuildContext context) {

    final remaining = producedQty - dispatchedQty;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      appBar: AppBar(
        title: const Text("Dispatch Fabric"),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                children: [

                  /// 🔥 HEADER (only if available)
                  if (jobNo.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            jobNo,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00BFA6),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("Produced: ${producedQty.toStringAsFixed(2)}"),
                              Text("Dispatched: ${dispatchedQty.toStringAsFixed(2)}"),
                              Text(
                                "Remaining: ${remaining.toStringAsFixed(2)}",
                                style: const TextStyle(color: Colors.orange),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),

                  /// EMPTY STATE
                  rolls.isEmpty
                      ? const Expanded(
                          child: Center(
                            child: Text(
                              "No rolls available for dispatch",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            itemCount: rolls.length,
                            itemBuilder: (context, index) {

                              final r = rolls[index];

                              final rollNo = _safeString(r['roll_no']);
                              final qty = double.tryParse(
                                      r['quantity'].toString()) ??
                                  0;

                              final selected =
                                  selectedRolls.contains(rollNo);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E1E1E),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Colors.grey.shade800),
                                ),
                                child: CheckboxListTile(
                                  value: selected,
                                  activeColor: const Color(0xFF00BFA6),

                                  title: Text(
                                    rollNo,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  subtitle: Text(
                                    "${qty.toStringAsFixed(2)} kg",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),

                                  onChanged: (_) => toggleRoll(rollNo),
                                ),
                              );
                            },
                          ),
                        ),

                  const SizedBox(height: 10),

                  /// DISPATCH BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.local_shipping),

                      label: dispatching
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              "Dispatch Selected (${selectedRolls.length})",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),

                      onPressed:
                          dispatching ? null : dispatch,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}