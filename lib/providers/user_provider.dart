import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:safeships_flutter/common/token_repository.dart';
import 'package:safeships_flutter/models/user_model.dart';
import 'package:safeships_flutter/services/user_service.dart';

class UserProvider with ChangeNotifier {
  final TokenRepository tokenRepository = TokenRepository();

  List<UserModel> _managers = [];
  List<UserModel> get managers => _managers;

  final UserService _userService = UserService();

  Future getManagers({
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      List<UserModel> result = await _userService.getUser(
          token: (await tokenRepository.getToken())!, role: 'manager');

      _managers = result;

      notifyListeners();
    } catch (error) {
      if (kDebugMode) log(error.toString());
      errorCallback?.call(error);
      log('error get categories: $error');
    }
  }

  void resetManager() {
    _managers = [];
    notifyListeners();
  }
}
