import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const baseUrl = "http://192.168.29.6:4000";

static Future<void> setToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', token);
}

static Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}

static Future<void> clearToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('token');
}

 
  static Future<Map<String, String>> getHeaders() async {
  final token = await getToken();

  return {
    "Content-Type": "application/json",
    if (token != null) "Authorization": "Bearer $token",
  };
}

  /* ================= JOBS ================= */

  static Future<List<dynamic>> getJobs() async {
    final res = await http.get(
      Uri.parse("$baseUrl/api/jobs"),
      headers: await getHeaders(), // ✅ FIXED
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load jobs: ${res.body}");
    }

    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getJobDetail(String jobNo) async {
    final res = await http.get(
      Uri.parse("$baseUrl/api/jobs/$jobNo"),
      headers: await getHeaders(),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("Error ${res.statusCode}: ${res.body}");
    }

    return jsonDecode(res.body);
  }

  static Future<void> createJob({
    required int partyId,
    required List<int> machineIds,
    required int fabricId,
    required int gsm,
    required double orderQuantity,
    required List<Map<String, dynamic>> yarns,
    File? image,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$baseUrl/api/jobs"),
    );

    final token = await getToken();
if (token != null) {
  request.headers['Authorization'] = 'Bearer $token';
}

    request.fields['party_id'] = partyId.toString();
    request.fields['machine_ids'] = jsonEncode(machineIds);
    request.fields['fabric_id'] = fabricId.toString();
    request.fields['gsm'] = gsm.toString();
    request.fields['order_quantity'] = orderQuantity.toString();
    request.fields['yarns'] = jsonEncode(yarns);

    if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', image.path),
      );
    }

    final res = await request.send();

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("Job creation failed");
    }
  }

  /* ================= CLOSE JOB ================= */

  static Future<void> closeJob(String jobNo) async {
    final res = await http.put(
      Uri.parse("$baseUrl/api/jobs/close/$jobNo"),
      headers: await getHeaders(), // ✅ FIXED
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("Failed to close job: ${res.body}");
    }
  }

  /* ================= Update Machine Performance ================= */

  static Future<void> updateMachinePerformance({
    required int machineId,
    required int rpm,
    required int counter,
    required double rollSize,
  }) async {
    await http.put(
      Uri.parse("$baseUrl/api/machines/$machineId/performance"),
      headers: await getHeaders(), // ✅ FIXED
      body: jsonEncode({
        "rpm": rpm,
        "counter": counter,
        "roll_size": rollSize,
      }),
    );
    */
  }

  /* ================= UPDATE MACHINE STATUS ================= */

  static Future<void> updateMachineStatus(int machineId, String status) async {
    final res = await http.put(
      Uri.parse("$baseUrl/api/machines/$machineId/status"),
      headers: await getHeaders(), // ✅ FIXED
      body: jsonEncode({"status": status}),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("Failed to update machine status");
    }
  }

  /* ================= UPDATE JOB ================= */

  static Future updateJob({
    required int jobId,
    required int partyId,
    required List<int> machineIds,
    required int fabricId,
    required int gsm,
    required double orderQuantity,
    required List<Map<String, dynamic>> yarns,
    File? image,
  }) async {
    final res = await http.put(
      Uri.parse("$baseUrl/api/jobs/$jobId"),
      headers: await getHeaders(),
      body: jsonEncode({
        "party_id": partyId,
        "machine_ids": machineIds,
        "fabric_id": fabricId,
        "gsm": gsm,
        "order_quantity": orderQuantity,
        "yarns": yarns,
      }),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("Job update failed: ${res.body}");
    }
  }

  /* ================= PARTY ================= */

  static Future<List<dynamic>> getParties() async {
    final res = await http.get(
      Uri.parse("$baseUrl/api/parties"),
      headers: await getHeaders(), // ✅ FIXED
    );
    if (res.statusCode != 200) {
      throw Exception("Failed to load parties");
    }
    return jsonDecode(res.body);
  }

  static Future<void> createParty({
    required String name,
    required String phone,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/parties"),
      headers: await getHeaders(), // ✅ FIXED
      body: jsonEncode({"name": name, "phone": phone}),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(res.body);
    }
  }

  /* ================= YARN Party Ledger ================= */

  static Future<List<dynamic>> getPartyLedger() async {
    final res = await http.get(
      Uri.parse("$baseUrl/api/yarn/party-summary"),
      headers: await getHeaders(), // ✅ FIXED
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load party ledger");
    }

    final data = jsonDecode(res.body) as List;

    return data
        .map((p) => {
              "party_id": p["id"],
              "party_name": p["name"],
              "yarn_inward": 0,
              "yarn_issued": 0,
              "yarn_returned": 0,
              "balance": p["balance"],
            })
        .toList();
  }

  static Future<List<dynamic>> getPartyYarnSummary() async {
    final res = await http.get(
      Uri.parse("$baseUrl/api/yarn/party-summary"),
      headers: await getHeaders(), // ✅ FIXED
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load party summary");
    }

    return jsonDecode(res.body);
  }

  /* ================= YARN ================= */

  static Future<List<dynamic>> getYarnMaster() async {
    final res = await http.get(
      Uri.parse("$baseUrl/api/yarn"),
      headers: await getHeaders(), // ✅ FIXED
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load yarn master");
    }
    return jsonDecode(res.body);
  }

  static Future<void> addYarn({
    required String yarnName,
    required String yarnCount,
    required String yarnType,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/yarn"),
      headers: await getHeaders(), // ✅ FIXED
      body: jsonEncode({
        "yarn_name": yarnName,
        "yarn_count": yarnCount,
        "yarn_type": yarnType,
      }),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("Add Yarn Failed: ${res.body}");
    }
  }

  /* ================= YARN STOCK ================= */

  static Future<List<dynamic>> getYarnStock() async {
    final res = await http.get(
      Uri.parse("$baseUrl/api/yarn/stock"),
      headers: await getHeaders(), // ✅ FIXED
    );
    if (res.statusCode != 200) {
      throw Exception("Failed to load yarn stock");
    }
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getStockByParty(int partyId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/api/yarn/inward/$partyId"),
      headers: await getHeaders(), // ✅ FIXED
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load party yarn stock");
    }

    return jsonDecode(res.body);
  }

  static Future<void> addYarnInward({
    required int partyId,
    required int yarnId,
    required String lotNo,
    required double quantity,
    required String challanNo,
    required String inwardDate,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/yarn/inward"),
      headers: await getHeaders(), // ✅ FIXED
      body: jsonEncode({
        "party_id": partyId,
        "yarn_id": yarnId,
        "lot_no": lotNo,
        "quantity": quantity,
        "challan_no": challanNo,
        "inward_date": inwardDate,
      }),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(res.body);
    }
  }

  static Future<void> issueYarn({
    required int jobId,
    required int yarnLotId,
    required double quantity,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/yarn/issue"),
      headers: await getHeaders(), // ✅ FIXED
      body: jsonEncode({
        "job_id": jobId,
        "yarn_lot_id": yarnLotId,
        "quantity": quantity,
      }),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(res.body);
    }
  }

  static Future<void> returnYarn({
    required int jobId,
    required int yarnLotId,
    required double quantity,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/yarn/return"),
      headers: await getHeaders(), // ✅ FIXED
      body: jsonEncode({
        "job_id": jobId,
        "yarn_lot_id": yarnLotId,
        "quantity": quantity,
      }),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(res.body);
    }
  }

  static Future<void> addWaste({
    required int jobId,
    required int yarnLotId,
    required double quantity,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/yarn/waste"),
      headers: await getHeaders(), // ✅ FIXED
      body: jsonEncode({
        "job_id": jobId,
        "yarn_lot_id": yarnLotId,
        "quantity": quantity,
      }),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(res.body);
    }
  }

  static Future addProduction(int jobId, List<double> weights) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/production/bulk"),
      headers: await getHeaders(), // ✅ FIXED
      body: jsonEncode({"job_id": jobId, "weights": weights}),
    );

    if (res.statusCode != 200) {
      throw Exception("Production failed: ${res.statusCode} - ${res.body}");
    }
  }

  static Future<List<dynamic>> getJobsByPartyFabric(
    int partyId,
    int fabricId,
  ) async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/jobs"),
      headers: await getHeaders(), // ✅ FIXED
    );

    if (response.statusCode == 200) {
      final jobs = jsonDecode(response.body) as List;

      return jobs.where((j) {
        final jobPartyId = int.tryParse(j["party_id"]?.toString() ?? "");
        final jobFabricId = int.tryParse(j["fabric_id"]?.toString() ?? "");
        final status = j["status"]?.toString();

        return jobPartyId == partyId &&
            jobFabricId == fabricId &&
            status == "OPEN";
      }).toList();
    } else {
      throw Exception("Failed to load jobs");
    }
  }

  /* ================= PRODUCTS ================= */

  static Future<List<dynamic>> getFabrics() async {
    final res = await http.get(
      Uri.parse("$baseUrl/api/fabrics"),
      headers: await getHeaders(), // ✅ FIXED
    );
    if (res.statusCode != 200) {
      throw Exception("Failed to load fabrics");
    }
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getYarnLotsByParty(int partyId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/api/yarn/inward/$partyId"),
      headers: await getHeaders(), // ✅ FIXED
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load yarn lots");
    }

    return jsonDecode(res.body);
  }

  /* ================= MACHINES ================= */

  static Future<List<dynamic>> getMachines() async {
  final headers = await getHeaders();

  print("HEADERS SENT: $headers");

  final res = await http.get(
    Uri.parse("$baseUrl/api/machines"),
    headers: headers,
  );

  print("STATUS: ${res.statusCode}");
  print("BODY: ${res.body}");

  if (res.statusCode != 200) {
    throw Exception("Failed to load machines: ${res.body}");
  }

  return jsonDecode(res.body);
}

  static Future<void> createMachine(String machineNo) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/machines"),
      headers: await getHeaders(), // ✅ FIXED
      body: jsonEncode({"machine_no": machineNo}),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(res.body);
    }
  }

  /* ================= Yarn Stock BY PARTY ================= */

  static Future<List<dynamic>> getYarnStockByParty(int partyId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/api/yarn/inward/$partyId"),
      headers: await getHeaders(), // ✅ FIXED
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load yarn stock");
    }

    return jsonDecode(res.body);
  }

  static Future<void> addFabric({
    required String name,
    String? description,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/fabrics"),
      headers: await getHeaders(), // ✅ FIXED
      body: jsonEncode({"name": name, "description": description}),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("Failed to add fabric");
    }
  }

  /* ================= Delete Job ================= */

  static Future<void> deleteJob(int id) async {
    throw UnsupportedError("Backend route DELETE /api/jobs/:id is not available");
    /*
      headers: await getHeaders(), // ✅ FIXED
    );
  }

    */
  }

  /* ================= JOB YARN HISTORY ================= */

  static Future<List<dynamic>> getJobYarnHistory(String jobNo) async {
    final res = await http.get(
      Uri.parse("$baseUrl/api/jobs/$jobNo/yarn-history"),
      headers: await getHeaders(), // ✅ FIXED
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load yarn history");
    }

    return jsonDecode(res.body);
  }

  /* ================= JOB PRODUCTION HISTORY ================= */

  static Future<List<dynamic>> getJobProductionHistory(String jobNo) async {
    final res = await http.get(
      Uri.parse("$baseUrl/api/jobs/$jobNo/production-history"),
      headers: await getHeaders(), // ✅ FIXED
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load production history");
    }

    return jsonDecode(res.body);
  }

  /* ================= DISPATCH ================= */

  static Future<dynamic> getDispatchRolls(int jobId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/dispatch/job/$jobId"),
      headers: await getHeaders(), // ✅ FIXED
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load rolls");
    }
  }

  static Future<void> dispatchRolls({
    required int jobId,
    required List<Map<String, dynamic>> rolls,
    required String challanNo,
    String? dispatchDate,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/dispatch"),
      headers: await getHeaders(), // ✅ FIXED
      body: jsonEncode({
        "job_id": jobId,
        "rolls": rolls,
        "challan_no": challanNo,
        if (dispatchDate != null) "dispatch_date": dispatchDate,
      }),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("Dispatch failed");
    }
  }

  static Future<List<dynamic>> getJobDispatchHistory(String jobNo) async {
    final res = await http.get(
      Uri.parse("$baseUrl/api/jobs/$jobNo/dispatch-history"),
      headers: await getHeaders(), // ✅ FIXED
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load dispatch history");
    }

    return jsonDecode(res.body);
  }

  static Future<void> uploadParties(File file) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$baseUrl/api/parties/upload/upload"),
    );

    final token = await getToken();
