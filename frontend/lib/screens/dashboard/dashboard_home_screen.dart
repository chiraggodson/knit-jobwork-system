import 'package:flutter/material.dart';

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF121212),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            /// ICON
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.construction,
                size: 60,
                color: Colors.orangeAccent,
              ),
            ),

            const SizedBox(height: 30),

            /// TITLE
            const Text(
              "Dashboard Coming Soon",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            /// SUBTEXT
            const Text(
              "We’re building something powerful for you 🚀",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            /// OPTIONAL BUTTON
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                // You can navigate somewhere if needed
              },
              child: const Text("Explore Machines"),
            ),
          ],
        ),
      ),
    );
  }
}