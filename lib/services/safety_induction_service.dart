import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:safeships_flutter/common/api.dart';
import 'package:safeships_flutter/models/safety_induction/certificate_model.dart';
import 'package:safeships_flutter/models/safety_induction/location_model.dart';
import 'package:safeships_flutter/models/safety_induction/question_model.dart';
import 'package:safeships_flutter/models/safety_induction/question_package_model.dart';
import 'package:safeships_flutter/models/safety_induction/safety_induction_attempt_model.dart';
import 'package:safeships_flutter/models/safety_induction/safety_induction_model.dart';

class SafetyInductionService {
  Future<List<LocationModel>> getLocations({required String token}) async {
    final url = '${ApiEndpoint.baseUrl}/api/safety-inductions/locations';
    final headers = {'Authorization': 'Bearer $token'};

    final response = await http.get(Uri.parse(url), headers: headers);
    log('GET /api/safety-inductions/locations response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      return data.map((item) => LocationModel.fromJson(item)).toList();
    } else {
      throw jsonDecode(response.body)['message'] ?? 'Failed to fetch locations';
    }
  }

  Future<SafetyInductionModel> createSafetyInduction({
    required String token,
    required String name,
    required String type,
    String? address,
    String? phoneNumber,
    String? email,
    bool forceCreate = false,
  }) async {
    final url = '${ApiEndpoint.baseUrl}/api/safety-inductions';
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'name': name,
      'type': type,
      'address': address,
      'phone_number': phoneNumber,
      'email': email,
      'force_create': forceCreate,
    });

    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);
    log('POST /api/safety-inductions response: ${response.body}');

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body)['data'];
      return SafetyInductionModel.fromJson(data);
    } else if (response.statusCode == 409) {
      final data = jsonDecode(response.body)['data'];
      throw PendingSubmissionException(
        message: jsonDecode(response.body)['message'] ??
            'Anda masih memiliki pengajuan yang belum selesai',
        pendingSubmission:
            SafetyInductionModel.fromJson(data['pending_submission']),
        options: List<String>.from(data['options']),
      );
    } else {
      throw jsonDecode(response.body)['message'] ??
          'Failed to create induction';
    }
  }

  Future<Map<String, dynamic>> getQuestions({
    required String token,
    required int inductionId,
  }) async {
    final url =
        '${ApiEndpoint.baseUrl}/api/safety-inductions/$inductionId/questions';
    final headers = {'Authorization': 'Bearer $token'};

    final response = await http.get(Uri.parse(url), headers: headers);
    log('GET /api/safety-inductions/$inductionId/questions response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return {
        'package': QuestionPackageModel.fromJson(data['package']),
        'questions': (data['questions'] as List)
            .map((item) => QuestionModel.fromJson(item))
            .toList(),
      };
    } else {
      throw jsonDecode(response.body)['message'] ?? 'Failed to fetch questions';
    }
  }

  Future<Map<String, dynamic>> submitAnswers({
    required String token,
    required int inductionId,
    required int questionPackageId,
    required List<Map<String, dynamic>> answers,
  }) async {
    final url =
        '${ApiEndpoint.baseUrl}/api/safety-inductions/$inductionId/submit-answers';
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'question_package_id': questionPackageId,
      'answers': answers,
    });
    log(body.toString());

    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);
    log('POST /api/safety-inductions/$inductionId/submit-answers response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return {
        'attempt': SafetyInductionAttemptModel.fromJson(data['attempt']),
        'can_retry': data['can_retry'],
        'certificate': data['certificate'] != null
            ? CertificateModel.fromJson(data['certificate'])
            : null,
      };
    } else {
      throw jsonDecode(response.body)['message'] ?? 'Failed to submit answers';
    }
  }

  Future<Map<String, dynamic>> getResult({
    required String token,
    required int inductionId,
  }) async {
    final url =
        '${ApiEndpoint.baseUrl}/api/safety-inductions/$inductionId/result';
    final headers = {'Authorization': 'Bearer $token'};

    final response = await http.get(Uri.parse(url), headers: headers);
    log('GET /api/safety-inductions/$inductionId/result response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return {
        'induction': SafetyInductionModel.fromJson(data['induction']),
        'attempts': (data['attempts'] as List)
            .map((item) => SafetyInductionAttemptModel.fromJson(item))
            .toList(),
        'certificate': data['certificate'] != null
            ? CertificateModel.fromJson(data['certificate'])
            : null,
      };
    } else {
      throw jsonDecode(response.body)['message'] ?? 'Failed to fetch result';
    }
  }

  Future<CertificateModel> getCertificate({
    required String token,
    required int inductionId,
  }) async {
    final url =
        '${ApiEndpoint.baseUrl}/api/safety-inductions/$inductionId/certificate';
    final headers = {'Authorization': 'Bearer $token'};

    final response = await http.get(Uri.parse(url), headers: headers);
    log('GET /api/safety-inductions/$inductionId/certificate response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return CertificateModel.fromJson(data);
    } else {
      throw jsonDecode(response.body)['message'] ??
          'Failed to fetch certificate';
    }
  }

  Future<List<SafetyInductionModel>> getMySubmissions({
    required String token,
  }) async {
    final url = '${ApiEndpoint.baseUrl}/api/safety-inductions/my-submissions';
    final headers = {'Authorization': 'Bearer $token'};

    final response = await http.get(Uri.parse(url), headers: headers);
    log('GET /api/safety-inductions/my-submissions response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      return data.map((item) => SafetyInductionModel.fromJson(item)).toList();
    } else {
      throw jsonDecode(response.body)['message'] ??
          'Failed to fetch submissions';
    }
  }

  Future<void> markAsFailed({
    required String token,
    required int inductionId,
  }) async {
    final url =
        '${ApiEndpoint.baseUrl}/api/safety-inductions/$inductionId/fail';
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final response = await http.post(Uri.parse(url), headers: headers);
    log('POST /api/safety-inductions/$inductionId/fail response: ${response.body}');

    if (response.statusCode == 200) {
      return;
    } else {
      throw jsonDecode(response.body)['message'] ??
          'Failed to mark induction as failed';
    }
  }
}

class PendingSubmissionException implements Exception {
  final String message;
  final SafetyInductionModel pendingSubmission;
  final List<String> options;

  PendingSubmissionException({
    required this.message,
    required this.pendingSubmission,
    required this.options,
  });

  @override
  String toString() => message;
}
