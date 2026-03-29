import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:knit_jobwork_app/services/api_service.dart';
import '../yarn/yarn_ledger_screen.dart';

class PartyYarnFilterScreen extends StatefulWidget {
const PartyYarnFilterScreen({super.key});

@override
State<PartyYarnFilterScreen> createState() =>
_PartyYarnFilterScreenState();
}

class _PartyYarnFilterScreenState extends State<PartyYarnFilterScreen> {

List parties = [];

int? selectedPartyId;
String? selectedPartyName;

String? selectedYarn;
String? selectedColor;
String? selectedLot;

DateTime? fromDate;
DateTime? toDate;

@override
void initState() {
super.initState();
fetchParties();
}

Future<void> fetchParties() async {
final res = await http.get(
Uri.parse("${ApiService.baseUrl}/api/parties"),
);


setState(() {
  parties = jsonDecode(res.body);
});


}

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
if (selectedPartyId == null || fromDate == null || toDate == null) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text("Please select Party & Date Range")),
);
return;
}


Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => YarnLedgerScreen(
      partyId: selectedPartyId!,
      partyName: selectedPartyName ?? "",
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


        /// 🔹 PARTY DROPDOWN (REAL DATA)
        DropdownButtonFormField<int>(
          decoration: const InputDecoration(labelText: "Select Party"),
          items: parties.map<DropdownMenuItem<int>>((p) {
            return DropdownMenuItem<int>(
              value: p['id'],
              child: Text(p['name']),
            );
          }).toList(),
          onChanged: (val) {
            final selected = parties.firstWhere((p) => p['id'] == val);
            setState(() {
              selectedPartyId = val;
              selectedPartyName = selected['name'];
            });
          },
        ),

        const SizedBox(height: 16),

        /// 🔹 DATE RANGE
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

        /// 🔹 OPTIONAL FILTERS (leave as-is for now)
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
