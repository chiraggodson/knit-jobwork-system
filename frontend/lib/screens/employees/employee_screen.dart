import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Employee {
  final int? id;
  final String empId;
  final String firstName;
  final String lastName;
  final String fatherName;
  final String dob;
  final String address;
  final String aadhar;
  final String phone;
  final String emergencyContact;
  final String esiNumber;
  final String group;
  final String department;
  final String role;

  final String payRate;
  final String payMethod;
  final String paySchedule;
  final String status;

  Employee({
    this.id,
    required this.empId,
    required this.firstName,
    required this.lastName,
    required this.fatherName,
    required this.dob,
    required this.address,
    required this.aadhar,
    required this.phone,
    required this.emergencyContact,
    required this.esiNumber,
    required this.group,
    required this.department,
    required this.role,
    required this.payRate,
    required this.payMethod,
    required this.paySchedule,
    required this.status,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      empId: json['emp_id'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      fatherName: json['father_name'] ?? '',
      dob: json['dob'] ?? '',
      address: json['address'] ?? '',
      aadhar: json['aadhar'] ?? '',
      phone: json['phone'] ?? '',
      emergencyContact: json['emergency_contact'] ?? '',
      esiNumber: json['esi_number'] ?? '',
      group: json['group'] ?? '',
      department: json['department'] ?? '',
      role: json['role'] ?? '',
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

  final String baseUrl = "http://192.168.29.6:4000";
  String token = "";

  String generateEmpId() {
    int next = employees.length + 1;
    return next.toString().padLeft(2, '0');
  }

  @override
  void initState() {
    super.initState();
    init();
    searchController.addListener(applyFilters);
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
      Uri.parse("$baseUrl/api/employees"),
      headers: {"Authorization": "Bearer $token"},
    );
final decoded = jsonDecode(response.body);

final List data = decoded is List
    ? decoded
    : decoded["employees"] ?? [];
    employees = data.map((e) => Employee.fromJson(e)).toList();

    applyFilters();
  } catch (e) {
    debugPrint("ERROR: $e");
  }

  setState(() => isLoading = false);
}
  void applyFilters() {
    String query = searchController.text.toLowerCase();

    filteredEmployees = employees.where((emp) {
      return "${emp.firstName} ${emp.lastName}"
          .toLowerCase()
          .contains(query);
    }).toList();

    setState(() {});
  }

  Future<void> addEmployee(Employee emp) async {
    await http.post(
      Uri.parse("$baseUrl/api/employees"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
  "emp_id": emp.empId,
  "first_name": emp.firstName,
  "last_name": emp.lastName,
  "father_name": emp.fatherName,
  "dob": emp.dob,
  "address": emp.address,
  "aadhar": emp.aadhar,
  "phone": emp.phone,
  "emergency_contact": emp.emergencyContact,
  "esi_number": emp.esiNumber,
  "group": emp.group,
  "department": emp.department,
  "role": emp.role,
  "pay_rate": emp.payRate,
  "pay_method": emp.payMethod,
  "pay_schedule": emp.paySchedule,
  "status": emp.status,
}),
    );

    fetchEmployees();
  }

  void openAddDialog() {
    final firstName = TextEditingController();
    final lastName = TextEditingController();
    final phone = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("New Employee"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: firstName, decoration: const InputDecoration(labelText: "First Name")),
            TextField(controller: lastName, decoration: const InputDecoration(labelText: "Last Name")),
            TextField(controller: phone, decoration: const InputDecoration(labelText: "Phone")),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              addEmployee(Employee(
                empId: generateEmpId(),
                firstName: firstName.text,
                lastName: lastName.text,
                fatherName: "",
                dob: "",
                address: "",
                aadhar: "",
                phone: phone.text,
                emergencyContact: "",
                esiNumber: "",
                group: "A",
                department: "Knitting",
                role: "Operator",
                payRate: "",
                payMethod: "",
                paySchedule: "",
                status: "Active",
              ));
              Navigator.pop(context);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF121212),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [

          /// TOP BAR
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Employees",
                  style: TextStyle(fontSize: 26, color: Colors.white)),
              ElevatedButton.icon(
                onPressed: openAddDialog,
                icon: const Icon(Icons.add),
                label: const Text("New Employee"),
              )
            ],
          ),

          const SizedBox(height: 20),

          /// SEARCH
          TextField(
            controller: searchController,
            decoration: const InputDecoration(hintText: "Search employees"),
          ),

          const SizedBox(height: 20),

          /// TABLE
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [

                      /// HEADER
                      const Row(
                        children: [
                          Expanded(child: Text("ID", style: TextStyle(color: Colors.grey))),
                          Expanded(child: Text("Name", style: TextStyle(color: Colors.grey))),
                          Expanded(child: Text("Role", style: TextStyle(color: Colors.grey))),
                          Expanded(child: Text("Dept", style: TextStyle(color: Colors.grey))),
                          Expanded(child: Text("Phone", style: TextStyle(color: Colors.grey))),
                          Expanded(child: Text("Status", style: TextStyle(color: Colors.grey))),
                        ],
                      ),

                      const Divider(),

                      /// DATA
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredEmployees.length,
                          itemBuilder: (_, i) {
                            final e = filteredEmployees[i];

                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  Expanded(child: Text(e.empId)),
                                  Expanded(child: Text("${e.firstName} ${e.lastName}")),
                                  Expanded(child: Text(e.role)),
                                  Expanded(child: Text("${e.department} (${e.group})")),
                                  Expanded(child: Text(e.phone)),
                                  _StatusBadge(e.status),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
          )
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    Color color = status == "Active"
        ? Colors.greenAccent
        : Colors.redAccent;

    return Expanded(
      child: Text(
        status,
        style: TextStyle(color: color),
      ),
    );
  }
}