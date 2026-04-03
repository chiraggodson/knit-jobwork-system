import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'add_dispatch_screen.dart';

class DispatchListScreen extends StatefulWidget {
const DispatchListScreen({super.key});

@override
State<DispatchListScreen> createState() => _DispatchListScreenState();
}

class _DispatchListScreenState extends State<DispatchListScreen> {
List dispatchList = [];
bool loading = true;

@override
void initState() {
super.initState();
loadDispatch();
}

Future<void> loadDispatch() async {
try {
// 👉 Replace with real API later
final data = await ApiService.getDispatchList();


  setState(() {
    dispatchList = data;
    loading = false;
  });
} catch (e) {
  setState(() => loading = false);
}


}

Future<void> refresh() async {
await loadDispatch();
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: const Color(0xFF121212),


  appBar: AppBar(
    title: const Text("Dispatch"),
  ),

  floatingActionButton: FloatingActionButton(
    onPressed: () async {
      final res = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AddDispatchScreen(),
        ),
      );

      if (res == true) {
        refresh();
      }
    },
    child: const Icon(Icons.add),
  ),

  body: loading
      ? const Center(child: CircularProgressIndicator())
      : dispatchList.isEmpty
          ? const Center(
              child: Text(
                "No dispatch records",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : RefreshIndicator(
              onRefresh: refresh,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: dispatchList.length,
                itemBuilder: (context, index) {
                  final d = dispatchList[index];

                  final challan = d['challan_no'] ?? "-";
                  final date = d['date'] ?? "-";
                  final party = d['party'] ?? "-";
                  final fabric = d['fabric'] ?? "-";
                  final lot = d['lot_no'] ?? "-";
                  final color = d['color'] ?? "-";
                  final rolls = d['total_rolls'] ?? 0;
                  final weight = d['total_weight'] ?? 0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade800),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// TOP ROW
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              challan,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00BFA6),
                              ),
                            ),
                            Text(
                              date,
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        /// PARTY
                        Text(
                          "Party: $party",
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 6),

                        /// FABRIC + LOT + COLOR
                        Text(
                          "Fabric: $fabric",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          "Lot: $lot  |  Color: $color",
                          style: const TextStyle(color: Colors.white70),
                        ),

                        const SizedBox(height: 10),

                        /// SUMMARY
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Rolls: $rolls",
                              style: const TextStyle(
                                color: Colors.orangeAccent,
                              ),
                            ),
                            Text(
                              "Weight: ${weight.toString()} kg",
                              style: const TextStyle(
                                color: Colors.greenAccent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
);


}
}
