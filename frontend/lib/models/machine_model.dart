class MachineModel {
  final int id;

  final String machineNo;
  final String status;

  final int rpm;
  final int counter;

  final double rollSize;

  final double kgPerHour;
  final double kg24h;

  final int estimatedRolls24h;

  final dynamic jobNo;

  final String type;

  MachineModel({
    required this.id,
    required this.machineNo,
    required this.status,
    required this.rpm,
    required this.counter,
    required this.rollSize,
    required this.kgPerHour,
    required this.kg24h,
    required this.estimatedRolls24h,
    required this.jobNo,
    required this.type,
  });

  /*
  =================================
  FROM JSON
  =================================
  */

  factory MachineModel.fromJson(
  Map<String, dynamic> json,
) {
  return MachineModel(
    id: int.tryParse(
          json['id'].toString(),
        ) ??
        0,

    machineNo:
        json['machine_no']?.toString() ?? '',

    status:
        json['status']?.toString() ??
        'STOPPED',

    rpm: int.tryParse(
          json['rpm'].toString(),
        ) ??
        0,

    counter: int.tryParse(
          json['counter'].toString(),
        ) ??
        0,

    rollSize: double.tryParse(
          json['roll_size'].toString(),
        ) ??
        0,

    kgPerHour: double.tryParse(
          json['kg_per_hour'].toString(),
        ) ??
        0,

    kg24h: double.tryParse(
          json['kg_24h'].toString(),
        ) ??
        0,

    estimatedRolls24h:
        int.tryParse(
              json['estimated_rolls_24h']
                  .toString(),
            ) ??
            0,

    jobNo: json['job_no'],

    type:
        json['machine_type']
            ?.toString() ??
        '',
  );
}

  /*
  =================================
  TO JSON
  =================================
  */

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'machine_no': machineNo,
      'status': status,
      'rpm': rpm,
      'counter': counter,
      'roll_size': rollSize,
      'kg_per_hour': kgPerHour,
      'kg_24h': kg24h,
      'estimated_rolls_24h':
          estimatedRolls24h,
      'job_no': jobNo,
      'machine_type': type,
    };
  }
}