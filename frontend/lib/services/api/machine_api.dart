import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../api_service.dart';
import '../../models/machine_model.dart';

class MachineApi {
  /*
  =================================
  GET MACHINES
  =================================
  */

  static Future<List<MachineModel>> getMachines() async {
    final headers = await ApiService.getHeaders();

    final res = await http.get(
      Uri.parse("${ApiService.baseUrl}/api/machines"),
      headers: headers,
    );

    debugPrint("GET MACHINES STATUS: ${res.statusCode}");

    final decoded = jsonDecode(res.body);

    if (res.statusCode != 200) {
      throw Exception(
        decoded['message'] ?? 'Failed to load machines',
      );
    }

    return (decoded['data'] as List)
    .map((e) => MachineModel.fromJson(e))
    .toList();
  }

  /*
  =================================
  UPDATE MACHINE STATUS
  =================================
  */

  static Future<void> updateMachineStatus(
    int machineId,
    String status,
  ) async {
    final res = await http.put(
      Uri.parse(
        "${ApiService.baseUrl}/api/machines/$machineId/status",
      ),
      headers: await ApiService.getHeaders(),
      body: jsonEncode({
        "status": status,
      }),
    );

    final decoded = jsonDecode(res.body);

    if (res.statusCode != 200) {
      throw Exception(
        decoded['message'] ?? 'Failed to update machine',
      );
    }
  }

  /*
  =================================
  UPDATE PERFORMANCE
  =================================
  */

  static Future<void> updateMachinePerformance({
    required int machineId,
    required int rpm,
    required int counter,
    required double rollSize,
  }) async {

    final res = await http.put(
      Uri.parse(
        "${ApiService.baseUrl}/api/machines/$machineId/performance",
      ),
      headers: await ApiService.getHeaders(),
      body: jsonEncode({
        "rpm": rpm,
        "counter": counter,
        "roll_size": rollSize,
      }),
    );

    final decoded = jsonDecode(res.body);

    if (res.statusCode != 200) {
      throw Exception(
        decoded['message'] ?? 'Failed to update performance',
      );
    }
  }

  /*
  =================================
  CREATE MACHINE
  =================================
  */

  static Future<void> createMachine(
    String machineNo,
  ) async {

    final res = await http.post(
      Uri.parse("${ApiService.baseUrl}/api/machines"),
      headers: await ApiService.getHeaders(),
      body: jsonEncode({
        "machine_no": machineNo,
      }),
    );

    final decoded = jsonDecode(res.body);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(
        decoded['message'] ?? 'Failed to create machine',
      );
    }
  }
}