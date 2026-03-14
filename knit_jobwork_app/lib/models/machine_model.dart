class Machine {
  final int machineNo;
  final String type;
  final String status;
  final int rpm;
  final int counter;

  Machine({
    required this.machineNo,
    required this.type,
    required this.status,
    required this.rpm,
    required this.counter,
  });

  factory Machine.fromJson(Map<String, dynamic> json) {
    return Machine(
      machineNo: json['machine_no'],
      type: json['machine_type'] ?? '',
      status: json['status'] ?? 'STOPPED',
      rpm: json['rpm'] ?? 0,
      counter: json['counter'] ?? 0,
    );
  }
}