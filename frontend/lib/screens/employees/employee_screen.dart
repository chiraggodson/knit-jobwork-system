import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Employee {
  final int? id;
  final String name;
  final String payRate;
  final String payMethod;
  final String paySchedule;
  final String status;

  Employee({
    this.id,
    required this.name,
    required this.payRate,
    required this.payMethod,
    required this.paySchedule,
    required this.status,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      name: json['name'] ?? '',
      payRate: json['pay_rate'] ?? '',
      payMethod: json['pay_method'] ?? '',
      paySchedule: json['pay_schedule'] ?? '',
      status: json['status'] ?? 'Active',
    );
  }
}

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  List<Employee> employees = [];
  List<Employee> filteredEmployees = [];

  bool isLoading = false;

  final TextEditingController searchController = TextEditingController();
  String selectedFilter = "Active Employees";

  // 🔥 CHANGE THIS
  final String baseUrl = "http://192.168.29.6:4000";

  // 🔥 ADD YOUR TOKEN HERE (or fetch from storage)
  String token = "";
@override
void initState() {
  super.initState();
  init();
  searchController.addListener(applyFilters);
  if (token.isEmpty) {
  print("⚠️ No token found");
}
}

Future<void> init() async {
  final prefs = await SharedPreferences.getInstance();
  token = prefs.getString("token") ?? "";

  fetchEmployees();
}

  

  Future<void> fetchEmployees() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/employees"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        employees = data.map((e) => Employee.fromJson(e)).toList();
        applyFilters();
      } else {
        throw Exception("Failed to load employees");
      }
    } catch (e) {
      debugPrint("ERROR: $e");
    }

    setState(() => isLoading = false);
  }

  void applyFilters() {
    String query = searchController.text.toLowerCase();

    filteredEmployees = employees.where((emp) {
      bool matchesSearch = emp.name.toLowerCase().contains(query);

      bool matchesFilter = selectedFilter == "All Employees"
          ? true
          : emp.status.toLowerCase() == "active";

      return matchesSearch && matchesFilter;
    }).toList();

    setState(() {});
  }

  Future<void> addEmployee(Employee emp) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/employees"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "name": emp.name,
          "pay_rate": emp.payRate,
          "pay_method": emp.payMethod,
          "pay_schedule": emp.paySchedule,
          "status": emp.status,
        }),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        fetchEmployees(); // refresh
      } else {
        throw Exception("Failed to add employee");
      }
    } catch (e) {
      debugPrint("ADD ERROR: $e");
    }
  }

  void openAddDialog() {
    final nameController = TextEditingController();
    final payRateController = TextEditingController();

    String payMethod = "Cash";
    String paySchedule = "Daily";

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text("Add Employee",
              style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _input(nameController, "Name"),
              const SizedBox(height: 10),
              _input(payRateController, "Pay Rate"),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: payMethod,
                dropdownColor: const Color(0xFF1A1A1A),
                items: ["Cash", "Bank"]
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ))
                    .toList(),
                onChanged: (val) => payMethod = val!,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: paySchedule,
                dropdownColor: const Color(0xFF1A1A1A),
                items: ["Daily", "Monthly"]
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ))
                    .toList(),
                onChanged: (val) => paySchedule = val!,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                addEmployee(Employee(
                  name: nameController.text,
                  payRate: payRateController.text,
                  payMethod: payMethod,
                  paySchedule: paySchedule,
                  status: "Active",
                ));

                Navigator.pop(context);
              },
              child: const Text("Save"),
            )
          ],
        );
      },
    );
  }

  Widget _input(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF121212),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Employees",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BFA6),
                    ),
                    child: const Text("Run payroll"),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text("Invite to Workforce"),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: openAddDialog,
                    child: const Text("Add employee"),
                  ),
                ],
              )
            ],
          ),

          const SizedBox(height: 20),

          /// FILTER
          Row(
            children: [
              SizedBox(
                width: 300,
                child: TextField(
                  controller: searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Find an employee",
                  ),
                ),
              ),
              const SizedBox(width: 20),
              DropdownButton<String>(
                value: selectedFilter,
                items: ["Active Employees", "All Employees"]
                    .map((e) =>
                        DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) {
                  selectedFilter = val!;
                  applyFilters();
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// TABLE
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredEmployees.length,
                    itemBuilder: (context, index) {
                      final emp = filteredEmployees[index];

                      return ListTile(
                        title: Text(emp.name,
                            style: const TextStyle(color: Colors.white)),
                        subtitle: Text(
                          "${emp.payRate} • ${emp.payMethod} • ${emp.paySchedule}",
                          style:
                              const TextStyle(color: Colors.grey),
                        ),
                        trailing: Text(
                          emp.status,
                          style: const TextStyle(
                              color: Color(0xFF00BFA6)),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}