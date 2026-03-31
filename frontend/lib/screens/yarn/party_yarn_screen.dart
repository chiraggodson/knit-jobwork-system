import 'add_yarn_inward_screen.dart';
import 'package:flutter/material.dart';
import '../party/add_party_screen.dart';
import '../../services/api_service.dart';
import '../party/party_inward_list_screen.dart';

class PartyYarnScreen extends StatelessWidget {
  const PartyYarnScreen({super.key});
  

  // 🔘 Bottom Sheet Actions
  void _showActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Choose Action",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              ListTile(
                leading: const Icon(Icons.inventory),
                title: const Text("Add Yarn Inward"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddYarnInwardScreen(),
                    ),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.person_add),
                title: const Text("Add Party"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddPartyScreen()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Party Yarn Ledger")),

      body: FutureBuilder(
        future: ApiService.getPartyYarnSummary(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final data = snapshot.data as List;

          if (data.isEmpty) {
            return const Center(child: Text("No yarn data"));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final p = data[index];
              print(p);

              // ✅ Safe number parsing
              final balance = double.tryParse(p['balance']?.toString() ?? "0") ?? 0;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 2,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),

                  // 👉 Tap Party → Add Yarn Inward (party pre-selected)
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PartyInwardListScreen(partyId: 
                            p['id'],
                            partyName: p['name']),
                            
                      ),
                    );
                  },

                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p['name']?.toString() ?? "Unknown Party"),
                        
                        const SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Balance: $balance kg"),
                          ],
                        ),

                        const SizedBox(height: 6),


                        Text(
                          "Balance: $balance kg",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: balance > 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),

      // ➕ Global Add Button
      floatingActionButton: FloatingActionButton(
        tooltip: "Add",
        onPressed: () => _showActions(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
