import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:safeships_flutter/common/api.dart';
import 'package:safeships_flutter/models/manager_model.dart';
import 'package:safeships_flutter/models/safety_patrol/safety_patrol_feedback_model.dart';
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
      throw jsonDecode(response.body)['message'] ?? 'Failed to fetch managers';
    }
  }

  Future<bool> submitSafetyPatrol({
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
      return true;
    } else {
      throw jsonDecode(response.body)['message'] ??
          'Failed to submit safety patrol';
    }
  }

  Future<List<SafetyPatrolModel>> getManagerial({
    required String token,
  }) async {
    var url = '${ApiEndpoint.baseUrl}/api/safety-patrols/managerial';
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
      return data.map((item) => SafetyPatrolModel.fromJson(item)).toList();
    } else {
      throw jsonDecode(response.body)['message'] ??
          'Failed to fetch managerial reports';
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
          'Failed to approve safety patrol';
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
          'Failed to reject safety patrol';
    }
  }

  Future<SafetyPatrolFeedbackModel> approveFeedback({
    required String token,
    required int feedbackId,
  }) async {
    var url =
        '${ApiEndpoint.baseUrl}/api/safety-patrols/feedback/$feedbackId/approve';
    var headers = {
      'Authorization': 'Bearer $token',
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
    );

    log('POST /api/safety-patrols/feedback/$feedbackId/approve response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return SafetyPatrolFeedbackModel.fromJson(data);
    } else {
      throw jsonDecode(response.body)['message'] ??
          'Failed to approve feedback';
    }
  }

  Future<SafetyPatrolFeedbackModel> rejectFeedback({
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
      return SafetyPatrolFeedbackModel.fromJson(data);
    } else {
      throw jsonDecode(response.body)['message'] ?? 'Failed to reject feedback';
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
          'Failed to fetch safety patrol';
    }
  }

  Future<List<SafetyPatrolModel>> getMySubmissions({
    required String token,
  }) async {
    var url = '${ApiEndpoint.baseUrl}/api/safety-patrols/my-submissions';
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
      throw jsonDecode(response.body)['message'] ??
          'Failed to fetch submissions';
    }
  }

  Future<List<SafetyPatrolModel>> getMyActions({
    required String token,
  }) async {
    var url = '${ApiEndpoint.baseUrl}/api/safety-patrols/my-actions';
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
      return data.map((item) => SafetyPatrolModel.fromJson(item)).toList();
    } else {
      throw jsonDecode(response.body)['message'] ?? 'Failed to fetch actions';
    }
  }

  Future<bool> submitFeedback({
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
      return true;
    } else {
      throw jsonDecode(response.body)['message'] ?? 'Failed to submit feedback';
    }
  }
}
