import 'dart:convert';
import 'dashboard_screen.dart';
import '../models/user_session.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:knit_jobwork_app/services/api_service.dart';




class LoginScreen extends StatefulWidget {
   LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  String error = "";

  Future<void> login() async {
    setState(() {
      loading = true;
      error = "";
    });

    try {
      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}/api/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": usernameController.text,
          "password": passwordController.text
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {

        final role = data["user"]["role"];

UserSession.current = UserSession(
  role: "admin",
  permissions: ["ALL"],
);

Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (_) => const Dashboard(),
  ),
);


      } else {
        setState(() {
          error = data["message"] ?? "Login failed";
        });
      }

    } catch (e) {
      setState(() {
        error = "Cannot connect to server";
      });
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: SizedBox(
          width: 350,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Image.asset("assets/logo.png", height: 120),

              const SizedBox(height: 30),

              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: "Username"),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
              ),

              const SizedBox(height: 10),

              if (error.isNotEmpty)
                Text(
                  error,
                  style: const TextStyle(color: Colors.red),
                ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : login,
                  child: loading
                      ? const CircularProgressIndicator()
                      : const Text("LOGIN"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}