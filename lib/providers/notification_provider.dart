import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:safeships_flutter/common/token_repository.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final TokenRepository tokenRepository = TokenRepository();
  final NotificationService _notificationService = NotificationService();

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> getNotifications({
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await tokenRepository.getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final result = await _notificationService.getNotifications(token: token);
      _notifications = result;
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        log('Error fetching notifications: $error');
      }
      errorCallback?.call(error);
    }
  }
}
