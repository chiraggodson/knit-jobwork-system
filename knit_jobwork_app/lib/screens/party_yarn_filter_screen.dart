import 'package:flutter/material.dart';
import 'party_yarn_ledger_screen.dart';

class PartyYarnFilterScreen extends StatefulWidget {
  const PartyYarnFilterScreen({super.key});

  @override
  State<PartyYarnFilterScreen> createState() => _PartyYarnFilterScreenState();
}

class _PartyYarnFilterScreenState extends State<PartyYarnFilterScreen> {

  String? selectedParty;
  String? selectedYarn;
  String? selectedColor;
  String? selectedLot;

  DateTime? fromDate;
  DateTime? toDate;

  Future<void> pickDate(BuildContext context, bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  void generateReport() {
    if (selectedParty == null || fromDate == null || toDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select Party & Date Range")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PartyYarnLedgerScreen(
          party: selectedParty!,
          fromDate: fromDate!,
          toDate: toDate!,
          yarn: selectedYarn,
          color: selectedColor,
          lot: selectedLot,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Party Yarn Ledger Filters")),
      backgroundColor: const Color(0xFF121212),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [

            // 🔹 PARTY DROPDOWN
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Select Party"),
              items: ["ABC Textiles", "XYZ KnitFab"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => selectedParty = val),
            ),

            const SizedBox(height: 16),

            // 🔹 DATE RANGE
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => pickDate(context, true),
                    child: Text(fromDate == null
                        ? "From Date"
                        : fromDate.toString().split(' ')[0]),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => pickDate(context, false),
                    child: Text(toDate == null
                        ? "To Date"
                        : toDate.toString().split(' ')[0]),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 🔹 OPTIONAL FILTERS
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Yarn (Optional)"),
              items: ["Cotton 30s", "PC Blend"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => selectedYarn = val),
            ),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Color (Optional)"),
              items: ["Red", "Blue"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => selectedColor = val),
            ),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Lot No (Optional)"),
              items: ["L001", "L002"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => selectedLot = val),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: generateReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BFA6),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text("Generate Report"),
            )
          ],
        ),
      ),
    );
  }
}