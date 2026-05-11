import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/api_service.dart';

class AddYarnInwardScreen extends StatefulWidget {
  final int? partyId;

  const AddYarnInwardScreen({
    super.key,
    this.partyId,
  });

  @override
  State<AddYarnInwardScreen> createState() =>
      _AddYarnInwardScreenState();
}

class _AddYarnInwardScreenState
    extends State<AddYarnInwardScreen> {
  final _formKey = GlobalKey<FormState>();

  bool loading = false;

  int? partyId;

  List parties = [];
  List yarns = [];
  List colors = [];

  DateTime challanDate = DateTime.now();

  final TextEditingController challanNoController =
      TextEditingController();

  final TextEditingController vehicleNoController =
      TextEditingController();

  final TextEditingController remarksController =
      TextEditingController();

  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();

    partyId = widget.partyId;

    loadData();

    addEmptyRow();
  }

  Future<void> loadData() async {
    try {
      parties = await ApiService.getParties();

      yarns = await ApiService.getYarnMaster();

      colors = await ApiService.getColors();

      setState(() {});
    } catch (e) {
      showError(e.toString());
    }
  }
void addEmptyRow() {
  items.add({
    "yarn_id": null,
    "color_id": null,
    "lot_no": "",
    "bags": "",
    "cones": "",
    "net_weight": "",
  });

  setState(() {});
}
  void removeRow(int index) {
    items.removeAt(index);

    setState(() {});
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: challanDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        challanDate = picked;
      });
    }
  }

  double parseNum(dynamic value) {
    return double.tryParse(value.toString()) ?? 0;
  }

  int parseInt(dynamic value) {
    return int.tryParse(value.toString()) ?? 0;
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (partyId == null) {
      showError("Please select party");
      return;
    }

    if (items.isEmpty) {
      showError("Add at least one yarn item");
      return;
    }

    final List<Map<String, dynamic>> preparedItems = [];

    for (final item in items) {
      if (item['yarn_id'] == null) {
        showError("Please select yarn in all rows");
        return;
      }

      preparedItems.add({
  "yarn_id": item['yarn_id'],
  "color_id": item['color_id'],
  "lot_no": item['lot_no'],
  "bags": parseInt(item['bags']),
  "cones": parseInt(item['cones']),
  "net_weight": parseNum(item['net_weight']),
});
    }

    setState(() {
      loading = true;
    });

    try {
      await ApiService.createYarnChallan(
        challanNo: challanNoController.text.trim(),
        partyId: partyId!,
        challanDate:
            DateFormat('yyyy-MM-dd').format(challanDate),
        vehicleNo: vehicleNoController.text.trim(),
        remarks: remarksController.text.trim(),
        items: preparedItems,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Yarn challan created successfully",
            ),
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      showError(e.toString());
    }

    setState(() {
      loading = false;
    });
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
 
Widget buildRow(int index) {
  final item = items[index];

  return Card(
    margin: const EdgeInsets.only(bottom: 18),
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [

          // ================= TOP ROW =================

          Row(
            children: [

              // YARN
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: item['yarn_id'],
                  decoration: const InputDecoration(
                    labelText: "Yarn",
                    border: OutlineInputBorder(),
                  ),
                  items: yarns
                      .map<DropdownMenuItem<int>>(
                        (y) => DropdownMenuItem(
                          value: y['id'],
                          child: Text(
                            y['yarn_name']
                                    ?.toString() ??
                                '',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    item['yarn_id'] = v;
                    setState(() {});
                  },
                ),
              ),

              const SizedBox(width: 12),

              // COLOR
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: item['color_id'],
                  decoration: const InputDecoration(
                    labelText: "Color",
                    border: OutlineInputBorder(),
                  ),
                  items: colors
                      .map<DropdownMenuItem<int>>(
                        (c) => DropdownMenuItem(
                          value: c['id'],
                          child: Text(
                            c['name']
                                    ?.toString() ??
                                '',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    item['color_id'] = v;
                    setState(() {});
                  },
                ),
              ),

              const SizedBox(width: 12),

              // LOT NO
              Expanded(
                child: TextFormField(
                  initialValue:
                      item['lot_no'].toString(),
                  decoration: const InputDecoration(
                    labelText: "Lot No",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) {
                    item['lot_no'] = v;
                  },
                ),
              ),

              const SizedBox(width: 10),

              // DELETE
              IconButton(
                onPressed: items.length == 1
                    ? null
                    : () => removeRow(index),
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ================= BOTTOM ROW =================

          Row(
            children: [

              // BAGS
              Expanded(
                child: TextFormField(
                  initialValue:
                      item['bags'].toString(),
                  keyboardType:
                      TextInputType.number,
                  decoration:
                      const InputDecoration(
                    labelText: "Bags",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) {
                    item['bags'] = v;
                  },
                ),
              ),

              const SizedBox(width: 12),

              // CONES
              Expanded(
                child: TextFormField(
                  initialValue:
                      item['cones'].toString(),
                  keyboardType:
                      TextInputType.number,
                  decoration:
                      const InputDecoration(
                    labelText: "Cones",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) {
                    item['cones'] = v;
                  },
                ),
              ),

              const SizedBox(width: 12),

              // NET WEIGHT
              Expanded(
                child: TextFormField(
                  initialValue:
                      item['net_weight']
                          .toString(),
                  keyboardType:
                      TextInputType.number,
                  decoration:
                      const InputDecoration(
                    labelText: "Net Weight (kg)",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) {
                    item['net_weight'] = v;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Add Yarn Challan"),
      ),

      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              DropdownButtonFormField<int>(
                value: partyId,
                decoration: const InputDecoration(
                  labelText: "Party",
                  border: OutlineInputBorder(),
                ),
                items: parties
                    .map<DropdownMenuItem<int>>(
                      (p) => DropdownMenuItem(
                        value: p['id'],
                        child: Text(
                          p['name']
                              ?.toString() ??
                              '',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: widget.partyId != null
                    ? null
                    : (v) {
                        setState(() {
                          partyId = v;
                        });
                      },
                validator: (v) =>
                    v == null
                        ? "Select Party"
                        : null,
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller:
                          challanNoController,
                      decoration:
                          const InputDecoration(
                        labelText:
                            "Challan No",
                        border:
                            OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null ||
                                  v.isEmpty
                              ? "Required"
                              : null,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: TextFormField(
                      controller:
                          vehicleNoController,
                      decoration:
                          const InputDecoration(
                        labelText:
                            "Vehicle No",
                        border:
                            OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: remarksController,
                decoration: const InputDecoration(
                  labelText: "Remarks",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8),
                  side: const BorderSide(
                    color: Colors.grey,
                  ),
                ),
                title: Text(
                  "Challan Date: ${DateFormat('dd-MM-yyyy').format(challanDate)}",
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.calendar_today,
                  ),
                  onPressed: pickDate,
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Yarn Items",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  ElevatedButton.icon(
                    onPressed: addEmptyRow,
                    icon: const Icon(Icons.add),
                    label:
                        const Text("Add Yarn"),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              ...List.generate(
                items.length,
                (index) => buildRow(index),
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed:
                      loading ? null : submit,
                  child: loading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          "Save Challan",
                        ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}