import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:safeships_flutter/common/token_repository.dart';
import 'package:safeships_flutter/models/user_model.dart';
import 'package:safeships_flutter/services/user_service.dart';

class UserProvider with ChangeNotifier {
  final TokenRepository tokenRepository = TokenRepository();

  final UserService _userService = UserService();

  List<UserModel> _users = [];
  List<UserModel> get users => _users;

  UserModel? _selectedUser;
  UserModel? get selectedUser => _selectedUser;

  Future<void> getUsers({
    String? role,
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      List<UserModel> result = await _userService.getUsers(
        token: (await tokenRepository.getToken())!,
        role: role,
      );

      _users = result;
      notifyListeners();
    } catch (error) {
      if (kDebugMode) log('Error fetching users: $error');
      errorCallback?.call(error);
    }
  }

  Future<void> getUserById({
    required int id,
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      UserModel result = await _userService.getUserById(
        token: (await tokenRepository.getToken())!,
        id: id,
      );

      _selectedUser = result;
      notifyListeners();
    } catch (error) {
      if (kDebugMode) log('Error fetching user by ID: $error');
      errorCallback?.call(error);
    }
  }

  Future<bool> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      UserModel result = await _userService.createUser(
        token: (await tokenRepository.getToken())!,
        name: name,
        email: email,
        password: password,
        role: role,
      );

      _users.add(result);
      notifyListeners();
      return true;
    } catch (error) {
      if (kDebugMode) log('Error creating user: $error');
      errorCallback?.call(error);
      return false;
    }
  }

  Future<bool> updateUser({
    required int id,
    required String name,
    required String email,
    String? password,
    required String role,
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      UserModel result = await _userService.updateUser(
        token: (await tokenRepository.getToken())!,
        id: id,
        name: name,
        email: email,
        password: password,
        role: role,
      );

      _users = _users.map((user) {
        if (user.id == result.id) {
          return result;
        }
        return user;
      }).toList();

      if (_selectedUser?.id == result.id) {
        _selectedUser = result;
      }

      notifyListeners();
      return true;
    } catch (error) {
      if (kDebugMode) log('Error updating user: $error');
      errorCallback?.call(error);
      return false;
    }
  }

  Future<bool> deleteUser({
    required int id,
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      UserModel deletedUser = await _userService.deleteUser(
        token: (await tokenRepository.getToken())!,
        id: id,
      );

      _users = _users.where((user) => user.id != id).toList();
      if (_selectedUser?.id == id) {
        _selectedUser = null;
      }

      notifyListeners();
      return true;
    } catch (error) {
      if (kDebugMode) log('Error deleting user: $error');
      errorCallback?.call(error);
      return false;
    }
  }

  Future<bool> resetPassword({
    required int id,
    required String password,
    required Function(String) errorCallback,
  }) async {
    try {
      final token = await tokenRepository.getToken();
      if (token == null) throw 'No token found';
      await _userService.resetPassword(
        token: token,
        id: id,
        password: password,
        errorCallback: errorCallback,
      );
      notifyListeners();
      return true;
    } catch (error) {
      errorCallback(error.toString());
      return false;
    }
  }

  void resetSelectedUser() {
    _selectedUser = null;
    notifyListeners();
  }

  void resetUsers() {
    _users = [];
    _selectedUser = null;
    notifyListeners();
  }
}
