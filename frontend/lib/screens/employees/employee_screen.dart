import 'package:flutter/material.dart';

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
}

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  List<Employee> employees = [];
  bool isLoading = false;

  final TextEditingController searchController = TextEditingController();
  String selectedFilter = "Active Employees";

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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                    ),
                    child: const Text("Run payroll"),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: const Text(
                      "Invite to Workforce",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: const Text(
                      "Add employee",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              )
            ],
          ),

          const SizedBox(height: 20),

          /// FILTER BAR
          Row(
            children: [
              SizedBox(
                width: 300,
                child: TextField(
                  controller: searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Find an employee",
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF1A1A1A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: selectedFilter,
                  dropdownColor: const Color(0xFF1A1A1A),
                  style: const TextStyle(color: Colors.white),
                  underline: const SizedBox(),
                  items: ["Active Employees", "All Employees"]
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedFilter = val!;
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// TABLE HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: const [
                Expanded(flex: 2, child: _HeaderText("NAME")),
                Expanded(flex: 2, child: _HeaderText("PAY RATE")),
                Expanded(flex: 2, child: _HeaderText("PAY METHOD")),
                Expanded(flex: 2, child: _HeaderText("PAY SCHEDULE")),
                Expanded(flex: 1, child: _HeaderText("STATUS")),
              ],
            ),
          ),

          const SizedBox(height: 10),

          /// TABLE
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: employees.length,
                    itemBuilder: (context, index) {
                      return employeeRow(employees[index]);
                    },
                  ),
          )
        ],
      ),
    );
  }

  Widget employeeRow(Employee emp) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: _cell(emp.name)),
          Expanded(flex: 2, child: _cell(emp.payRate)),
          Expanded(flex: 2, child: _cell(emp.payMethod)),
          Expanded(flex: 2, child: _cell(emp.paySchedule)),
          Expanded(
            flex: 1,
            child: Text(
              emp.status,
              style: const TextStyle(
                color: Color(0xFF00BFA6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cell(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white),
    );
  }
}

class _HeaderText extends StatelessWidget {
  final String text;

  const _HeaderText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.grey,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}