import 'package:flutter/material.dart';
import 'dart:html' as html;

class PoPrintScreen extends StatelessWidget {
  final Map<String, dynamic> poData;

  const PoPrintScreen({super.key, required this.poData});

  void _print() {
    html.window.print();
  }

  @override
  Widget build(BuildContext context) {
    final party = poData['party_name'] ?? '';
    final fabric = poData['fabric_name'] ?? '';
    final quantity = poData['quantity'] ?? '';
    final jobId = poData['id'] ?? '';
    final date = poData['date'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Print Purchase Order"),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _print,
          )
        ],
      ),
      body: Center(
        child: Container(
          width: 800,
          padding: const EdgeInsets.all(24),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              const Text(
                "B&B KNITFAB",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text("Purchase Order"),
              const Divider(),

              const SizedBox(height: 16),

              // INFO
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("PO No: $jobId"),
                  Text("Date: $date"),
                ],
              ),

              const SizedBox(height: 20),

              Text("Party: $party"),
              Text("Fabric: $fabric"),
              Text("Order Quantity: $quantity"),

              const SizedBox(height: 30),

              const Text(
                "Order Details",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Table(
                border: TableBorder.all(),
                children: [
                  const TableRow(children: [
                    Padding(
                        padding: EdgeInsets.all(8),
                        child: Text("Item", style: TextStyle(fontWeight: FontWeight.bold))),
                    Padding(
                        padding: EdgeInsets.all(8),
                        child: Text("Qty", style: TextStyle(fontWeight: FontWeight.bold))),
                  ]),
                  TableRow(children: [
                    Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(fabric)),
                    Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(quantity.toString())),
                  ]),
                ],
              ),

              const Spacer(),

              const SizedBox(height: 40),
              const Text("Authorized Signature"),
            ],
          ),
        ),
      ),
    );
  }
}
