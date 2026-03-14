import 'package:flutter/material.dart';
import '../config/app_config.dart';
import 'user_management_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  bool requireLogin = AppConfig.requireLogin;

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

        ],
      ),
    );
  }
}