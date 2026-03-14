import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EditJobScreen extends StatefulWidget {
  final Map<String, dynamic> job;

  const EditJobScreen({
    super.key,
    required this.job,
  });

  @override
  State<EditJobScreen> createState() => _EditJobScreenState();
}

class _EditJobScreenState extends State<EditJobScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _gsm = TextEditingController();
  final TextEditingController _quantity = TextEditingController();

  List parties = [];
  List machines = [];
  List fabrics = [];
  List yarns = [];

  int? partyId;
  int? fabricId;

  bool isMultiMachine = false;
  int? singleMachineId;
  List<int> selectedMachineIds = [];

  List<Map<String, dynamic>> selectedYarns = [];

  bool loading = false;
  bool machineLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final p = await ApiService.getParties();
      final m = await ApiService.getMachines();
      final f = await ApiService.getFabrics();
      final y = await ApiService.getYarnMaster();

      final jobDetails = await ApiService.getJobDetails(widget.job['id']);

      setState(() {
        parties = p;
        machines = m;
        fabrics = f;
        yarns = y;

        partyId = jobDetails['party_id'];
        fabricId = jobDetails['fabric_id'];

        _gsm.text = jobDetails['gsm'].toString();
        _quantity.text = jobDetails['order_quantity'].toString();

        /// MACHINE SETUP
        selectedMachineIds = List<int>.from(jobDetails['machines'] ?? []);

        if (selectedMachineIds.length <= 1) {
          isMultiMachine = false;
          singleMachineId =
              selectedMachineIds.isNotEmpty ? selectedMachineIds.first : null;
        } else {
          isMultiMachine = true;
        }

        /// YARN SETUP
        selectedYarns =
            List<Map<String, dynamic>>.from(jobDetails['yarns'] ?? []);

        machineLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (partyId == null || fabricId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Party and Fabric required")),
      );
      return;
    }

    /// MACHINE VALIDATION
    if (!isMultiMachine) {
      if (singleMachineId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Select a machine")),
        );
        return;
      }
      selectedMachineIds = [singleMachineId!];
    } else {
      if (selectedMachineIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Select at least one machine")),
        );
        return;
      }
    }

    /// YARN VALIDATION
    for (var y in selectedYarns) {
      if (y['yarn_id'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Select yarn")),
        );
        return;
      }
    }

    setState(() => loading = true);

    try {
      await ApiService.updateJob(
        jobId: widget.job['id'],
        partyId: partyId!,
        machineIds: selectedMachineIds,
        fabricId: fabricId!,
        gsm: int.parse(_gsm.text),
        orderQuantity: double.parse(_quantity.text),
        yarns: selectedYarns,
      );

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }

    if (mounted) setState(() => loading = false);
  }

  @override
  void dispose() {
    _gsm.dispose();
    _quantity.dispose();
    super.dispose();
  }

  Widget _machineSelector() {
    if (machineLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!isMultiMachine) {
      return DropdownButtonFormField<int>(
        value: singleMachineId,
        decoration: const InputDecoration(
          labelText: "Machine",
          border: OutlineInputBorder(),
        ),
        items: machines.map<DropdownMenuItem<int>>((m) {
          return DropdownMenuItem(
            value: m['id'],
            child: Text("Machine ${m['machine_no']}"),
          );
        }).toList(),
        onChanged: (v) => setState(() => singleMachineId = v),
      );
    }

    return Column(
      children: machines.map<Widget>((m) {
        final id = m['id'];
        final selected = selectedMachineIds.contains(id);

        return CheckboxListTile(
          value: selected,
          title: Text("Machine ${m['machine_no']}"),
          onChanged: (checked) {
            setState(() {
              if (checked == true) {
                selectedMachineIds.add(id);
              } else {
                selectedMachineIds.remove(id);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _yarnSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Yarns Required",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        ...selectedYarns.asMap().entries.map((entry) {
          int index = entry.key;
          var yarnItem = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: yarnItem['yarn_id'],
                    decoration: const InputDecoration(
                      labelText: "Yarn",
                      border: OutlineInputBorder(),
                    ),
                    items: yarns.map<DropdownMenuItem<int>>((y) {
                      return DropdownMenuItem(
                        value: y['id'],
                        child: Text(y['yarn_name']),
                      );
                    }).toList(),
                    onChanged: (v) {
                      setState(() {
                        selectedYarns[index]['yarn_id'] = v;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      selectedYarns.removeAt(index);
                    });
                  },
                )
              ],
            ),
          );
        }),

        TextButton.icon(
          onPressed: () {
            setState(() {
              selectedYarns.add({'yarn_id': null});
            });
          },
          icon: const Icon(Icons.add),
          label: const Text("Add Yarn"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Job ${widget.job['job_no']}"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// PARTY
              DropdownButtonFormField<int>(
                value: partyId,
                decoration: const InputDecoration(
                  labelText: "Party",
                  border: OutlineInputBorder(),
                ),
                items: parties.map<DropdownMenuItem<int>>((p) {
                  return DropdownMenuItem(
                    value: p['id'],
                    child: Text(p['name']),
                  );
                }).toList(),
                onChanged: (v) => setState(() => partyId = v),
              ),

              const SizedBox(height: 16),

              /// MACHINE MODE
              SwitchListTile(
                title: const Text("Enable Multiple Machines"),
                value: isMultiMachine,
                onChanged: (val) {
                  setState(() {
                    isMultiMachine = val;
                    selectedMachineIds.clear();
                    singleMachineId = null;
                  });
                },
              ),

              const SizedBox(height: 8),

              _machineSelector(),

              const SizedBox(height: 16),

              /// FABRIC
              DropdownButtonFormField<int>(
                value: fabricId,
                decoration: const InputDecoration(
                  labelText: "Fabric",
                  border: OutlineInputBorder(),
                ),
                items: fabrics.map<DropdownMenuItem<int>>((f) {
                  return DropdownMenuItem(
                    value: f['id'],
                    child: Text(f['name']),
                  );
                }).toList(),
                onChanged: (v) => setState(() => fabricId = v),
              ),

              const SizedBox(height: 16),

              /// GSM
              TextFormField(
                controller: _gsm,
                decoration: const InputDecoration(
                  labelText: "GSM",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 16),

              /// QUANTITY
              TextFormField(
                controller: _quantity,
                decoration: const InputDecoration(
                  labelText: "Order Quantity (kg)",
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),

              const SizedBox(height: 24),

              _yarnSection(),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: loading ? null : _submit,
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Update Job"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}