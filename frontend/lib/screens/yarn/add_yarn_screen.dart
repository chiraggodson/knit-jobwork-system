import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AddYarnScreen extends StatefulWidget {
  const AddYarnScreen({super.key});

  @override
  State<AddYarnScreen> createState() => _AddYarnScreenState();
}

class _AddYarnScreenState extends State<AddYarnScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController =
      TextEditingController(text: "40's Cotton");
  final TextEditingController _countController =
      TextEditingController(text: "40'S");
  final TextEditingController _typeController =
      TextEditingController(text: "Cotton");
  final TextEditingController _colorController = TextEditingController();
  bool _isLoading = false;

  Future<void> _saveYarn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ApiService.addYarn(
        yarnName: _nameController.text.trim(),
        yarnCount: _countController.text.trim(),
        yarnType: _typeController.text.trim(),
        
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Yarn Added Successfully")),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to Add Yarn")),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Yarn"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              // Yarn Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Yarn Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter Yarn Name" : null,
              ),

              const SizedBox(height: 16),

              // Yarn Count
              TextFormField(
                controller: _countController,
                decoration: const InputDecoration(
                  labelText: "Yarn Count",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // Yarn Type
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(
                  labelText: "Yarn Type",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),
              TextField(
  controller: _colorController,
  decoration: const InputDecoration(
    labelText: "Color",
    border: OutlineInputBorder(),
  ),
),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveYarn,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "SAVE YARN",
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
