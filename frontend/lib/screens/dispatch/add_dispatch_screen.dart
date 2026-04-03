import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'dispatch_screen.dart';

class AddDispatchScreen extends StatefulWidget {
const AddDispatchScreen({super.key});

@override
State<AddDispatchScreen> createState() => _AddDispatchScreenState();
}

class _AddDispatchScreenState extends State<AddDispatchScreen> {

final _challan = TextEditingController();
final _partyPO = TextEditingController();
final _designNo = TextEditingController();
final _lot = TextEditingController();
final _color = TextEditingController();

DateTime selectedDate = DateTime.now();

List parties = [];
List fabrics = [];

int? selectedPartyId;
String? selectedPartyName;
String? selectedFabric;

bool loading = true;

@override
void initState() {
super.initState();
loadDropdowns();
}

Future<void> loadDropdowns() async {
try {
final p = await ApiService.getParties();
final f = await ApiService.getFabrics();


  setState(() {
    parties = p;
    fabrics = f;
    loading = false;
  });
} catch (e) {
  setState(() => loading = false);
}


}

void next() {


if (_challan.text.isEmpty ||
    selectedPartyId == null ||
    selectedFabric == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Challan, Party & Fabric required")),
  );
  return;
}

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => DispatchScreen(
      jobId: selectedPartyId!, // temp usage

      dispatchData: {
        "challan_no": _challan.text.trim(),
        "date": selectedDate.toIso8601String(),
        "party_id": selectedPartyId,
        "party_name": selectedPartyName,
        "party_po": _partyPO.text.trim(),
        "design_no": _designNo.text.trim(),
        "fabric": selectedFabric,
        "lot_no": _lot.text.trim(),
        "color": _color.text.trim(),
      },
    ),
  ),
);


}

Future<void> pickDate() async {
final picked = await showDatePicker(
context: context,
initialDate: selectedDate,
firstDate: DateTime(2020),
lastDate: DateTime(2100),
);


if (picked != null) {
  setState(() => selectedDate = picked);
}


}

@override
Widget build(BuildContext context) {


if (loading) {
  return const Scaffold(
    body: Center(child: CircularProgressIndicator()),
  );
}

return Scaffold(
  backgroundColor: const Color(0xFF121212),

  appBar: AppBar(
    title: const Text("Add Dispatch"),
  ),

  body: SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [

        /// DATE
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text("Dispatch Date"),
          subtitle: Text(
            "${selectedDate.toLocal()}".split(' ')[0],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: pickDate,
          ),
        ),

        const SizedBox(height: 12),

        _field(_challan, "Challan No"),

        /// PARTY DROPDOWN
        DropdownButtonFormField<int>(
          value: selectedPartyId,
          hint: const Text("Select Party"),
          items: parties.map<DropdownMenuItem<int>>((p) {
            return DropdownMenuItem(
              value: p['id'],
              child: Text(p['name']),
            );
          }).toList(),
          onChanged: (val) {
            final party =
                parties.firstWhere((p) => p['id'] == val);
            setState(() {
              selectedPartyId = val;
              selectedPartyName = party['name'];
            });
          },
        ),

        const SizedBox(height: 12),

        /// FABRIC DROPDOWN
        DropdownButtonFormField<String>(
          value: selectedFabric,
          hint: const Text("Select Fabric"),
          items: fabrics.map<DropdownMenuItem<String>>((f) {
            return DropdownMenuItem(
              value: f['name'],
              child: Text(f['name']),
            );
          }).toList(),
          onChanged: (val) {
            setState(() => selectedFabric = val);
          },
        ),

        const SizedBox(height: 12),

        _field(_partyPO, "Party PO"),
        _field(_designNo, "Design Number"),
        _field(_lot, "Lot Number"),
        _field(_color, "Color"),

        const SizedBox(height: 24),

        /// NEXT BUTTON
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.arrow_forward),
            label: const Text(
              "Select Rolls",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: next,
          ),
        ),
      ],
    ),
  ),
);


}

Widget _field(TextEditingController c, String label) {
return Padding(
padding: const EdgeInsets.only(bottom: 12),
child: TextField(
controller: c,
decoration: InputDecoration(
labelText: label,
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(8),
),
),
),
);
}
}
