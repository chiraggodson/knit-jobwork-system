import 'package:knit_jobwork_app/screens/dispatch/jobwise_dispatch_screen.dart';

import 'edit_job_screen.dart';
import 'package:flutter/material.dart';
import '../yarn/issue_yarn_screen.dart';
import '../yarn/yarn_return_screen.dart';
import '../../services/api_service.dart';
import '../dispatch/dispatch_screen.dart';
import '../yarn/setting_fabric_screen.dart';
import '../production/production_entry_screen.dart';
import 'po_print_screen.dart';


class JobDetailScreen extends StatefulWidget {
  final int jobId;
  final String jobNo;

  const JobDetailScreen({
    super.key,
    required this.jobId,
    required this.jobNo,
  });

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}


class _JobDetailScreenState extends State<JobDetailScreen> {
  late Future<Map<String, dynamic>> jobFuture;

  bool dispatchExpanded = false;
bool dispatchLoading = false;
List<dynamic> dispatchHistory = [];
  bool yarnExpanded = false;
  bool productionExpanded = false;

  List<dynamic> yarnHistory = [];
  List<dynamic> productionHistory = [];

  bool yarnLoading = false;
  bool productionLoading = false;

  @override
  void initState() {
    super.initState();
    loadJob();
  }

  void loadJob() {
    jobFuture = ApiService.getJobDetail(widget.jobNo);
  }

  Future<void> loadYarnHistory() async {
    setState(() => yarnLoading = true);
    yarnHistory =
        await ApiService.getJobYarnHistory(widget.jobNo);
    setState(() => yarnLoading = false);
  }

  Future<void> loadProductionHistory() async {
    setState(() => productionLoading = true);
    productionHistory =
        await ApiService.getJobProductionHistory(widget.jobNo);
    setState(() => productionLoading = false);
  }

  Future<void> loadDispatchHistory() async {

  setState(() => dispatchLoading = true);

  dispatchHistory =
      await ApiService.getJobDispatchHistory(widget.jobNo);

  setState(() => dispatchLoading = false);

}

  Future<void> refreshAfterNav(Future<bool?> nav) async {
    final result = await nav;
    if (result == true) {
      setState(() {
        loadJob();
      });
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case "YARN_NEEDED":
        return Colors.redAccent;
      case "PAUSED":
        return Colors.orangeAccent;
      case "CLOSED":
        return Colors.deepPurpleAccent;
      case "OPEN":
        return const Color(0xFF00BFA6);
      default:
        return Colors.grey;
    }
  }

