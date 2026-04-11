import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class MachineScreen extends StatefulWidget {
  const MachineScreen({super.key});

  @override
  State<MachineScreen> createState() => _MachineScreenState();
}

class _MachineScreenState extends State<MachineScreen> {
  late Future<List<dynamic>> _machinesFuture;
  Map<String, dynamic>? selectedMachine;

  @override
  void initState() {
    super.initState();
    _loadMachines();
  }

  void _loadMachines() {
    _machinesFuture = ApiService.getMachines();
  }

  Future<void> _refresh() async {
    setState(() {
      _loadMachines();
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case "RUNNING":
        return Colors.greenAccent;
      case "CLEANING":
        return Colors.orangeAccent;
      case "IDLE":
        return Colors.blueGrey;
      case "YARN_NEEDED":
        return Colors.purpleAccent;
      case "SETTING":
        return Colors.tealAccent;
      default:
        return Colors.grey;
    }
  }

 double _calculateEstimated24(Map machine) {
  final rpm =
      double.tryParse(machine['rpm']?.toString() ?? "0") ?? 0;

  final counter =
      double.tryParse(machine['counter']?.toString() ?? "1") ?? 1;

  if (rpm == 0 || counter == 0) return 0;

  final totalRotations24h = rpm * 60 * 24;
  final production24h = totalRotations24h / counter;

  return production24h;
}

double _calculateEstimatedKg24(Map machine) {
  final productionUnits = _calculateEstimated24(machine);

  final rollSize =
      double.tryParse(machine['roll_size']?.toString() ?? "0") ?? 0;

  if (rollSize == 0) return 0;

  return productionUnits * rollSize;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1B2E),
      body: FutureBuilder<List<dynamic>>(
        future: _machinesFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final machines = snapshot.data!;
          if (machines.isEmpty) {
            return const Center(child: Text("No machines"));
          }

          selectedMachine ??= machines.first;

          return Row(
            children: [

              /// LEFT SIDEBAR
              Container(
                width: 260,
                color: const Color(0xFF25203A),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "MANUFACTURING UNIT",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyanAccent,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: machines.length,
                        itemBuilder: (context, index) {
                          final m = machines[index];
                          final isSelected =
                              m['id'] == selectedMachine!['id'];

                          return ListTile(
                            selected: isSelected,
                            selectedTileColor:
                                Colors.cyan.withOpacity(0.15),
                            title: Text(
                              "Machine ${m['machine_no']}",
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.cyanAccent
                                    : Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              m['status'],
                              style: const TextStyle(fontSize: 12),
                            ),
                            onTap: () {
                              setState(() {
                                selectedMachine = m;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              /// MAIN PANEL
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      _headerCard(selectedMachine!),

                      const SizedBox(height: 20),

                      /// FIRST ROW
                      Row(
                        children: [
                          _bigCard(
                              "Est. Kg (24h)",
                              _calculateEstimatedKg24(selectedMachine!)
                                  .toStringAsFixed(2),
                              Colors.cyanAccent,
                            ),

                          _bigCard(
                            "Est. (24h)",
                            _calculateEstimated24(selectedMachine!)
                                .toStringAsFixed(2),
                            Colors.orangeAccent,
                          ),

                          _bigCard(
                            "Actual Production",
                            "${selectedMachine!['actual_production']?.toStringAsFixed(1) ?? "0"} kg",
                            Colors.greenAccent,
                          ),

                          _bigCard(
                            "Design No",
                            selectedMachine!['design_no'] ?? "-",
                            Colors.purpleAccent,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// SECOND ROW
                      Row(
                        children: [
                          _miniCard(
                            "RPM",
                            selectedMachine!['rpm']?.toString() ?? "0",
                          ),
                          _miniCard(
                            "Counter",
                            selectedMachine!['counter']?.toString() ?? "0",
                          ),
                          _miniCard(
                            "Roll Size",
                            selectedMachine!['roll_size'] != null &&
                                    selectedMachine!['roll_size'] != 0
                                ? "${selectedMachine!['roll_size']} kg"
                                : "-",
                          ),
                          _miniCard(
                            "Status",
                            selectedMachine!['status'] ?? "-",
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A243F),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Text(
                              "Production Graph Area",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _headerCard(Map m) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Machine ${m['machine_no']}",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BFA6),
                  foregroundColor: Colors.black,
                ),
                icon: const Icon(Icons.speed),
                label: const Text("Update RPM"),
                onPressed: () => _showPerformanceDialog(m),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _statusColor(m['status']),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  m['status'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showPerformanceDialog(Map machine) async {
    final rpmController =
        TextEditingController(text: machine['rpm']?.toString() ?? "0");

    final counterController =
        TextEditingController(text: machine['counter']?.toString() ?? "0");

    final rollSizeController =
        TextEditingController(text: machine['roll_size']?.toString() ?? "0");

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Update Machine Performance"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: rpmController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "RPM"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: counterController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Counter"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: rollSizeController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Roll Size (kg)"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BFA6),
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              await ApiService.updateMachinePerformance(
                machineId: machine['id'],
                rpm: int.tryParse(rpmController.text) ?? 0,
                counter: int.tryParse(counterController.text) ?? 0,
                rollSize:
                    double.tryParse(rollSizeController.text) ?? 0,
              );
              Navigator.pop(context);
              _refresh();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Widget _bigCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: const Color(0xFF2A243F),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 14),
            Text(value,
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: color)),
          ],
        ),
      ),
    );
  }

  Widget _miniCard(String title, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A243F),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 10),
            Text(value,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}