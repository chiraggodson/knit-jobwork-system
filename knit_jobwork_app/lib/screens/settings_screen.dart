import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../services/api_service.dart';
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

      const Divider(),

      /// ============================
      /// FACTORY RESET SECTION
      /// ============================

      ListTile(
        leading: const Icon(Icons.warning, color: Colors.red),
        title: const Text(
          "Reset Factory Transactions",
          style: TextStyle(color: Colors.red),
        ),
        subtitle: const Text(
          "Delete ALL jobs, yarn movements, production and dispatch data.\nMachines, fabrics and yarn names will remain.",
        ),
        onTap: () async {

          final confirm = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Confirm Factory Reset"),
              content: const Text(
                "This will permanently delete:\n\n"
                "• Jobs\n"
                "• Yarn transactions\n"
                "• Production records\n"
                "• Dispatch records\n\n"
                "Machines, fabrics and yarn names will NOT be deleted.\n\n"
                "Are you sure?"
              ),
              actions: [

                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text("Cancel"),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text("RESET"),
                ),

              ],
            ),
          );

          if (confirm == true) {

            try {

              await ApiService.resetTransactions();

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Factory transactions reset successfully"),
                ),
              );

            } catch (e) {

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Reset failed: $e"),
                ),
              );

            }

          }

        },
      ),

    ],
  ),
);

}
}
