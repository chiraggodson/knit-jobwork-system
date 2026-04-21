import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class SettingFabricScreen extends StatefulWidget {
  final int jobId;
  final int partyId;

  const SettingFabricScreen({
    super.key,
    required this.jobId,
    required this.partyId,
  });

  @override
  State<SettingFabricScreen> createState() => _SettingFabricScreenState();
}

class _SettingFabricScreenState extends State<SettingFabricScreen> {
  final TextEditingController _quantityController = TextEditingController();

  List<dynamic> yarnLots = [];
  int? selectedYarnLotId;
  bool loading = false;
  bool loadingLots = true;

  @override
  void initState() {
    super.initState();
    loadYarnLots();
  }

  Future<void> loadYarnLots() async {
    try {
      final data = await ApiService.getYarnLotsByParty(widget.partyId);

      if (!mounted) return;

      setState(() {
        yarnLots = data.where((lot) {
          final balance = double.tryParse(lot['balance']?.toString() ?? '0') ?? 0;
          return balance > 0;
        }).toList();
        loadingLots = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => loadingLots = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> submit() async {
    final qty = double.tryParse(_quantityController.text);

    if (selectedYarnLotId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select yarn lot")),
      );
      return;
    }

    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid quantity")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await ApiService.addSetting(
        jobId: widget.jobId,
        yarnLotId: selectedYarnLotId!,
        quantity: qty,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Setting fabric recorded")),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
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
      appBar: AppBar(title: const Text("Setting Fabric")),
      body: loadingLots
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    "Record fabric made during machine setup.",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),

                  DropdownButtonFormField<int>(
                    value: selectedYarnLotId,
                    decoration: const InputDecoration(
                      labelText: "Yarn Lot",
                      border: OutlineInputBorder(),
                    ),
                    items: yarnLots.map<DropdownMenuItem<int>>((lot) {
                      final balance =
                          double.tryParse(lot['balance']?.toString() ?? '0') ??
                              0;
                      return DropdownMenuItem<int>(
                        value: lot['id'],
                        child: Text(
                          "${lot['yarn_name']} - ${lot['lot_no']} (${balance.toStringAsFixed(2)} kg)",
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedYarnLotId = value);
                    },
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: _quantityController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: "Setting Quantity (kg)",
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
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("Add Setting Fabric"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
