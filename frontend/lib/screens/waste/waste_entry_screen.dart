import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AddYarnInwardScreen extends StatefulWidget {
  final int? partyId;

  const AddYarnInwardScreen({super.key, this.partyId});

  @override
  State<AddYarnInwardScreen> createState() => _AddYarnInwardScreenState();
}

class _AddYarnInwardScreenState extends State<AddYarnInwardScreen> {
  final _formKey = GlobalKey<FormState>();

  int? partyId;
  int? yarnId;

  // ✅ COLOR
  int? selectedColorId;

  List parties = [];
  List yarns = [];

  bool loading = false;

  final TextEditingController _lotNo = TextEditingController();
  final TextEditingController _quantity = TextEditingController();
  final TextEditingController _challanNo = TextEditingController();

  DateTime inwardDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    partyId = widget.partyId;
    loadData();
  }

  Future<void> loadData() async {
    try {
      parties = await ApiService.getParties();
      yarns = await ApiService.getYarnMaster();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load data")),
      );
    }
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: inwardDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => inwardDate = picked);
    }
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedColorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select color")),
      );
      return;
    }

    double? qty = double.tryParse(_quantity.text);
    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid quantity")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await ApiService.addYarnInward(
        partyId: partyId!,
        yarnId: yarnId!,
        lotNo: _lotNo.text.trim(),
        quantity: qty,
        color: selectedColorId!, // ✅ FIX
        challanNo: _challanNo.text.trim(),
        inwardDate: DateFormat('yyyy-MM-dd').format(inwardDate),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Yarn inward recorded")),
        );
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
    _lotNo.dispose();
    _quantity.dispose();
    _challanNo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Yarn Inward")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<int>(
                value: partyId,
                decoration: const InputDecoration(
                  labelText: "Party",
                  border: OutlineInputBorder(),
                ),
                items: parties
                    .map<DropdownMenuItem<int>>(
                      (p) => DropdownMenuItem(
                        value: p['id'],
                        child: Text(p['name']),
                      ),
                    )
                    .toList(),
                onChanged: widget.partyId != null
                    ? null
                    : (v) => setState(() => partyId = v),
                validator: (v) => v == null ? "Select party" : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<int>(
                value: yarnId,
                decoration: const InputDecoration(
                  labelText: "Yarn",
                  border: OutlineInputBorder(),
                ),
                items: yarns
                    .map<DropdownMenuItem<int>>(
                      (y) => DropdownMenuItem(
                        value: y['id'],
                        child: Text(y['name']),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => yarnId = v),
                validator: (v) => v == null ? "Select yarn" : null,
              ),
              const SizedBox(height: 16),

              // ✅ CLEAN COLOR DROPDOWN
              DropdownButtonFormField<int>(
                value: selectedColorId,
                decoration: const InputDecoration(
                  labelText: "Color",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text("Red")),
                  DropdownMenuItem(value: 2, child: Text("Blue")),
                  DropdownMenuItem(value: 3, child: Text("Black")),
                  DropdownMenuItem(value: 4, child: Text("White")),
                ],
                onChanged: (v) => setState(() => selectedColorId = v),
                validator: (v) => v == null ? "Select color" : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _lotNo,
                decoration: const InputDecoration(
                  labelText: "Lot No",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _quantity,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: "Quantity (kg)",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _challanNo,
                decoration: const InputDecoration(
                  labelText: "Challan No",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              ListTile(
                title: Text(
                  "Inward Date: ${DateFormat('dd-MM-yyyy').format(inwardDate)}",
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: pickDate,
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: loading ? null : submit,
                  child: loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Save Yarn Inward"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}