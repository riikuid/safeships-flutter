import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:safeships_flutter/models/auth_model.dart';
import 'package:safeships_flutter/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  AuthModel? _user;
  AuthModel get user => _user!;

  Future<bool> login({
    required String email,
    required String password,
    required String fcmToken,
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      log('masuk');
      AuthModel data = await AuthService().login(
        email: email,
        password: password,
        fcmToken: fcmToken,
      );

      _user = data;
      notifyListeners();

      return true;
    } on SocketException {
      errorCallback?.call("No Internet Connection");
      return false;
    } catch (e) {
      errorCallback?.call(e);
      return false;
    }
  }

  Future<bool> guestLogin({
    required String fcmToken,
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      log('masuk');
      AuthModel data = await AuthService().guestLogin(
        fcmToken: fcmToken,
      );

      _user = data;
      notifyListeners();

      return true;
    } on SocketException {
      errorCallback?.call("No Internet Connection");
      return false;
    } catch (e) {
      errorCallback?.call(e);
      return false;
    }
  }

  Future<bool> logout({
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      log('logout');
      await AuthService().logout();

      _user = null;
      notifyListeners();

      return true;
    } on SocketException {
      errorCallback?.call("No Internet Connection");
      return false;
    } catch (e) {
      errorCallback?.call(e);
      return false;
    }
  }

  // Future<bool> register({
  //   required String nama,
  //   required String notelp,
  //   required String kampus,
  //   required String nrp,
  //   required String email,
  //   required String password,
  //   required String passwordConfirmation,
  //   void Function(dynamic)? errorCallback,
  // }) async {
  //   try {
  //     authRepository.clearAuth();
  //     AuthModel data = await AuthService().register(
  //       nama: nama,
  //       notelp: notelp,
  //       kampus: kampus,
  //       nrp: nrp,
  //       email: email,
  //       password: password,
  //       passwordConfirmation: passwordConfirmation,
  //     );
  //     authRepository.putAuth(data);

  //     _user = data.user;
  //     notifyListeners();

  //     return true;
  //   } on SocketException {
  //     errorCallback?.call("No Internet Connection");
  //     return false;
  //   } catch (e) {
  //     log('error regis $e');
  //     errorCallback?.call(e);
  //     return false;
  //   }
  // }

  Future<bool> getProfile({
    required String token,
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      AuthModel data = await AuthService().authWithToken(token);

      _user = data;
      notifyListeners();

      return true;
    } on SocketException {
      errorCallback?.call("No Internet Connection");
      return false;
    } catch (e) {
      errorCallback?.call(e);
      return false;
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      _user = await AuthService().updateProfile(name: name, email: email);
      notifyListeners();
      return true;
    } on SocketException {
      errorCallback?.call("No Internet Connection");
      return false;
    } catch (e) {
      errorCallback?.call(e);
      return false;
    }
  }

  Future<bool> resetPassword({
    required int userId,
    required String password,
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      await AuthService().resetPassword(userId: userId, password: password);
      return true;
    } on SocketException {
      errorCallback?.call("No Internet Connection");
      return false;
    } catch (e) {
      errorCallback?.call(e);
      return false;
    }
  }
}
