import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:safeships_flutter/common/api.dart';
import 'package:safeships_flutter/models/manager_model.dart';
import 'package:safeships_flutter/models/safety_patrol/safety_patrol_card_model.dart';
import 'package:safeships_flutter/models/safety_patrol/safety_patrol_model.dart';

class SafetyPatrolService {
  Future<List<ManagerModel>> getManagers({
    required String token,
  }) async {
    var url = '${ApiEndpoint.baseUrl}/api/users/managers';
    var headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    log('GET /api/users/managers response: ${response.body}');

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body)['data'];
      return data.map((item) => ManagerModel.fromJson(item)).toList();
    } else {
      throw jsonDecode(response.body)['message'] ?? 'Gagal mengambil manajer';
    }
  }

  Future<SafetyPatrolModel> submitSafetyPatrol({
    required String token,
    required String managerId,
    required String reportDate,
    required String pathFile,
    required String type,
    required String description,
    required String location,
  }) async {
    var url = '${ApiEndpoint.baseUrl}/api/safety-patrols';

    var requestMultipart = http.MultipartRequest('POST', Uri.parse(url));

    var headers = {
      'Authorization': 'Bearer $token',
    };

    requestMultipart.fields.addAll({
      'manager_id': managerId,
      'report_date': reportDate,
      'type': type,
      'description': description,
      'location': location,
    });

    var imageFile = await http.MultipartFile.fromPath('image', pathFile);
    requestMultipart.files.add(imageFile);

    requestMultipart.headers.addAll(headers);

    var streamedResponse = await requestMultipart.send();
    var response = await http.Response.fromStream(streamedResponse);

    log('POST /api/safety-patrols response: ${response.body}');

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body)['data'];
      return SafetyPatrolModel.fromJson(data);
    } else {
      throw jsonDecode(response.body)['message'] ??
          'Gagal mengirim safety patrol';
    }
  }

  Future<List<SafetyPatrolCardModel>> getManagerial({
    required String token,
    String? status,
  }) async {
    var url = '${ApiEndpoint.baseUrl}/api/safety-patrols/managerial';
    if (status != null) {
      url += '?status=$status';
    }
    var headers = {
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    log('GET /api/safety-patrols/managerial response: ${response.body}');

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body)['data'];
      return data.map((item) => SafetyPatrolCardModel.fromJson(item)).toList();
    } else {
      throw jsonDecode(response.body)['message'] ??
          'Gagal mengambil laporan manajerial';
    }
  }

  Future<SafetyPatrolModel> approveSafetyPatrol({
    required String token,
    required int patrolId,
    String? actorId,
    String? deadline,
  }) async {
    var url = '${ApiEndpoint.baseUrl}/api/safety-patrols/$patrolId/approve';
    var headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    var body = jsonEncode({
      if (actorId != null) 'actor_id': actorId,
      if (deadline != null) 'deadline': deadline,
    });

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    log('POST /api/safety-patrols/$patrolId/approve response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return SafetyPatrolModel.fromJson(data);
    } else {
      throw jsonDecode(response.body)['message'] ??
          'Gagal menyetujui safety patrol';
    }
  }

  Future<SafetyPatrolModel> rejectSafetyPatrol({
    required String token,
    required int patrolId,
    required String comments,
  }) async {
    var url = '${ApiEndpoint.baseUrl}/api/safety-patrols/$patrolId/reject';
    var headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    var body = jsonEncode({
      'comments': comments,
    });

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    log('POST /api/safety-patrols/$patrolId/reject response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return SafetyPatrolModel.fromJson(data);
    } else {
      throw jsonDecode(response.body)['message'] ??
          'Gagal menolak safety patrol';
    }
  }

  Future<SafetyPatrolModel> approveFeedback({
    required String token,
    required int feedbackId,
  }) async {
    var url =
        '${ApiEndpoint.baseUrl}/api/safety-patrols/feedback/$feedbackId/approve';
    var headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
    );

    log('POST /api/safety-patrols/feedback/$feedbackId/approve response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return SafetyPatrolModel.fromJson(data);
    } else {
      throw jsonDecode(response.body)['message'] ?? 'Gagal menyetujui feedback';
    }
  }

  Future<SafetyPatrolModel> rejectFeedback({
    required String token,
    required int feedbackId,
    required String comments,
  }) async {
    var url =
        '${ApiEndpoint.baseUrl}/api/safety-patrols/feedback/$feedbackId/reject';
    var headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    var body = jsonEncode({
      'comments': comments,
    });

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    log('POST /api/safety-patrols/feedback/$feedbackId/reject response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return SafetyPatrolModel.fromJson(data);
    } else {
      throw jsonDecode(response.body)['message'] ?? 'Gagal menolak feedback';
    }
  }

  Future<SafetyPatrolModel> showSafetyPatrol({
    required String token,
    required int patrolId,
  }) async {
    var url = '${ApiEndpoint.baseUrl}/api/safety-patrols/$patrolId/detail';
    var headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    log('GET /api/safety-patrols/$patrolId/detail response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return SafetyPatrolModel.fromJson(data);
    } else {
      throw jsonDecode(response.body)['message'] ??
          'Gagal mengambil safety patrol';
    }
  }

  Future<List<SafetyPatrolModel>> getMySubmissions({
    required String token,
    String? status,
  }) async {
    var url = '${ApiEndpoint.baseUrl}/api/safety-patrols/my-submissions';
    if (status != null) {
      url += '?status=$status';
    }
    var headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    log('GET /api/safety-patrols/my-submissions response: ${response.body}');

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body)['data'];
      return data.map((item) => SafetyPatrolModel.fromJson(item)).toList();
    } else {
      throw jsonDecode(response.body)['message'] ?? 'Gagal mengambil pengajuan';
    }
  }

  Future<List<SafetyPatrolCardModel>> getMyActions({
    required String token,
    String? status,
  }) async {
    var url = '${ApiEndpoint.baseUrl}/api/safety-patrols/my-actions';
    if (status != null) {
      url += '?status=$status';
    }
    var headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    log('GET /api/safety-patrols/my-actions response: ${response.body}');

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body)['data'];
      return data.map((item) => SafetyPatrolCardModel.fromJson(item)).toList();
    } else {
      throw jsonDecode(response.body)['message'] ?? 'Gagal mengambil tindakan';
    }
  }

  Future<SafetyPatrolModel> submitFeedback({
    required String token,
    required int patrolId,
    required String feedbackDate,
    required String pathFile,
    required String description,
  }) async {
    var url =
        '${ApiEndpoint.baseUrl}/api/safety-patrols/$patrolId/submit-feedback';

    var requestMultipart = http.MultipartRequest('POST', Uri.parse(url));

    var headers = {
      'Authorization': 'Bearer $token',
    };

    requestMultipart.fields.addAll({
      'feedback_date': feedbackDate,
      'description': description,
    });

    var imageFile = await http.MultipartFile.fromPath('image', pathFile);
    requestMultipart.files.add(imageFile);

    requestMultipart.headers.addAll(headers);

    var streamedResponse = await requestMultipart.send();
    var response = await http.Response.fromStream(streamedResponse);

    log('POST /api/safety-patrols/$patrolId/submit-feedback response: ${response.body}');

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body)['data'];
      return SafetyPatrolModel.fromJson(data);
    } else {
      throw jsonDecode(response.body)['message'] ?? 'Gagal mengirim feedback';
    }
  }
}
