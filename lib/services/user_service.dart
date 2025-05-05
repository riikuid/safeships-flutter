import 'dart:convert';
import 'dart:developer';

import 'package:safeships_flutter/common/api.dart';
import 'package:safeships_flutter/models/user_model.dart';
import 'package:http/http.dart' as http;

class UserService {
  Future<List<UserModel>> getUser({
    required String token,
    String? role,
  }) async {
    var url = '${ApiEndpoint.baseUrl}/api/user?role=$role';
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
      List<UserModel> categories =
          data.map((item) => UserModel.fromJson(item)).toList();
      return categories;
    } else {
      throw jsonDecode(response.body)['message'];
    }
  }
}
