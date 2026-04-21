import 'dart:io';
import 'user_management_screen.dart';
import '../../config/app_config.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:file_picker/file_picker.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool requireLogin = AppConfig.requireLogin;

  Future<void> _uploadParties() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null) return;

    File file = File(result.files.single.path!);

    try {
      await ApiService.uploadParties(file);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Parties uploaded successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload failed: $e")),
        );
      }
    }
  }

  void _openUploadMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text("Upload Parties"),
                onTap: () {
                  Navigator.pop(context);
                  _uploadParties();
                },
              ),
              ListTile(
                leading: const Icon(Icons.inventory),
                title: const Text("Upload Yarn Inward"),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Upload Yarn Inward not connected yet")),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.work),
                title: const Text("Upload Job Orders"),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Upload Job Orders not connected yet")),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openDownloadMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text("Download Parties Template"),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Parties template route not connected yet")),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.inventory),
                title: const Text("Download Yarn Inward Template"),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Template not connected yet")),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.work),
                title: const Text("Download Job Orders Template"),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Template not connected yet")),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Require Login"),
            subtitle: const Text("Disable during development"),
            value: requireLogin,
            onChanged: (value) async {
              await AppConfig.setRequireLogin(value);

              setState(() {
                requireLogin = value;
              });
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.people),
            title: const Text("User Management"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const UserManagementScreen(),
                ),
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text("Upload Data"),
            subtitle: const Text("Upload Parties, Yarn Inward, Job Orders"),
            onTap: _openUploadMenu,
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.download),
            title: const Text("Download Templates"),
            subtitle: const Text("Parties, Yarn Inward, Job Orders"),
            onTap: _openDownloadMenu,
          ),

          const Divider(),
        ],
      ),
    );
  }
}
