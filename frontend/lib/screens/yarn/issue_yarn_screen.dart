import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class IssueYarnScreen extends StatefulWidget {
  final int jobId;
  final int partyId;

  const IssueYarnScreen({
    super.key,
    required this.jobId,
    required this.partyId,
    });

  @override
  State<IssueYarnScreen> createState() => _IssueYarnScreenState();
}

class _IssueYarnScreenState extends State<IssueYarnScreen> {
  final TextEditingController _quantityController = TextEditingController();

  List<dynamic> yarnLots = [];
  dynamic selectedLot;

  bool loading = false;
  bool lotLoading = true;

  @override
  void initState() {
    super.initState();
    loadLots();
  }

  Future<void> loadLots() async {
    try {
      final res = await ApiService.getYarnLotsByParty(widget.partyId); // temporary reuse
      setState(() {
        yarnLots = res;
        lotLoading = false;
      });
    } catch (e) {
      setState(() => lotLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Failed to load lots")));
    }
  }

  void submit() async {
    if (selectedLot == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Select yarn lot")));
      return;
    }

    double? qty = double.tryParse(_quantityController.text);
    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Enter valid quantity")));
      return;
    }

   double safeDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

double balance = safeDouble(selectedLot['balance']);

    if (qty > balance) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Insufficient lot balance")));
      return;
    }

    setState(() => loading = true);

    try {
      await ApiService.issueYarn(
        jobId: widget.jobId,
        yarnLotId: selectedLot['yarn_lot_id'],
        quantity: qty,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Yarn issued successfully")));
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }

    if (mounted) setState(() => loading = false);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Issue Yarn")),
      body: lotLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButtonFormField<dynamic>(
                  value: selectedLot,
                  decoration: const InputDecoration(
                    labelText: "Select Yarn Lot",
                    border: OutlineInputBorder(),
                  ),
                  items: yarnLots.map((lot) {

                    final yarnName = lot['yarn_name'] ?? '';
                    final lotNo = lot['lot_no'] ?? '';
                    final balance =
                        double.tryParse(lot['balance'].toString()) ?? 0;

                    return DropdownMenuItem(
                      value: lot,
                      child: Text(
                        "$yarnName  |   Lot: $lotNo  |  Balance: ${balance.toStringAsFixed(2)} kg",
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedLot = val;
                    });
                  },
                ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _quantityController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: "Quantity (kg)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading ? null : submit,
                      child: loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("Issue Yarn"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
