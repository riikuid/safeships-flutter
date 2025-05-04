import 'dart:convert';
import 'dart:developer';

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
}
