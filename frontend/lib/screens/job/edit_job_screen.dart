import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:image_picker/image_picker.dart';

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
  bool pageLoading = true;

  File? fabricImage;
  String? existingImageUrl;

  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadData();
    setState(() {});
    
  }
  
  Future<void> pickImage(ImageSource source) async {
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (picked != null) {
      setState(() {
        fabricImage = File(picked.path);
      });
    }
  }

  void showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _loadData() async {
    try {
      final p = await ApiService.getParties();
      final m = await ApiService.getMachines();
      final f = await ApiService.getFabrics();
      final y = await ApiService.getYarnMaster();
      print("MACHINES MASTER ====> $machines");
      final jobDetails =
          await ApiService.getJobDetail(widget.job['job_no']);

print("JOB MACHINES ====> ${jobDetails['machines']}");
      setState(() {
        parties = p;
        machines = m;
        fabrics = f;
        yarns = y;

        partyId = jobDetails['party_id'];
        fabricId = jobDetails['fabric_id'];

        _gsm.text = jobDetails['gsm'].toString();
        _quantity.text = jobDetails['order_quantity'].toString();

        // ✅ FIX IMAGE URL
        existingImageUrl = jobDetails['image_url'] != null
            ? "${ApiService.baseUrl}/${jobDetails['image_url']}"
            : null;

        // ✅ FIX MACHINE MAPPING
        selectedMachineIds = (jobDetails['machines'] as List? ?? [])
        .map<int>((m) {
          if (m is Map<String, dynamic>) {
            return m['id'] ?? m['machine_id'];
          }
          return m; // fallback if it's already int
        })
        .whereType<int>()
        .toList();

        if (selectedMachineIds.length <= 1) {
          isMultiMachine = false;
          singleMachineId =
              selectedMachineIds.isNotEmpty ? selectedMachineIds.first : null;
        } else {
          isMultiMachine = true;
        }

        selectedYarns = (jobDetails['yarns'] as List? ?? [])
    .map<Map<String, dynamic>>((y) {
      int? matchedId;

      // 🔥 match yarn_name with master list
      final match = yarns.firstWhere(
        (ym) => ym['yarn_name'] == y['yarn_name'],
        orElse: () => null,
      );

      if (match != null) {
        matchedId = match['id'];
      }

      return {
        'yarn_id': matchedId,
        'percentage': y['mix_percent'] ?? 0,
      };
    })
    .toList();

        pageLoading = false;
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
        image: fabricImage,
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

  Widget _imageUploader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Fabric Image",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: showImageOptions,
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: fabricImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(fabricImage!, fit: BoxFit.cover),
                  )
                : existingImageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(existingImageUrl!,
                            fit: BoxFit.cover),
                      )
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 40),
                            SizedBox(height: 8),
                            Text("Tap to upload image"),
                          ],
                        ),
                      ),
          ),
        ),
      ],
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
              // 🔹 Yarn Dropdown
              Expanded(
                flex: 3,
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

              // 🔹 Percentage Field
              Expanded(
                flex: 2,
                child: TextFormField(
                  initialValue:
                      (yarnItem['percentage'] ?? 0).toString(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "%",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) {
                    setState(() {
                      selectedYarns[index]['percentage'] =
                          double.tryParse(val) ?? 0;
                    });
                  },
                ),
              ),

              const SizedBox(width: 8),

              // 🔹 Delete Button
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
            selectedYarns.add({'yarn_id': null, 'percentage': 0});
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
    if (pageLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
              SwitchListTile(
                title: const Text("Enable Multiple Machines"),
                value: isMultiMachine,
                onChanged: (val) {
                  setState(() {
                    isMultiMachine = val;

                    if (val) {
                      selectedMachineIds = singleMachineId != null
                          ? [singleMachineId!]
                          : [];
                    } else {
                      singleMachineId = selectedMachineIds.isNotEmpty
                          ? selectedMachineIds.first
                          : null;
                    }
                  });
                },
              ),
              _machineSelector(),
              const SizedBox(height: 16),
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
              TextFormField(
                controller: _gsm,
                decoration: const InputDecoration(
                  labelText: "GSM",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantity,
                decoration: const InputDecoration(
                  labelText: "Order Quantity (kg)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              _imageUploader(),
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