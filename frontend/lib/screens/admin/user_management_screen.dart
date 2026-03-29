import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../services/api_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {

  List users = [];

  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  String role = "supervisor";

  Future fetchUsers() async {

    final response = await http.get(Uri.parse("${ApiService.baseUrl}/api/users"));

    setState(() {
      users = jsonDecode(response.body);
    });
  }

  Future addUser() async {

    await http.post(
      Uri.parse("${ApiService.baseUrl}/api/users"),
      headers: {"Content-Type":"application/json"},
      body: jsonEncode({
        "name": nameController.text,
        "username": usernameController.text,
        "password": passwordController.text,
        "role": role
      }),
    );

    nameController.clear();
    usernameController.clear();
    passwordController.clear();

    fetchUsers();
  }

  Future deleteUser(int id) async {

    await http.delete(
      Uri.parse("${ApiService.baseUrl}/api/users/$id"),
    );

    fetchUsers();
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: const Text("User Management")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            Row(
              children: [

                Expanded(
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Name",
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: "Username",
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: "Password",
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                DropdownButton<String>(
                  value: role,
                  items: const [
                    DropdownMenuItem(
                      value: "admin",
                      child: Text("Admin"),
                    ),
                    DropdownMenuItem(
                      value: "supervisor",
                      child: Text("Supervisor"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      role = value!;
                    });
                  },
                ),

                const SizedBox(width: 10),

                ElevatedButton(
                  onPressed: addUser,
                  child: const Text("Add User"),
                ),

              ],
            ),

            const SizedBox(height: 30),

            Expanded(
              child: ListView.builder(

                itemCount: users.length,

                itemBuilder: (context, index) {

                  final user = users[index];

                  return Card(
                    child: ListTile(

                      title: Text(user["name"]),

                      subtitle: Text(
                        "${user["username"]} • ${user["role"]}",
                      ),

                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {

                          deleteUser(user["id"]);

                        },
                      ),
                    ),
                  );
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}