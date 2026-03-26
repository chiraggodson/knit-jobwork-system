import 'create_job_screen.dart';
import 'job_detail_screen.dart';
import '../services/api_service.dart';
import 'package:flutter/material.dart';

/* ================= JOB SUMMARY SCREEN ================= */

class JobReportScreen extends StatefulWidget {

  
  const JobReportScreen({super.key});

  @override
  State<JobReportScreen> createState() => _JobReportScreenState();
}

Widget _bigMetric(String label, double value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value.toStringAsFixed(2),
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.grey,
          letterSpacing: 1,
        ),
      ),
    ],
  );
}

Widget _bigPercent(int percent) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "$percent%",
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF00BFA6),
        ),
      ),
      const SizedBox(height: 6),
      const Text(
        "COMPLETION",
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey,
          letterSpacing: 1,
        ),
      ),
    ],
  );
}

Widget _smallMetric(String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
    ],
  );
}
class _JobReportScreenState extends State<JobReportScreen> {
  
Widget _smallMetric(String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
    ],
  );
}


  String _sortType = "latest";
  void _sortJobs(List jobs) {
  switch (_sortType) {

    case "oldest":
      jobs.sort((a, b) =>
          a['job_no'].toString().compareTo(b['job_no'].toString()));
      break;

    case "production_high":
      jobs.sort((a, b) {
        double aVal = double.tryParse(a['production_qty'].toString()) ?? 0;
        double bVal = double.tryParse(b['production_qty'].toString()) ?? 0;
        return bVal.compareTo(aVal);
      });
      break;

    case "production_low":
      jobs.sort((a, b) {
        double aVal = double.tryParse(a['production_qty'].toString()) ?? 0;
        double bVal = double.tryParse(b['production_qty'].toString()) ?? 0;
        return aVal.compareTo(bVal);
      });
      break;

    case "status":
      jobs.sort((a, b) =>
          a['status'].toString().compareTo(b['status'].toString()));
      break;

    default: // latest
      jobs.sort((a, b) =>
          b['job_no'].toString().compareTo(a['job_no'].toString()));
  }
}



  late Future<List<dynamic>> _jobsFuture;


  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  void _showSortOptions() {
  showModalBottomSheet(
    context: context,
    builder: (_) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          const Text(
            "Sort Jobs",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          _sortTile("Latest Job", "latest"),
          _sortTile("Oldest Job", "oldest"),
          _sortTile("Highest Production", "production_high"),
          _sortTile("Lowest Production", "production_low"),
          _sortTile("Status", "status"),

          const SizedBox(height: 16),
        ],
      );
    },
  );
}

