import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/user_session.dart';
import 'package:http/http.dart' as http;
import '../dashboard/dashboard_screen.dart';
import 'package:knit_jobwork_app/services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

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
          "password": passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        await ApiService.setToken(data['token']); // ✅ FIXED (was response['token'])

      final savedToken = await ApiService.getToken();
      print("TOKEN AFTER LOGIN: $savedToken");
        final role = data["user"]["role"]; // ✅ now actually used

        UserSession.current = UserSession(
          role: role,                                          // ✅ FIXED
          permissions: data["user"]["permissions"] ?? ["ALL"], // ✅ FIXED
        );

        if (!mounted) return; // ✅ safety check
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Dashboard()),
        );
      } else {
        if (!mounted) return;
        setState(() {
          error = data["message"] ?? "Login failed";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
      });
    }

    if (!mounted) return;
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