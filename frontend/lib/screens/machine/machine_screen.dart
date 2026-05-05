import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class MachineScreen extends StatefulWidget {
  const MachineScreen({super.key});

  @override
  State<MachineScreen> createState() => _MachineScreenState();
}

class _MachineScreenState extends State<MachineScreen> {
  List machines = [];
  bool loading = true;

  int running = 0;
  int stopped = 0;
  int alerts = 0;

  Timer? refreshTimer;

  Map? selectedMachine;

  bool showPanel = false;
  double panelWidth = 350;

  @override
  void initState() {
    super.initState();
    loadMachines();

    refreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => loadMachines(),
    );
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> loadMachines() async {
    try {
      final data = await ApiService.getMachines();

      int run = 0;
      int stop = 0;
      int warn = 0;

      for (var m in data) {
        if (m["status"] == "RUNNING") run++;
        if (m["status"] == "STOPPED") stop++;
        if (m["status"] == "YARN_REQUIRED") warn++;
      }

      setState(() {
        machines = data;
        running = run;
        stopped = stop;
        alerts = warn;
        loading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Map? getMachine(int machineNo) {
    try {
      return machines.firstWhere(
        (m) => int.parse(m["machine_no"].toString()) == machineNo,
      );
    } catch (_) {
      return null;
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case "RUNNING":
        return Colors.greenAccent;
      case "STOPPED":
        return Colors.redAccent;
      case "CLEANING":
        return Colors.orangeAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        Container(
          color: const Color(0xFF121212),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: LayoutBuilder(
              builder: (context, constraints) {
                int columns = constraints.maxWidth > 1400
                    ? 4
                    : constraints.maxWidth > 900
                        ? 2
                        : 1;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Factory Command Center",
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 30),

                    /// METRICS
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        _metricCardNew(
                          "Machines Running",
                          "$running",
                          Icons.precision_manufacturing,
                          Colors.greenAccent,
                          columns,
                          constraints,
                        ),
                        _metricCardNew(
                          "Machines Stopped",
                          "$stopped",
                          Icons.warning_amber_rounded,
                          Colors.orangeAccent,
                          columns,
                          constraints,
                        ),
                        _metricCardNew(
                          "Total Machines",
                          "${machines.length}",
                          Icons.factory,
                          const Color(0xFF00BFA6),
                          columns,
                          constraints,
                        ),
                        _metricCardNew(
                          "Yarn Alerts",
                          "$alerts",
                          Icons.inventory,
                          Colors.redAccent,
                          columns,
                          constraints,
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    _buildFloor(
                        "Ground Floor",
                        [1,2,3,4,5,6,7,8,9,10,11,12],
                        constraints),

                    const SizedBox(height: 30),

                    _buildFloor(
                        "Second Floor",
                        [13,14,15,16,17,18,19,20,21,26,27,28,29],
                        constraints),

                    const SizedBox(height: 30),

                    _buildFloor(
                        "Third Floor",
                        [22,23,24,25,30,31],
                        constraints),
                  ],
                );
              },
            ),
          ),
        ),

        /// RIGHT PANEL
        if (showPanel)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Row(
              children: [
                GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      panelWidth -= details.delta.dx;
                      panelWidth = panelWidth.clamp(250, 600);
                    });
                  },
                  child: Container(
                    width: 6,
                    color: Colors.grey.shade800,
                  ),
                ),
                Container(
                  width: panelWidth,
                  color: const Color(0xFF1A1A1A),
                  padding: const EdgeInsets.all(20),
                  child: selectedMachine == null
                      ? const Text("No Machine")
                      : _buildDetails(selectedMachine!),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFloor(
      String title, List<int> machinesList, BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: machinesList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: constraints.maxWidth > 1500
                ? 8
                : constraints.maxWidth > 1200
                    ? 6
                    : 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.95,
          ),
          itemBuilder: (context, index) {
            int machineNumber = machinesList[index];
            final m = getMachine(machineNumber);

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedMachine = m;
                  showPanel = true;
                });
              },
              child: _machineCard(machineNumber, m),
            );
          },
        ),
      ],
    );
  }

  Widget _machineCard(int machineNo, Map? m) {
    final status = m?["status"] ?? "STOPPED";

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("M-$machineNo",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text("RPM: ${m?['rpm'] ?? 0}", style: const TextStyle(fontSize: 11)),
          Text("Job: ${m?['job_no'] ?? "-"}",
              style: const TextStyle(fontSize: 11)),
          const Spacer(),
          Row(
            children: [
              Icon(Icons.circle, size: 10, color: statusColor(status)),
              const SizedBox(width: 6),
              Text(status,
                  style:
                      TextStyle(color: statusColor(status), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricCardNew(
    String title,
    String value,
    IconData icon,
    Color color,
    int columns,
    BoxConstraints constraints,
  ) {
    return Container(
      width: constraints.maxWidth / columns - 20,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Row(
        children: [
          Icon(icon, size: 36, color: color),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: color)),
              const SizedBox(height: 4),
              Text(title,
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(Map m) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Machine ${m['machine_no']}",
            style:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text("Status: ${m['status']}"),
        Text("RPM: ${m['rpm']}"),
        Text("Counter: ${m['counter']}"),
        Text("Roll Size: ${m['roll_size']} kg"),
        Text("Job: ${m['job_no']}"),

        const SizedBox(height: 20),

        ElevatedButton(
          onPressed: () => _showPerformanceDialog(m),
          child: const Text("Update Performance"),
        ),

        const SizedBox(height: 12),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: statusColor(m['status']),
          ),
          onPressed: () => _changeStatus(m),
          child: const Text("Change Status"),
        ),
      ],
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
        title: const Text("Update Machine"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: rpmController),
            TextField(controller: counterController),
            TextField(controller: rollSizeController),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await ApiService.updateMachinePerformance(
                machineId: machine['id'],
                rpm: int.tryParse(rpmController.text) ?? 0,
                counter: int.tryParse(counterController.text) ?? 0,
                rollSize: double.tryParse(rollSizeController.text) ?? 0,
              );
              Navigator.pop(context);
              loadMachines();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _changeStatus(Map machine) async {
    final statuses = ["RUNNING","STOPPED","CLEANING","YARN_REQUIRED"];

    await showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: statuses.map((status) {
              return ListTile(
                leading: Icon(Icons.circle, color: statusColor(status)),
                title: Text(status),
                onTap: () async {
                  Navigator.pop(context);
                  await ApiService.updateMachineStatus(machine['id'], status);
                  loadMachines();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}