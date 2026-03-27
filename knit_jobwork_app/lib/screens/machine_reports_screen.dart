import 'package:flutter/material.dart';

class MachineReportsScreen extends StatelessWidget {
  const MachineReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Machine Reports"),
      ),
      body: const Center(
        child: Text(
          "Machine Reports Coming Soon",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}