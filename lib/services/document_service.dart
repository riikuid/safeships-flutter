import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:safeships_flutter/common/api.dart';
import 'package:safeships_flutter/models/category_model.dart';
import 'package:safeships_flutter/models/category_with_doc_model.dart';
import 'package:safeships_flutter/models/document_model.dart';
import 'package:safeships_flutter/models/manager_model.dart';
import 'package:safeships_flutter/models/user_model.dart';

class DocumentService {
  Future<List<ManagerModel>> getManagers({
    required String token,
    String? role,
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

    log('GET /api/users response: ${response.body}');

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body)['data'];
      return data.map((item) => ManagerModel.fromJson(item)).toList();
    } else {
      throw jsonDecode(response.body)['message'] ?? 'Failed to fetch users';
    }
  }

  Future<List<UserModel>> getUsers({
    required String token,
    String? role,
  }) async {
    var url =
        '${ApiEndpoint.baseUrl}/api/users${role != null ? '?role=$role' : ''}';
    var headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    log('GET /api/users response: ${response.body}');

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body)['data'];
      return data.map((item) => UserModel.fromJson(item)).toList();
    } else {
      throw jsonDecode(response.body)['message'] ?? 'Failed to fetch users';
    }
  }

  Future<List<CategoryModel>> getCategories({
    required String token,
  }) async {
    var url = '${ApiEndpoint.baseUrl}/api/documents/categories';
    var headers = {
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    log(response.body);

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body)['data'];
      List<CategoryModel> categories =
          data.map((item) => CategoryModel.fromJson(item)).toList();
      return categories;
    } else {
      throw jsonDecode(response.body)['message'];
    }
  }

  Future<List<CategoryWithDocModel>> getCategoriesWithDocs({
    required String token,
    required int categoryId,
    // required int limit,
  }) async {
    var url =
        '${ApiEndpoint.baseUrl}/api/documents/level3?category_id=$categoryId';
    var headers = {
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    log(response.body);

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body)['data'];
      List<CategoryWithDocModel> histories =
          data.map((item) => CategoryWithDocModel.fromJson(item)).toList();
      return histories;
    } else {
      throw jsonDecode(response.body)['message'];
    }
  }

  Future<List<DocumentModel>> getDocumentsManagerial({
    required String token,
    // required int limit,
  }) async {
    var url = '${ApiEndpoint.baseUrl}/api/documents/managerial';
    var headers = {
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    log(response.body);

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body)['data'];
      List<DocumentModel> documents =
          data.map((item) => DocumentModel.fromJson(item)).toList();
      return documents;
    } else {
      throw jsonDecode(response.body)['message'];
    }
  }

  Future<bool> ajukanDokumentasiBaru({
    required String token,
    required String categoryId,
    required String managerId,
    required String title,
    required String description,
    required String pathFile,
  }) async {
    var url = '${ApiEndpoint.baseUrl}/api/documents';

    var requestMultipart = http.MultipartRequest('POST', Uri.parse(url));

    var headers = {
      'Authorization': 'Bearer $token',
    };

    // Isi field-body dari parameter
    requestMultipart.fields.addAll({
      'category_id': categoryId,
      'manager_id': managerId,
      'title': title,
      'description': description,
    });

    // Tambahkan file
    var docFile = await http.MultipartFile.fromPath('file', pathFile);
    requestMultipart.files.add(docFile);

    // Tambahkan headers
    requestMultipart.headers.addAll(headers);

    // Kirim permintaan
    var streamedResponse = await requestMultipart.send();

    // Terima respons
    var response = await http.Response.fromStream(streamedResponse);

    log(response.body);

    if (response.statusCode == 201) {
      // final data = jsonDecode(response.body)['data'];
      // DocumentModel documents = DocumentModel.fromJson(data);
      return true;
    } else {
      throw jsonDecode(response.body)['message'];
    }
  }

  Future<DocumentModel> approveDocument({
    required String token,
    required int documentId,
  }) async {
    var url = '${ApiEndpoint.baseUrl}/api/documents/$documentId/approve';
    var headers = {
      'Authorization': 'Bearer $token',
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
    );

    log(response.body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      DocumentModel documents = DocumentModel.fromJson(data);
      return documents;
    } else {
      throw jsonDecode(response.body)['message'];
    }
  }

  Future<DocumentModel> rejectDocument({
    required String token,
    required int documentId,
    required String comments,
  }) async {
    var url = '${ApiEndpoint.baseUrl}/api/documents/$documentId/reject';
    var headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    var body = jsonEncode({
      'comments': comments,
    });

    log(body.toString());

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    log(response.body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      DocumentModel documents = DocumentModel.fromJson(data);
      return documents;
    } else {
      throw jsonDecode(response.body)['message'];
    }
  }

  Future<List<DocumentModel>> getMySubmissions({
    required String token,
  }) async {
    var url = '${ApiEndpoint.baseUrl}/api/documents/my-submissions';
    var headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      log(response.body);

      if (response.statusCode == 200) {
        // final jsonResponse = jsonDecode(response.body);
        List data = jsonDecode(response.body)['data'];
        List<DocumentModel> documents =
            data.map((item) => DocumentModel.fromJson(item)).toList();
        return documents;
      } else {
        throw jsonDecode(response.body)['message'] ??
            'Failed to fetch submissions';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<DocumentModel> showDocument({
    required String token,
    required int documentId,
  }) async {
    var url = '${ApiEndpoint.baseUrl}/api/documents/$documentId/detail';
    var headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      log(response.body);

      if (response.statusCode == 200) {
        // final jsonResponse = jsonDecode(response.body);
        var data = jsonDecode(response.body)['data'];
        DocumentModel documents = DocumentModel.fromJson(data);
        return documents;
      } else {
        throw jsonDecode(response.body)['message'] ??
            'Failed to fetch submissions';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteDocument({
    required int documentId,
    required String token,
  }) async {
    if (token == null) throw 'No token found';

    final url = '${ApiEndpoint.baseUrl}/api/documents/$documentId';
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final response = await http.delete(Uri.parse(url), headers: headers);

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body)['message'] ?? 'Unknown error';
      throw error;
    }
  }

  Future<void> deleteDocumentsByCategory({
    required int categoryId,
    required String token,
  }) async {
    final url = '${ApiEndpoint.baseUrl}/api/documents/category/$categoryId';
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final response = await http.delete(Uri.parse(url), headers: headers);

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body)['message'] ?? 'Unknown error';
      throw error;
    }
  }
}
