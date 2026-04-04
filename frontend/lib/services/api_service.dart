import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;



class ApiService {
  static const baseUrl = "http://192.168.1.31:4000";

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

  request.fields['party_id'] = partyId.toString();
  request.fields['machine_ids'] = jsonEncode(machineIds);
  request.fields['fabric_id'] = fabricId.toString();
  request.fields['gsm'] = gsm.toString();
  request.fields['order_quantity'] = orderQuantity.toString();
  request.fields['yarns'] = jsonEncode(yarns);

  if (image != null) {
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        image.path,
      ),
    );
  }

  final res = await request.send();

  if (res.statusCode < 200 || res.statusCode >= 300) {
    throw Exception("Job creation failed");
  }
}


  /* ================= JOBS ================= */

  

static Future<List<dynamic>> getJobs() async {
  final res = await http.get(
    Uri.parse("$baseUrl/api/jobs"),
    headers: {
      "Content-Type": "application/json",
    },
  );

  if (res.statusCode != 200) {
    throw Exception("Failed to load jobs: ${res.body}");
  }

  return jsonDecode(res.body);
}

  static Future<Map<String, dynamic>> getJobDetail(String jobNo) async {
    final res = await http.get(Uri.parse("$baseUrl/api/jobs/$jobNo"));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("Error ${res.statusCode}: ${res.body}");
    }

    return jsonDecode(res.body);
  }

  /* ================= CLOSE JOB ================= */

  static Future<void> closeJob(String jobNo) async {
  final res = await http.put(
    Uri.parse("$baseUrl/api/jobs/close/$jobNo"),
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
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "rpm": rpm,
      "counter": counter,
      "roll_size": rollSize,
    }),
  );
}
/* ================= UPDATE MACHINE STATUS ================= */
static Future<void> updateMachineStatus(
    int machineId, String status) async {
  final res = await http.put(
    Uri.parse("$baseUrl/api/machines/$machineId/status"),
    headers: {"Content-Type": "application/json"},
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
  File? image, // ✅ ADD THIS
}) async {

  var request = http.MultipartRequest(
    'PUT',
    Uri.parse("$baseUrl/api/jobs/$jobId"),
  );

  request.fields['party_id'] = partyId.toString();
  request.fields['machine_ids'] = jsonEncode(machineIds);
  request.fields['fabric_id'] = fabricId.toString();
  request.fields['gsm'] = gsm.toString();
  request.fields['order_quantity'] = orderQuantity.toString();
  request.fields['yarns'] = jsonEncode(yarns);

  /// ✅ IMAGE SUPPORT
  if (image != null) {
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        image.path,
      ),
    );
  }

  final res = await request.send();

  if (res.statusCode < 200 || res.statusCode >= 300) {
    throw Exception("Job update failed");
  }
}

  /* ================= PARTY ================= */

  static Future<List<dynamic>> getParties() async {
    final res = await http.get(Uri.parse("$baseUrl/api/parties"));
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
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "phone": phone}),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(res.body);
    }
  }
  
    /* ================= YARN Party Ledger ================= */
static Future<List<dynamic>> getPartyLedger() async {
  final res = await http.get(Uri.parse("$baseUrl/api/yarn/yarn-ledger"));

  if (res.statusCode != 200) {
    throw Exception("Failed to load party ledger");
  }

  return jsonDecode(res.body);
}
static Future<List<dynamic>> getPartyYarnSummary() async {
  final res = await http.get(Uri.parse("$baseUrl/api/yarn/party-summary"));

  if (res.statusCode != 200) {
    throw Exception("Failed to load party summary");
  }

  return jsonDecode(res.body);
}
  /* ================= YARN ================= */

  static Future<List<dynamic>> getYarnMaster() async {
    print("Calling GET YARN MASTER..    ");

    final res = await http.get(Uri.parse("$baseUrl/api/yarn"));
      
    print("STATUS: ${res.statusCode}");
    print("BODY: ${res.body}");

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
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "yarn_name": yarnName,
        "yarn_count": yarnCount,
        "yarn_type": yarnType,
      }),
    );

    print("ADD YARN STATUS: ${res.statusCode}");
    print("ADD YARN BODY: ${res.body}");

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("Add Yarn Failed: ${res.body}");
    }
  }

  /* ================= YARN STOCK ================= */

  static Future<List<dynamic>> getYarnStock() async {
    final res = await http.get(Uri.parse("$baseUrl/api/yarn/stock"));
    if (res.statusCode != 200) {
      throw Exception("Failed to load yarn stock");
    }
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getStockByParty(int partyId) async {
    final res =
        await http.get(Uri.parse("$baseUrl/api/yarn/stock-by-party/$partyId"));

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
      headers: {"Content-Type": "application/json"},
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
      headers: {"Content-Type": "application/json"},
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
      headers: {"Content-Type": "application/json"},
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
      headers: {"Content-Type": "application/json"},
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

static Future addProduction(
    int jobId,
    List<double> weights,
) async {

  final res = await http.post(
    Uri.parse("$baseUrl/api/production/bulk"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "job_id": jobId,
      "weights": weights
    }),
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
      Uri.parse(
        "$baseUrl/api/jobs/filter?party_id=$partyId&fabric_id=$fabricId",
      ),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load jobs");
    }
  }

  /* ================= PRODUCTS ================= */

  static Future<List<dynamic>> getFabrics() async {
    final res = await http.get(Uri.parse("$baseUrl/api/fabrics"));
    if (res.statusCode != 200) {
      throw Exception("Failed to load fabrics");
    }
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getYarnLotsByParty(int partyId) async {
  final res = await http.get(
    Uri.parse("$baseUrl/api/yarn/inward/$partyId"),
  );

  if (res.statusCode != 200) {
    throw Exception("Failed to load yarn lots");
  }

  return jsonDecode(res.body);
}


  /* ================= MACHINES ================= */

  static Future<List<dynamic>> getMachines() async {
    final res = await http.get(Uri.parse("$baseUrl/api/machines"));
    if (res.statusCode != 200) {
      throw Exception("Failed to load machines");
    }
    return jsonDecode(res.body);
  }

  static Future<void> createMachine(String machineNo) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/machines"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"machine_no": machineNo}),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(res.body);
    }
  }

  /* ================= Yarn Stock BY PARTY ================= */
  static Future<List<dynamic>> getYarnStockByParty(int partyId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/api/yarn/stock-by-party/$partyId"),
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
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "description": description,
      }),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("Failed to add fabric");
    }
  }
  /* ================= Delete Job HISTORY ================= */
    static Future<void> deleteJob(int id) async {

    await http.delete(
      Uri.parse("$baseUrl/api/jobs/$id"),
    );

  }

    /* ================= JOB YARN HISTORY ================= */
  static Future<List<dynamic>> getJobYarnHistory(String jobNo) async {
    final res = await http.get(
      Uri.parse("$baseUrl/api/jobs/$jobNo/yarn-history"),
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
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load production history");
    }

    return jsonDecode(res.body);
  } 

  
