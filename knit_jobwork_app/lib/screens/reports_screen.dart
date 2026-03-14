import 'package:flutter/material.dart';
import 'party_stock_report_screen.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Reports"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            _ReportCard(
              icon: Icons.factory,
              title: "Job Reports",
            ),
            _ReportCard(
              icon: Icons.inventory,
              title: "Yarn Reports",
            ),
            _ReportCard(
              icon: Icons.precision_manufacturing,
              title: "Machine Reports",
            ),
            _ReportCard(
  icon: Icons.bar_chart,
  title: "Stock Summary",
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PartyStockReportScreen(),
      ),
    );
  },
),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;   // ✅ ADD THIS

  const _ReportCard({
    required this.icon,
    required this.title,
    this.onTap,                // ✅ ADD THIS
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,   // ✅ USE IT HERE
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: const Color(0xFF00BFA6),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}