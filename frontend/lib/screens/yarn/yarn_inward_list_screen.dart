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

  List parties = [];
  List yarns = [];

  bool loading = false;

  // Controllers
  final TextEditingController _lotNo = TextEditingController();
  final TextEditingController _quantity = TextEditingController();
  final TextEditingController _boxes = TextEditingController();
  final TextEditingController _challanNo = TextEditingController();

  DateTime inwardDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    partyId = widget.partyId;
    loadData();
  }

  Future<void> loadData() async {
    parties = await ApiService.getParties();
    yarns = await ApiService.getYarnMaster();
    setState(() {});
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

    setState(() => loading = true);

    try {
      await ApiService.addYarnInward(
        partyId: partyId!,
        yarnId: yarnId!,
        lotNo: _lotNo.text.trim(),
        quantity: double.parse(_quantity.text),
        
        challanNo: _challanNo.text.trim(),
        inwardDate: DateFormat('yyyy-MM-dd').format(inwardDate),
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Yarn inward recorded")));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => loading = false);
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
              // PARTY
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

              // YARN
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

              // LOT NO
              TextFormField(
                controller: _lotNo,
                decoration: const InputDecoration(
                  labelText: "Lot No",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              // QUANTITY
              TextFormField(
                controller: _quantity,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Quantity (kg)",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              // BOXES
              TextFormField(
                controller: _boxes,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "No. of Boxes",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              // CHALLAN NO
              TextFormField(
                controller: _challanNo,
                decoration: const InputDecoration(
                  labelText: "Challan No",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              // DATE
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

              // SUBMIT
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: loading ? null : submit,
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
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
