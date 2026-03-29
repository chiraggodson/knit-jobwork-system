import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:image_picker/image_picker.dart';

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();

  final _gsm = TextEditingController();
  final _quantity = TextEditingController();

  List parties = [];
  int? partyId;

  List machines = [];
  bool machineLoading = true;

  bool isMultiMachine = false;
  int? singleMachineId;
  List<int> selectedMachineIds = [];

  List fabrics = [];
  int? fabricId;

  List yarns = [];
  List<Map<String, dynamic>> selectedYarns = [];

  bool loading = false;

  File? fabricImage;
  final ImagePicker picker = ImagePicker();

  /// 🔥 IMAGE PICK (Gallery + Camera)
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

  /// 🔥 IMAGE PICK DIALOG
  void showImagePickerOptions() {
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

  @override
  void initState() {
    super.initState();
    loadParties();
    loadMachines();
    loadFabrics();
    loadYarns();
  }

  Future<void> loadParties() async {
    final data = await ApiService.getParties();
    setState(() => parties = data);
  }

  Future<void> loadMachines() async {
    final data = await ApiService.getMachines();
    setState(() {
      machines = data;
      machineLoading = false;
    });
  }

  Future<void> loadFabrics() async {
    final data = await ApiService.getFabrics();
    setState(() => fabrics = data);
  }

  Future<void> loadYarns() async {
    final data = await ApiService.getYarnMaster();
    setState(() => yarns = data);
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (partyId == null || fabricId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Party & Fabric required")),
      );
      return;
    }

    if (!isMultiMachine) {
      if (singleMachineId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Select machine")),
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

    if (selectedYarns.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Add at least one yarn")),
      );
      return;
    }

    double totalPercent = 0;

    for (var y in selectedYarns) {
      if (y['yarn_id'] == null || y['percentage'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Select yarn & enter %")),
        );
        return;
      }

      totalPercent += (y['percentage'] as double);
    }

    if ((totalPercent - 100).abs() > 0.5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Total % must be 100 (Current: $totalPercent)")),
      );
      return;
    }

    final cleanedYarns = selectedYarns.map((y) {
      return {
        "yarn_id": y['yarn_id'],
        "percentage": y['percentage'],
      };
    }).toList();

    setState(() => loading = true);

    try {
      await ApiService.createJob(
        partyId: partyId!,
        machineIds: selectedMachineIds,
        fabricId: fabricId!,
        gsm: int.parse(_gsm.text),
        orderQuantity: double.parse(_quantity.text),
        yarns: cleanedYarns,
        image: fabricImage,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Jobs created successfully")),
        );
        Navigator.pop(context);
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Job")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 🔥 IMAGE UPLOADER UI
              const Text("Fabric Image",
                  style: TextStyle(fontWeight: FontWeight.bold)),

              const SizedBox(height: 10),

              GestureDetector(
                onTap: showImagePickerOptions,
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: fabricImage == null
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, size: 40),
                              SizedBox(height: 8),
                              Text("Tap to upload image"),
                            ],
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            fabricImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

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
                validator: (v) => v == null ? "Required" : null,
              ),

              const SizedBox(height: 16),

              /// MACHINE TOGGLE
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

              machineLoading
                  ? const CircularProgressIndicator()
                  : !isMultiMachine
                      ? DropdownButtonFormField<int>(
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
                          onChanged: (v) =>
                              setState(() => singleMachineId = v),
                        )
                      : Column(
                          children: machines.map<Widget>((m) {
                            final id = m['id'];
                            final isSelected =
                                selectedMachineIds.contains(id);

                            return CheckboxListTile(
                              value: isSelected,
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
                        ),

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
                validator: (v) => v == null ? "Required" : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _gsm,
                decoration: const InputDecoration(
                  labelText: "GSM",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _quantity,
                decoration: const InputDecoration(
                  labelText: "Order Quantity (kg)",
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),

              const SizedBox(height: 24),

              const Text("Yarns Required",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

              const SizedBox(height: 10),

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

                      SizedBox(
                        width: 80,
                        child: TextFormField(
                          initialValue: yarnItem['percentage']?.toString(),
                          decoration: const InputDecoration(
                            labelText: "%",
                            border: OutlineInputBorder(),
                          ),
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (val) {
                            selectedYarns[index]['percentage'] =
                                double.tryParse(val) ?? 0;
                          },
                        ),
                      ),

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
                    selectedYarns.add({
                      'yarn_id': null,
                      'percentage': 0,
                    });
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text("Add Yarn"),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: loading ? null : submit,
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Create Job"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}