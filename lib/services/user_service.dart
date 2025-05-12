import 'dart:convert';
import 'dart:developer';

import 'package:safeships_flutter/common/api.dart';
import 'package:safeships_flutter/models/user_model.dart';
import 'package:http/http.dart' as http;

class UserService {
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

  // Get a specific user by ID
  Future<UserModel> getUserById({
    required String token,
    required int id,
  }) async {
    var url = '${ApiEndpoint.baseUrl}/api/users/$id';
    var headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    log('GET /api/users/$id response: ${response.body}');

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['data'];
      return UserModel.fromJson(data);
    } else {
      throw jsonDecode(response.body)['message'] ?? 'Failed to fetch user';
    }
  }

  // Create a new user
  Future<UserModel> createUser({
    required String token,
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    var url = '${ApiEndpoint.baseUrl}/api/users';
    var headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    var body = jsonEncode({
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    });

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    log('POST /api/users response: ${response.body}');

    if (response.statusCode == 201) {
      var data = jsonDecode(response.body)['data'];
      return UserModel.fromJson(data);
    } else {
      throw jsonDecode(response.body)['message'] ?? 'Failed to create user';
    }
  }

  // Update an existing user
  Future<UserModel> updateUser({
    required String token,
    required int id,
    required String name,
    required String email,
    String? password, // Password is optional
    required String role,
  }) async {
    var url = '${ApiEndpoint.baseUrl}/api/users/$id';
    var headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    var body = jsonEncode({
      'name': name,
      'email': email,
      if (password != null) 'password': password,
      'role': role,
    });

    final response = await http.put(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    log('PUT /api/users/$id response: ${response.body}');

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['data'];
      return UserModel.fromJson(data);
    } else {
      throw jsonDecode(response.body)['message'] ?? 'Failed to update user';
    }
  }

  // Delete a user
  Future<UserModel> deleteUser({
    required String token,
    required int id,
  }) async {
    var url = '${ApiEndpoint.baseUrl}/api/users/$id';
    var headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final response = await http.delete(
      Uri.parse(url),
      headers: headers,
    );

    log('DELETE /api/users/$id response: ${response.body}');

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['data'];
      return UserModel.fromJson(data);
    } else {
      throw jsonDecode(response.body)['message'] ?? 'Failed to delete user';
    }
  }
}
