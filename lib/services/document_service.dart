import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:safeships_flutter/common/api.dart';
import 'package:safeships_flutter/models/category_model.dart';
import 'package:safeships_flutter/models/category_with_doc_model.dart';
import 'package:safeships_flutter/models/document_model.dart';

class DocumentService {
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
}
