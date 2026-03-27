import 'package:flutter/material.dart';

class YarnReportsScreen extends StatelessWidget {
  const YarnReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yarn Reports"),
      ),
      body: const Center(
        child: Text(
          "Yarn Reports Coming Soon",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}