  Color transactionColor(String type) {
    switch (type) {
      case "INWARD":
        return Colors.blueAccent;
      case "ISSUE":
        return const Color(0xFF00BFA6);
      case "RETURN":
        return Colors.greenAccent;
      case "WASTE":
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }
  String _monthName(int month) {
  const months = [
    "",
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
  ];
  return months[month];
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      
        appBar: AppBar(
          title: Text("Job ${widget.jobNo}"),
        ),

      body: FutureBuilder<Map<String, dynamic>>(
        future: jobFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Failed to load job details"));
          }

          final job = snapshot.data!;
          
          
          
          double safeDouble(dynamic v) =>
              double.tryParse(v?.toString() ?? '0') ?? 0;

          final partyName = job['party_name'] ?? '-';
          final machineNo = job['machine_no']?.toString() ?? '-';
          final fabricType = job['fabric_name'] ?? '-';
          final gsm = job['gsm']?.toString() ?? '-';

          final orderQty = safeDouble(job['order_quantity']);
          final yarnIssued = safeDouble(job['yarn_issued']);
          final fabricProduced = safeDouble(job['fabric_produced']);
          final yarnReturned = safeDouble(job['yarn_returned']);
          final waste = safeDouble(job['waste']);
          final status = job['status'] ?? 'OPEN';
          final yarnNeeded = orderQty - yarnIssued;

          final fabricDispatched = safeDouble(job['fabric_dispatched']);
          final warehouseStock = fabricProduced - fabricDispatched;
          final yarns = job['yarns'] ?? [];
          print("YARNS DATA: $yarns");
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
        
  /// ================= HEADER =================///
              _card(
  child: LayoutBuilder(
    builder: (context, constraints) {
      bool wide = constraints.maxWidth > 900;

      /// LEFT: PARTY INFO
      Widget leftSection = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            partyName.toUpperCase(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.grey),
          const SizedBox(height: 12),

          infoRow("Machine", machineNo),
          infoRow("Fabric", fabricType),
          infoRow("GSM", gsm),
          infoRow("Order Quantity",
              "${orderQty.toStringAsFixed(2)} kg"),
        ],
      );

      /// CENTER: YARNS REQUIRED TABLE
     Widget yarnSection = Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Text(
      "Yarns Required",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
    const SizedBox(height: 12),

    /// HEADER
    Row(
      children: const [
        Expanded(child: Text("Yarn")),
        Expanded(child: Text("Issued")),
        Expanded(child: Text("Required")),
        Expanded(child: Text("Balance")),
      ],
    ),
    const Divider(),

    /// DATA
    ...yarns.map<Widget>((y) {
      final name = y['yarn_name'] ?? '';

      final mixPercent =
          double.tryParse(y['mix_percent']?.toString() ?? '0') ?? 0;
      final displayName = "$name (${mixPercent.toStringAsFixed(0)}%)";
      final issued =
          double.tryParse(y['issued']?.toString() ?? '0') ?? 0;

      final required = orderQty * (mixPercent / 100);
      final balance = required - issued;

      Color balanceColor;
      if (balance > 5) {
        balanceColor = Colors.redAccent;
      } else if (balance > 0) {
        balanceColor = Colors.orangeAccent;
      } else {
        balanceColor = Colors.greenAccent;
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
  child: RichText(
    text: TextSpan(
      text: name,
      style: const TextStyle(color: Colors.white),
      children: [
        TextSpan(
          text: " (${mixPercent.toStringAsFixed(0)}%)",
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    ),
  ),
),
            Expanded(child: Text("${issued.toStringAsFixed(2)}")),
            Expanded(child: Text("${required.toStringAsFixed(2)}")),
            Expanded(
              child: Text(
                "${balance.toStringAsFixed(2)}",
                style: TextStyle(
                  color: balanceColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList(),  // ✅ VERY IMPORTANT

  ], // ✅ THIS WAS MISSING
);

      /// RIGHT: IMAGE
      Widget imageSection = Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF00BFA6).withOpacity(0.4),
          ),
        ),
        child: job['fabric_image'] == null
            ? const Center(
                child: Text(
                  "No Fabric Image",
                  style: TextStyle(color: Colors.grey),
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  "${ApiService.baseUrl.replaceAll('/api', '')}/uploads/${job['fabric_image']}",
                  fit: BoxFit.cover,
                ),
              ),
      );

      /// FINAL LAYOUT
      if (wide) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: leftSection),
            const SizedBox(width: 20),
            Expanded(flex: 4, child: yarnSection),
            const SizedBox(width: 20),
            Expanded(flex: 3, child: imageSection),
          ],
        );
      } else {
        return Column(
          children: [
            leftSection,
            const SizedBox(height: 16),
            yarnSection,
            const SizedBox(height: 16),
            imageSection,
          ],
        );
      }
    },
  ),
),
             
              
              /// ================= STATS =================
              _card(
                child: Column(
                  children: [
                    statRow("Yarn Issued", yarnIssued),
                    const Divider(color: Colors.grey),
                    statRow("Fabric Produced", fabricProduced),
                    const Divider(color: Colors.grey),
                    statRow(
                      "Fabric Dispatched",
                      safeDouble(job['fabric_dispatched']),
                    ),
                    const Divider(color: Colors.grey),
                    statRow("Yarn Returned", yarnReturned),
                    const Divider(color: Colors.grey),
                    statRow("Waste", waste),
                  ],
                ),
              ),
                
              /// ================= YARN HISTORY =================
              _card(
                child: ExpansionTile(
                  title: const Text(
                    "Yarn Transaction History",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00BFA6)),
                  ),
                  onExpansionChanged: (val) async {
                    setState(() => yarnExpanded = val);
                    
                    if (val && yarnHistory.isEmpty) {
                      await loadYarnHistory();
                    }
                  },
                  children: [
                    if (yarnLoading)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      )
                    else
                      ...yarnHistory.map((y) {
                      final type = y['transaction_type'] ?? '';
                      final yarnName = y['yarn_name'] ?? '';
                      final lotNo = y['lot_no'] ?? '';
                      final qty = double.tryParse(y['quantity'].toString()) ?? 0;
                      final date = DateTime.tryParse(y['created_at'].toString());
                      final user = y['created_by'] ?? 'SYSTEM';

                      String formattedDate = '';
                      if (date != null) {
                        formattedDate =
                            "${date.day.toString().padLeft(2, '0')} "
                            "${_monthName(date.month)} "
                            "${date.year} at "
                            "${date.hour.toString().padLeft(2, '0')}:"
                            "${date.minute.toString().padLeft(2, '0')}";
                      }

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade800),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            /// FIRST LINE
                            Row(
                              children: [
                                Text(
                                  type,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: transactionColor(type),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text("|", style: TextStyle(color: Colors.grey)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "$yarnName - Lot: $lotNo",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text("|", style: TextStyle(color: Colors.grey)),
                                const SizedBox(width: 8),
                                Text(
                                  "${qty.toStringAsFixed(2)} kg",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF00BFA6),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            /// SECOND LINE
                            Text(
                              "$formattedDate | $user",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// ================= PRODUCTION HISTORY =================
              _card(
                child: ExpansionTile(
                  title: const Text(
                    "Production History",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00BFA6)),
                  ),
                  onExpansionChanged: (val) async {
                    setState(() => productionExpanded = val);
                    if (val && productionHistory.isEmpty) {
                      await loadProductionHistory();
                    }
                  },
                  children: [
                    if (productionLoading)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      )
                    else
                      ...productionHistory.map((p) {
                        return ListTile(
                          title: Text(
                            "Roll: ${p['roll_no']}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                              "${p['quantity']} kg | ${p['created_at']}"),
                        );
                      }),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              /// ================= DISPATCH HISTORY =================
              _card(
                child: ExpansionTile(
                  title: const Text(
                    "Dispatch History",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00BFA6),
                    ),
                  ),
                  onExpansionChanged: (val) async {

                    setState(() => dispatchExpanded = val);

                    if (val && dispatchHistory.isEmpty) {
                      await loadDispatchHistory();
                    }

                  },
                  children: [

                    if (dispatchLoading)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      )
                    else
                      ...dispatchHistory.map((d) {

                        final qty =
                            double.tryParse(d['quantity'].toString()) ?? 0;

                        return ListTile(

                          title: Text(
                            "Roll: ${d['roll_no']}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          subtitle: Text(
                            "${qty.toStringAsFixed(2)} kg | ${d['dispatched_at']}",
                          ),

                        );

                      }),

                  ],
                ),
              ),

              /// ================= ACTIONS =================
              if (status == "OPEN")
                actionButton(
                  icon: Icons.edit,
                  label: "Edit Job",
                  onTap: () {
                    refreshAfterNav(
                      Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditJobScreen(
                            job: job,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                if (status == "OPEN")
                actionButton(
                  icon: Icons.inventory,
                  label: "Issue Yarn",
                  onTap: () {
                    refreshAfterNav(
                      Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => IssueYarnScreen(
                            jobId: widget.jobId,
                            partyId: job['party_id'],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              if (status == "OPEN")
                actionButton(
                  icon: Icons.tune,
                  label: "Setting Fabric",
                  onTap: () {
                    refreshAfterNav(
                      Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SettingFabricScreen(
                            jobId: widget.jobId,
                            partyId: job['party_id'],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
              if (status == "OPEN")
                actionButton(
                  icon: Icons.add_box,
                  label: "Add Production",
                  onTap: () {
                    refreshAfterNav(
                      Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductionEntryScreen(jobId: widget.jobId,jobNo: widget.jobNo,),
                        ),
                      ),
                    );
                  },
                ),

              if (status == "OPEN")
                actionButton(
                  icon: Icons.undo,
                  label: "Yarn Return",
                  onTap: () {
                    refreshAfterNav(
                      Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => YarnReturnScreen(
                            jobId: widget.jobId,
                            partyId: job['party_id'],
                          ),
                        ),
                      ),
                    );
                  },
                ),

              /*
                if (status == "OPEN")
                actionButton(
                  icon: Icons.local_shipping,
                  label: "Dispatch Fabric",
                  onTap: () {
                    refreshAfterNav(
                      Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => JobwiseDispatchScreen(
                            jobId: widget.jobId,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                */
                
                if (status == "OPEN")
                actionButton(
                  icon: Icons.lock,
                  label: "Close Job",
                  
                  onTap: () async {

                    final confirm = await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Close Job"),
                          content: const Text(
                            "Are you sure you want to close this job?",
                          ),
                          actions: [

                            TextButton(
                              child: const Text("Cancel"),
                              onPressed: () => Navigator.pop(context, false),
                            ),

                            ElevatedButton(
                              child: const Text("Close Job"),
                              onPressed: () => Navigator.pop(context, true),
                            ),

                          ],
                        );
                      },
                    );

                    if (confirm == true) {

                      await ApiService.closeJob(widget.jobNo);

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Job closed")),
                      );

                      loadJob();

                    }
                    ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PoPrintScreen(
          poData: {
            "id": job.id,
            "party_name": job.partyName,
            "fabric_name": job.fabricName,
            "quantity": job.quantity,
            "date": job.date,
          },
        ),
      ),
    );
  },
  child: const Text("Print PO"),
),
                  },
                ),

            ],
          );
        },
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: child,
    );
  }

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget statTile(String label, double value) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.25),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey.shade800),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          "${value.toStringAsFixed(2)} kg",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00BFA6),
          ),
        ),

      ],
    ),
  );
}

  

  Widget statRow(String label, double value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          "${value.toStringAsFixed(2)} kg",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF00BFA6),
          ),
        ),
      ],
    ),
  );
}


  Widget actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SizedBox(
        height: 52,
        child: ElevatedButton.icon(
          icon: Icon(icon),
          label: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          onPressed: onTap,
        ),
      ),
    );
 
 
  }
}

class FullImageView extends StatelessWidget {
  final String imageUrl;

  const FullImageView({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: InteractiveViewer(
        minScale: 0.5,
        maxScale: 6,
        child: SizedBox.expand(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
   
}

