import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  
  List machines = [];
  bool loading = true;

  int running = 0;
  int stopped = 0;
  int alerts = 0;

  Timer? refreshTimer;

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
        (m) => int.parse(m["machine_no"].toString()) == machineNo
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: const Color(0xFF121212),
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {

          int columns = constraints.maxWidth > 1400
              ? 4
              : constraints.maxWidth > 900
              ? 2
              : 1;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text(
                  "Factory Command Center",
                  style: TextStyle(fontSize: 26,fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 30),

                /// METRICS

                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: [

                    _metricCard("Machines Running", "$running",
                        Icons.precision_manufacturing,
                        Colors.greenAccent, columns, constraints),

                    _metricCard("Machines Stopped", "$stopped",
                        Icons.warning_amber_rounded,
                        Colors.orangeAccent, columns, constraints),

                    _metricCard("Total Machines", "${machines.length}",
                        Icons.factory,
                        const Color(0xFF00BFA6), columns, constraints),

                    _metricCard("Yarn Alerts", "$alerts",
                        Icons.inventory,
                        Colors.redAccent, columns, constraints),
                  ],
                ),

                const SizedBox(height: 40),

                const Text(
                  "Machine Status",
                  style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                _buildFloor("Ground Floor",
                    [1,2,3,4,5,6,7,8,9,10,11,12], constraints),

                const SizedBox(height: 30),

                _buildFloor("Second Floor",
                    [13,14,15,16,17,18,19,20,21,26,27,28,29], constraints),

                const SizedBox(height: 30),

                _buildFloor("Third Floor",
                    [22,23,24,25,30,31], constraints),

              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloor(String title, List<int> machinesList, BoxConstraints constraints) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(title,
            style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),

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

            if (m == null) {
              return _machineCard(machineNumber,"UNKNOWN","STOPPED","-",
                  0,0,0);
            }

            return _machineCard(
              machineNumber,
              "Interlock",
              m["status"] ?? "STOPPED",
              m["job_no"]?.toString() ?? "-",

              double.tryParse(m["kg_per_hour"].toString()) ?? 0,

              int.tryParse(m["rpm"].toString()) ?? 0,

              int.tryParse(m["counter"].toString()) ?? 0,
            );
          },
        ),
      ],
    );
  }
}

/// METRIC CARD

Widget _metricCard(
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

        Icon(icon,size:36,color:color),

        const SizedBox(width:16),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(value,
              style: TextStyle(
                  fontSize:26,
                  fontWeight:FontWeight.bold,
                  color:color)),

            const SizedBox(height:4),

            Text(title,
                style: const TextStyle(
                    color: Colors.grey,fontSize:13)),
          ],
        ),
      ],
    ),
  );
}

/// MACHINE CARD

Widget _machineCard(
  int machineNo,
  String machineType,
  String status,
  String job,
  double production,
  int rpm,
  int counter,
) {

  Color statusColor;

  switch (status) {
    case "RUNNING":
      statusColor = Colors.greenAccent;
      break;

    case "STOPPED":
      statusColor = Colors.redAccent;
      break;

    case "CLEANING":
      statusColor = Colors.orangeAccent;
      break;

    default:
      statusColor = Colors.grey;
  }

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

        Text("MACHINE $machineNo",
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14)),

        const SizedBox(height:4),

        Text(machineType,
            style: const TextStyle(
                fontSize:12,
                color: Colors.grey)),

        const Spacer(),

        Row(
          children: [

            Icon(Icons.circle,size:10,color:statusColor),
            const SizedBox(width:6),

            Text(status,
                style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ],
        ),

        const SizedBox(height:6),

        Text("Job: $job",style: const TextStyle(fontSize:12)),

        Text("Prod: ${production.toStringAsFixed(1)} kg/h",
            style: const TextStyle(fontSize:12)),

        Text("RPM: $rpm",style: const TextStyle(fontSize:12)),

        Text("Counter: $counter",
            style: const TextStyle(fontSize:12,color: Colors.white70)),
      ],
    ),
  );
}