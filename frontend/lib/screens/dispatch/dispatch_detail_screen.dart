import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class DispatchDetailScreen extends StatefulWidget {
final int dispatchId;

const DispatchDetailScreen({
super.key,
required this.dispatchId,
});

@override
State<DispatchDetailScreen> createState() =>
_DispatchDetailScreenState();
}

class _DispatchDetailScreenState extends State<DispatchDetailScreen> {

Map<String, dynamic>? data;
bool loading = true;

@override
void initState() {
super.initState();
loadData();
}

Future<void> loadData() async {
try {
final res =
await ApiService.getDispatchDetail(widget.dispatchId);


  setState(() {
    data = res;
    loading = false;
  });
} catch (e) {
  setState(() => loading = false);
}


}

@override
Widget build(BuildContext context) {


if (loading) {
  return const Scaffold(
    body: Center(child: CircularProgressIndicator()),
  );
}

if (data == null) {
  return const Scaffold(
    body: Center(child: Text("No data")),
  );
}

final rolls = data!['rolls'] ?? [];

return Scaffold(
  appBar: AppBar(
    title: Text(data!['challan_no'] ?? "Dispatch"),
  ),

  body: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// HEADER
        _row("Date", data!['dispatch_date']),
        _row("Party", data!['party_name']),
        _row("Fabric", data!['fabric']),
        _row("Lot", data!['lot_no']),
        _row("Color", data!['color']),
        _row("Design", data!['design_no']),
        _row("Count", data!['count']),

        const SizedBox(height: 16),

        /// SUMMARY
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Rolls: ${data!['total_rolls']}"),
            Text("Weight: ${data!['total_weight']} kg"),
          ],
        ),

        const Divider(height: 24),

        const Text(
          "Roll Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        /// ROLL LIST
        Expanded(
          child: ListView.builder(
            itemCount: rolls.length,
            itemBuilder: (context, index) {
              final r = rolls[index];

              return ListTile(
                title: Text(r['roll_no']),
                trailing: Text(
                  "${double.tryParse(r['quantity'].toString())?.toStringAsFixed(2)} kg",
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
);


}

Widget _row(String label, dynamic value) {
return Padding(
padding: const EdgeInsets.only(bottom: 6),
child: Row(
children: [
SizedBox(
width: 90,
child: Text(
"$label:",
style: const TextStyle(fontWeight: FontWeight.bold),
),
),
Expanded(
child: Text(value?.toString() ?? "-"),
),
],
),
);
}
}
