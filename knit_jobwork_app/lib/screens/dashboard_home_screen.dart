import 'package:flutter/material.dart';

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
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
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                /// =======================
                /// TOP METRICS
                /// =======================

                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: [

                    _metricCard(
                      "Machines Running",
                      "18",
                      Icons.precision_manufacturing,
                      Colors.greenAccent,
                      4,
                      constraints,
                    ),

                    _metricCard(
                      "Machines Stopped",
                      "3",
                      Icons.warning_amber_rounded,
                      Colors.orangeAccent,
                      4,
                      constraints,
                    ),

                    _metricCard(
                      "Active Jobs",
                      "12",
                      Icons.factory,
                      const Color(0xFF00BFA6),
                      4,
                      constraints,
                    ),

                    _metricCard(
                      "Yarn Alerts",
                      "2",
                      Icons.inventory,
                      Colors.redAccent,
                      4,
                      constraints,
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                /// =======================
                /// MACHINE STATUS GRID
                /// =======================

                const Text(
                  "Machine Status",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),
                _buildFloor("Ground Floor", [ 1,2,3,4,5,6,7,8,9,10,11,12], constraints),
                const SizedBox(height: 30),
                _buildFloor("Second Floor", [13,14,15,16,17,18,19,20,21,26,27,28,29], constraints),
                const SizedBox(height: 30),
                _buildFloor("Third Floor", [22,23,24,25,30,31], constraints),

                /// =======================
                /// RECENT ACTIVITY
                /// =======================

                const Text(
                  "Recent Activity",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Container( 
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade800),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        "• Job #1203 started on Machine 4",
                        style: TextStyle(color: Colors.white70),
                      ),

                      SizedBox(height: 8),

                      Text(
                        "• Yarn issued to Job #1201",
                        style: TextStyle(color: Colors.white70),
                      ),

                      SizedBox(height: 8),

                      Text(
                        "• Machine 7 cleaning completed",
                        style: TextStyle(color: Colors.white70),
                      ),

                      SizedBox(height: 8),

                      Text(
                        "• Dispatch completed for Job #1198",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// =======================
/// METRIC CARD
/// =======================

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

        Icon(
          icon,
          size: 36,
          color: color,
        ),

        const SizedBox(width: 16),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

/// =======================
/// MACHINE CARD
/// =======================
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

    default:
      statusColor = Colors.orangeAccent;
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

        /// MACHINE NUMBER
        Text(
          "MACHINE $machineNo",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 4),

        /// MACHINE TYPE
        Text(
          machineType,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),

        const Spacer(),

        /// STATUS
        Row(
          children: [
            Icon(Icons.circle, size: 10, color: statusColor),
            const SizedBox(width: 6),
            Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        /// JOB
        Text(
          "Job: $job",
          style: const TextStyle(fontSize: 12),
        ),

        /// PRODUCTION
        Text(
          "Prod: ${production.toStringAsFixed(1)} kg",
          style: const TextStyle(fontSize: 12),
        ),

        /// RPM
        Text(
          "RPM: $rpm",
          style: const TextStyle(fontSize: 12),
        ),

        /// COUNTER
        Text(
          "Counter: $counter",
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    ),
  );
}

Widget _buildFloor(
  String title,
  List<int> machines,
  BoxConstraints constraints,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 16),

      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: machines.length,
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

          int machineNumber = machines[index];

          return _machineCard(
            machineNumber,
            "Interlock", // machine type placeholder
            index % 3 == 0
                ? "RUNNING"
                : index % 3 == 1
                    ? "STOPPED"
                    : "CLEANING",
            "1203",      // job placeholder
            420.5,       // production placeholder
            28,          // rpm placeholder
            845120,      // counter placeholder
          );
        },
      ),
    ],
  );
}