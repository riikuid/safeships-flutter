import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:safeships_flutter/common/api.dart';
import '../models/notification_model.dart';

class NotificationService {
  Future<List<NotificationModel>> getNotifications({
    required String token,
  }) async {
    var url = '${ApiEndpoint.baseUrl}/api/notifications';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        return data
            .map((json) =>
                NotificationModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
            'Failed to fetch notifications: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching notifications: $e');
      }
      rethrow;
    }
  }
}