Widget _sortTile(String title, String value) {
  return ListTile(
    title: Text(title),
    trailing: _sortType == value ? const Icon(Icons.check) : null,
    onTap: () {
      setState(() {
        _sortType = value;
      });
      Navigator.pop(context);
    },
  );
}

  void _loadJobs() {
    _jobsFuture = ApiService.getJobs();
  }

  Future<void> _refreshJobs() async {
    setState(() {
      _loadJobs();
    });
  }

  Color statusColor(String? status) {
  
  switch (status) {
  
    case "YARN_NEEDED":
      return Colors.redAccent.shade200;
    case "PAUSED":
      return Colors.orangeAccent.shade200;
    case "CLOSED":
      return Colors.deepPurpleAccent.shade200;
    case "OPEN":
      return Colors.greenAccent.shade400;
    default:
      return Colors.grey;
  
}
}

  Widget summaryBox(String title, double value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 12, color: color)),
            const SizedBox(height: 4),
            Text(
              value.toStringAsFixed(2),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateAndRefresh(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    _refreshJobs(); // 👈 AUTO RELOAD AFTER RETURN
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
        title: const Text("Job Summary"),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        
        tooltip: "Create Job",
        onPressed: () =>
            _navigateAndRefresh(const CreateJobScreen()),
        child: const Icon(Icons.add),
      )
    : null,

      body: FutureBuilder<List<dynamic>>(
        future: _jobsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final jobs = snapshot.data ?? [];
          _sortJobs(jobs);
          if (jobs.isEmpty) {
            return const Center(child: Text("No jobs created yet"));
          }

          return RefreshIndicator(
            onRefresh: _refreshJobs,
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                final j = jobs[index];

                final int? jobId = j['id'];
                final String? jobNo = j['job_no'];
                final int? partyId = j['party_id'];
                

                final String status = j['status']?.toString() ?? 'OPEN';

                final double orderQty =
                    double.tryParse(j['order_quantity'].toString()) ?? 0;

                final double production =
                    double.tryParse(j['actual_production'].toString()) ?? 0;

                final double productionLeft = (orderQty - production) < 0
                    ? 0
                    : (orderQty - production);

                final double progress =
                    orderQty == 0 ? 0 : (production / orderQty).clamp(0, 1);

                final int progressPercent = (progress * 100).round();

                return Container(
  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
  decoration: BoxDecoration(
    color: const Color(0xFF1A1A1A),
    borderRadius: BorderRadius.circular(6),
    border: Border.all(color: Colors.grey.shade800, width: 1),
  ),
  child: InkWell(
    onTap: jobId == null
        ? null
        : () => _navigateAndRefresh(
              JobDetailScreen(jobId: jobId, jobNo: jobNo ?? ''),
            ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        /// INDUSTRIAL SINGLE LINE HEADER
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  /// JOB NO
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BFA6).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      jobNo ?? "-",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF00BFA6),
                      ),
                    ),
                  ),

                  const SizedBox(width: 24),

                  /// PARTY NAME
              Expanded(
                child: Text(
                  j['party_name'] ?? "-",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(width: 32),

              /// FABRIC NAME
              Expanded(
                child: Text(
                  j['fabric_name'] ?? "-",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(width: 32),

              /// YARN
              Expanded(
                child: Text(
                  j['yarns_used'] ?? "-",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

                  const SizedBox(width: 24),

                  /// STATUS
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: statusColor(status).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: statusColor(status),
                      ),
                    ),
                  ),
                ],
              ),
                    
                        const SizedBox(height: 24),

                        /// MAIN METRICS (Industrial Grid)
              LayoutBuilder(
                builder: (context, constraints) {
                  int columns = constraints.maxWidth > 1200
                      ? 4
                      : constraints.maxWidth > 800
                          ? 2
                          : 1;

                  return Wrap(
                    spacing: 40,
                    runSpacing: 20,
                    children: [
                      SizedBox(
                        width: constraints.maxWidth / columns - 40,
                        child: _bigMetric("ORDER (KG)", orderQty),
                      ),
                      SizedBox(
                        width: constraints.maxWidth / columns - 40,
                        child: _bigMetric("PRODUCED (KG)", production),
                      ),
                      SizedBox(
                        width: constraints.maxWidth / columns - 40,
                        child: _bigMetric("REMAINING (KG)", productionLeft),
                      ),
                      SizedBox(
                        width: constraints.maxWidth / columns - 40,
                        child: _bigPercent(progressPercent),
                      ),
                    ],
                  );
                },
              ),

                        const SizedBox(height: 18),

                        /// PROGRESS BAR (Thicker)
                        /// INDUSTRIAL PROGRESS BAR
              Container(
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Stack(
                  children: [
                    /// Filled Portion
                    FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: progress == 1
                              ? Colors.greenAccent
                              : progress > 0.7
                                  ? Colors.orangeAccent
                                  : const Color(0xFF00BFA6),
                        ),
                      ),
                    ),

                    /// Center Percentage Text
                    Center(
                      child: Text(
                        "$progressPercent%",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),      

                          const SizedBox(height: 18),

         
                        ],
                      ),
                    ),
                  ),
                );    
              },
            ),
          );
        },
      ),
    );
  }
}
