class Job {
  final int id;
  final String jobNo;
  final String partyName;
  final String fabricName;
  final double orderQty;
  final double production;
  final String status;

  Job({
    required this.id,
    required this.jobNo,
    required this.partyName,
    required this.fabricName,
    required this.orderQty,
    required this.production,
    required this.status,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      jobNo: json['job_no'] ?? '',
      partyName: json['party_name'] ?? '',
      fabricName: json['fabric_name'] ?? '',
      orderQty: (json['order_quantity'] ?? 0).toDouble(),
      production: (json['actual_production'] ?? 0).toDouble(),
      status: json['status'] ?? 'OPEN',
    );
  }
}