/* ============================================================
   DISPATCH MODULE
============================================================ */

  /* GET ROLLS READY FOR DISPATCH */

  static Future<dynamic> getDispatchRolls(int jobId) async {
  final response = await http.get(
    Uri.parse("$baseUrl/api/dispatch/rolls/$jobId"),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Failed to load rolls");
  }
}

  /* DISPATCH SELECTED ROLLS */

  static Future<void> dispatchRolls({
    required int jobId,
    required List<Map<String, dynamic>> rolls,
  }) async {

    final res = await http.post(
      Uri.parse("$baseUrl/api/dispatch"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "job_id": jobId,
        "rolls": rolls,
      }),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("Dispatch failed");
    }
  }

  /* ================= JOB DISPATCH HISTORY ================= */

static Future<List<dynamic>> getJobDispatchHistory(String jobNo) async {

  final res = await http.get(
    Uri.parse("$baseUrl/api/jobs/$jobNo/dispatch-history"),
  );

  if (res.statusCode != 200) {
    throw Exception("Failed to load dispatch history");
  }

  return jsonDecode(res.body);

}

static Future<void> uploadParties(File file) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse("$baseUrl/api/parties/upload"),
  );

  request.files.add(
    await http.MultipartFile.fromPath('file', file.path),
  );

  final res = await request.send();

  if (res.statusCode < 200 || res.statusCode >= 300) {
    throw Exception("Upload failed");
  }
}

static void downloadPartyTemplate() async {
  final url = "$baseUrl/api/templates/party-template";
  await http.get(Uri.parse(url));
}

static Future<List<dynamic>> getJobIssuedYarns(int jobId) async {
  final res = await http.get(
    Uri.parse("$baseUrl/api/jobs/$jobId/issued-yarns"),
  );

  if (res.statusCode == 200) {
    return jsonDecode(res.body);
  } else {
    throw Exception("Failed to load issued yarns");
  }
}
static Future<void> addSetting({
  required int jobId,
  required double quantity,
}) async {
  final res = await http.post(
    Uri.parse("$baseUrl/api/yarn/setting"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "job_id": jobId,
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
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(data),
  );

  if (res.statusCode != 200) {
    throw Exception("Failed to create dispatch");
  }
}

static Future<List> getDispatchList() async {
  final res = await http.get(
    Uri.parse("$baseUrl/api/dispatch"),
  );

  if (res.statusCode != 200) {
    throw Exception("Failed to load dispatch list");
  }

  return jsonDecode(res.body);
}

static Future<Map<String, dynamic>> getDispatchDetail(int id) async {
  final res = await http.get(
    Uri.parse("$baseUrl/api/dispatch/$id"),
  );

  if (res.statusCode != 200) {
    throw Exception("Failed to load dispatch detail");
  }

  return jsonDecode(res.body);
}
static Future<List<dynamic>> getOpenJobs() async {
  final response = await http.get(
    Uri.parse("$baseUrl/api/jobs"),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    // 🔥 filter only OPEN jobs
    return data.where((j) => j['status'] == 'OPEN').toList();
  } else {
    throw Exception("Failed to load jobs");
  }
}

}