if (token != null) {
  request.headers['Authorization'] = 'Bearer $token';
}

    request.files.add(
      await http.MultipartFile.fromPath('file', file.path),
    );

    final res = await request.send();

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("Upload failed");
    }
  }

  static Future<void> downloadPartyTemplate() async {
    throw UnsupportedError("Backend route GET /api/templates/party-template is not available");
  }

  static Future<List<dynamic>> getJobIssuedYarns(int jobId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/api/jobs/$jobId/issued-yarns"),
      headers: await getHeaders(), // ✅ FIXED
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load issued yarns");
    }
  }

  static Future<void> addSetting({
    required int jobId,
    required int yarnLotId,
    required double quantity,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/yarn/setting"),
      headers: await getHeaders(), // ✅ FIXED
      body: jsonEncode({
        "job_id": jobId,
        "yarn_lot_id": yarnLotId,
        "quantity": quantity,
      }),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(res.body);
    }
  }

  static Future<void> createDispatch(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/dispatch/create"),
      headers: await getHeaders(), // ✅ FIXED
      body: jsonEncode(data),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to create dispatch");
    }
  }

  static Future<List> getDispatchList() async {
    final res = await http.get(
      Uri.parse("$baseUrl/api/dispatch"),
      headers: await getHeaders(), // ✅ FIXED
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load dispatch list");
    }

    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getDispatchDetail(int id) async {
    final res = await http.get(
      Uri.parse("$baseUrl/api/dispatch/$id"),
      headers: await getHeaders(), // ✅ FIXED
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load dispatch detail");
    }

    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getOpenJobs() async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/jobs"),
      headers: await getHeaders(), // ✅ FIXED
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data.where((j) => j['status'] == 'OPEN').toList();
    } else {
      throw Exception("Failed to load jobs");
    }
  }

  static Future<List<dynamic>> getPartyYarnLedger(int partyId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/api/yarn/ledger-report/$partyId"),
      headers: await getHeaders(),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load party yarn ledger");
    }

    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getUsers() async {
    final res = await http.get(
      Uri.parse("$baseUrl/api/users"),
      headers: await getHeaders(),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load users: ${res.body}");
    }

    return jsonDecode(res.body);
  }

  static Future<void> createUser({
    required String name,
    required String username,
    required String password,
    required String role,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/users"),
      headers: await getHeaders(),
      body: jsonEncode({
        "name": name,
        "username": username,
        "password": password,
        "role": role,
      }),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("Failed to create user: ${res.body}");
    }
  }

  static Future<void> deleteUser(int id) async {
    final res = await http.delete(
      Uri.parse("$baseUrl/api/users/$id"),
      headers: await getHeaders(),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("Failed to delete user: ${res.body}");
    }
  }
}
