import 'dart:convert';
import 'dart:developer';

import 'package:safeships_flutter/common/api.dart';
import 'package:safeships_flutter/common/token_repository.dart';
import 'package:safeships_flutter/models/auth_model.dart';
import 'package:http/http.dart' as http;

class AuthService {
  TokenRepository tokenRepository = TokenRepository();

  Future<AuthModel> login({
    required String email,
    required String password,
    required String fcmToken,
  }) async {
    tokenRepository.clearToken();
    var url = '${ApiEndpoint.baseUrl}/api/login';
    var headers = {
      'Content-Type': 'application/json',
    };
    var body = jsonEncode({
      'email': email,
      'password': password,
      'fcm_token': fcmToken,
    });
    log('service body $body');

    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    log(response.body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      AuthModel user = AuthModel.fromJson(data['user']);
      tokenRepository.putToken(data['token']);
      return user;
    } else {
      throw jsonDecode(response.body)['message'];
    }
  }

  Future<bool> logout() async {
    var url = '${ApiEndpoint.baseUrl}/api/logout';

    String token = (await tokenRepository.getToken())!;
    var headers = {
      'Authorization': 'Bearer $token',
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
    );

    log(response.body);

    if (response.statusCode == 200) {
      tokenRepository.clearToken();
      return true;
    } else {
      throw jsonDecode(response.body)['message'];
    }
  }

  Future<AuthModel> authWithToken(String token) async {
    var url = '${ApiEndpoint.baseUrl}/api/user';
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    print(response.body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['data'];
      AuthModel user = AuthModel.fromJson(data);
      return user;
    } else {
      throw jsonDecode(response.body)['message'];
    }
  }

  // Future<AuthModel> register({
  //   required String fullName,
  //   required String email,
  //   required String password,
  //   required String fcmToken,
  //   required String passwordConfirmation,
  // }) async {
  //   var url = '${ApiEndpoint.baseUrl}/api/register';

  //   var headers = {'Content-Type': 'application/json'};

  //   var body = jsonEncode({
  //     'name': fullName,
  //     'email': email,
  //     'password_confirmation': passwordConfirmation,
  //     'password': password,
  //     'fmc_token': fcmToken,
  //   });

  //   final response = await http.post(
  //     Uri.parse(url),
  //     headers: headers,
  //     body: body,
  //   );

  //   print(response.body);

  //   if (response.statusCode == 201) {
  //     return AuthModel.fromJson(jsonDecode(response.body)['user']);
  //   } else {
  //     throw jsonDecode(response.body)['message'];
  //   }
  // }
}
