import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:safeships_flutter/common/token_repository.dart';
import 'package:safeships_flutter/models/manager_model.dart';
import 'package:safeships_flutter/models/safety_patrol/safety_patrol_approval_model.dart';
import 'package:safeships_flutter/models/safety_patrol/safety_patrol_card_model.dart';
import 'package:safeships_flutter/models/safety_patrol/safety_patrol_feedback_approval_model.dart';
import 'package:safeships_flutter/models/safety_patrol/safety_patrol_model.dart';
import 'package:safeships_flutter/services/safety_patrol_service.dart';

class SafetyPatrolProvider with ChangeNotifier {
  final TokenRepository tokenRepository = TokenRepository();
  final SafetyPatrolService _safetyPatrolService = SafetyPatrolService();

  List<ManagerModel> _managers = [];
  List<ManagerModel> get managers => _managers;

  List<SafetyPatrolCardModel> _managerialPatrols = [];
  List<SafetyPatrolCardModel> get managerialPatrols => _managerialPatrols;

  List<SafetyPatrolModel> _mySubmissions = [];
  List<SafetyPatrolModel> get mySubmissions => _mySubmissions;

  List<SafetyPatrolCardModel> _myActions =
      []; // Changed to SafetyPatrolCardModel
  List<SafetyPatrolCardModel> get myActions => _myActions;

  Future<void> getManagers({
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      List<ManagerModel> result = await _safetyPatrolService.getManagers(
        token: (await tokenRepository.getToken())!,
      );

      _managers = result;
      notifyListeners();
    } catch (error) {
      if (kDebugMode) log('Error fetching managers: $error');
      errorCallback?.call(error);
    }
  }

  Future<SafetyPatrolModel> submitSafetyPatrol({
    required String managerId,
    required String reportDate,
    required String pathFile,
    required String type,
    required String description,
    required String location,
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      SafetyPatrolModel result = await _safetyPatrolService.submitSafetyPatrol(
        token: (await tokenRepository.getToken())!,
        managerId: managerId,
        reportDate: reportDate,
        pathFile: pathFile,
        type: type,
        description: description,
        location: location,
      );

      _mySubmissions = [..._mySubmissions, result];
      notifyListeners();
      return result;
    } on SocketException {
      errorCallback?.call("Terjadi Kesalahan Koneksi");
      rethrow;
    } catch (e) {
      errorCallback?.call(e);
      rethrow;
    }
  }

  Future<void> getManagerial({
    void Function(dynamic)? errorCallback,
    String? status,
  }) async {
    try {
      List<SafetyPatrolCardModel> result =
          await _safetyPatrolService.getManagerial(
        token: (await tokenRepository.getToken())!,
        status: status,
      );

      _managerialPatrols = result;
      notifyListeners();
    } catch (error) {
      if (kDebugMode) log('Error fetching managerial patrols: $error');
      errorCallback?.call(error);
    }
  }

  Future<SafetyPatrolModel> approveSafetyPatrol({
    required int patrolId,
    required int userId,
    String? actorId,
    String? deadline,
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      SafetyPatrolModel result = await _safetyPatrolService.approveSafetyPatrol(
        token: (await tokenRepository.getToken())!,
        patrolId: patrolId,
        actorId: actorId,
        deadline: deadline,
      );

      _managerialPatrols = _managerialPatrols.map((patrol) {
        if (patrol.id == result.id) {
          return SafetyPatrolCardModel(
            id: result.id,
            type: result.type.toString().split('.').last,
            location: result.location,
            description: result.description,
            status: result.status,
            createdAt: result.createdAt,
            userApprovalStatus: result.approvals!
                .firstWhere(
                  (approval) => approval.approverId == userId,
                  orElse: () => SafetyPatrolApprovalModel(
                    id: 0,
                    safetyPatrolId: patrolId,
                    approverId: userId,
                    status: 'approved',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                )
                .status,
          );
        }
        return patrol;
      }).toList();

      _mySubmissions = _mySubmissions.map((patrol) {
        if (patrol.id == result.id) return result;
        return patrol;
      }).toList();

      _myActions = _myActions.map((patrol) {
        if (patrol.id == result.id) {
          return SafetyPatrolCardModel(
            id: result.id,
            type: result.type.toString().split('.').last,
            location: result.location,
            description: result.description,
            status: result.status,
            createdAt: result.createdAt,
            deadline: DateTime.parse(deadline!), // Use the provided deadline
          );
        }
        return patrol;
      }).toList();

      notifyListeners();
      return result;
    } catch (error) {
      if (kDebugMode) log('Error approving safety patrol: $error');
      errorCallback?.call(error);
      rethrow;
    }
  }

  Future<SafetyPatrolModel> rejectSafetyPatrol({
    required int patrolId,
    required int userId,
    required String comments,
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      SafetyPatrolModel result = await _safetyPatrolService.rejectSafetyPatrol(
        token: (await tokenRepository.getToken())!,
        patrolId: patrolId,
        comments: comments,
      );

      _managerialPatrols = _managerialPatrols.map((patrol) {
        if (patrol.id == result.id) {
          return SafetyPatrolCardModel(
            id: result.id,
            type: result.type.toString().split('.').last,
            location: result.location,
            description: result.description,
            status: result.status,
            createdAt: result.createdAt,
            userApprovalStatus: result.approvals!
                .firstWhere(
                  (approval) => approval.approverId == userId,
                  orElse: () => SafetyPatrolApprovalModel(
                    id: 0,
                    safetyPatrolId: patrolId,
                    approverId: userId,
                    status: 'rejected',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                )
                .status,
          );
        }
        return patrol;
      }).toList();

      _mySubmissions = _mySubmissions.map((patrol) {
        if (patrol.id == result.id) return result;
        return patrol;
      }).toList();

      _myActions = _myActions.map((patrol) {
        if (patrol.id == result.id) {
          return SafetyPatrolCardModel(
            id: result.id,
            type: result.type.toString().split('.').last,
            location: result.location,
            description: result.description,
            status: result.status,
            createdAt: result.createdAt,
            deadline: patrol.deadline, // Preserve existing deadline
          );
        }
        return patrol;
      }).toList();

      notifyListeners();
      return result;
    } catch (error) {
      if (kDebugMode) log('Error rejecting safety patrol: $error');
      errorCallback?.call(error);
      rethrow;
    }
  }

  Future<SafetyPatrolModel> approveFeedback({
    required int feedbackId,
    required int patrolId,
    required int userId,
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      SafetyPatrolModel result = await _safetyPatrolService.approveFeedback(
        token: (await tokenRepository.getToken())!,
        feedbackId: feedbackId,
      );

      _managerialPatrols = _managerialPatrols.map((patrol) {
        if (patrol.id == patrolId) {
          return SafetyPatrolCardModel(
            id: patrol.id,
            type: patrol.type,
            location: patrol.location,
            description: patrol.description,
            status: result.status,
            createdAt: patrol.createdAt,
            userApprovalStatus: result.feedbacks
                    ?.firstWhere((f) => f.id == feedbackId)
                    .approvals
                    ?.firstWhere(
                      (approval) => approval.approverId == userId,
                      orElse: () => SafetyPatrolFeedbackApprovalModel(
                        id: 0,
                        feedbackId: feedbackId,
                        approverId: userId,
                        status: 'approved',
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                    )
                    .status ??
                patrol.userApprovalStatus,
          );
        }
        return patrol;
      }).toList();

      _mySubmissions = _mySubmissions.map((patrol) {
        if (patrol.id == patrolId) return result;
        return patrol;
      }).toList();

      _myActions = _myActions.map((patrol) {
        if (patrol.id == patrolId) {
          return SafetyPatrolCardModel(
            id: patrol.id,
            type: patrol.type,
            location: patrol.location,
            description: patrol.description,
            status: result.status,
            createdAt: patrol.createdAt,
            deadline: patrol.deadline, // Preserve existing deadline
          );
        }
        return patrol;
      }).toList();

      notifyListeners();
      return result;
    } catch (error) {
      if (kDebugMode) log('Error approving feedback: $error');
      errorCallback?.call(error);
      rethrow;
    }
  }

  Future<SafetyPatrolModel> rejectFeedback({
    required int feedbackId,
    required int patrolId,
    required int userId,
    required String comments,
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      SafetyPatrolModel result = await _safetyPatrolService.rejectFeedback(
        token: (await tokenRepository.getToken())!,
        feedbackId: feedbackId,
        comments: comments,
      );

      _managerialPatrols = _managerialPatrols.map((patrol) {
        if (patrol.id == patrolId) {
          return SafetyPatrolCardModel(
            id: patrol.id,
            type: patrol.type,
            location: patrol.location,
            description: patrol.description,
            status: result.status,
            createdAt: patrol.createdAt,
            userApprovalStatus: result.feedbacks
                    ?.firstWhere((f) => f.id == feedbackId)
                    .approvals
                    ?.firstWhere(
                      (approval) => approval.approverId == userId,
                      orElse: () => SafetyPatrolFeedbackApprovalModel(
                        id: 0,
                        feedbackId: feedbackId,
                        approverId: userId,
                        status: 'rejected',
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                    )
                    .status ??
                patrol.userApprovalStatus,
          );
        }
        return patrol;
      }).toList();

      _mySubmissions = _mySubmissions.map((patrol) {
        if (patrol.id == patrolId) return result;
        return patrol;
      }).toList();

      _myActions = _myActions.map((patrol) {
        if (patrol.id == patrolId) {
          return SafetyPatrolCardModel(
            id: patrol.id,
            type: patrol.type,
            location: patrol.location,
            description: patrol.description,
            status: result.status,
            createdAt: patrol.createdAt,
            deadline: patrol.deadline, // Preserve existing deadline
          );
        }
        return patrol;
      }).toList();

      notifyListeners();
      return result;
    } catch (error) {
      if (kDebugMode) log('Error rejecting feedback: $error');
      errorCallback?.call(error);
      rethrow;
    }
  }

  Future<SafetyPatrolModel> showSafetyPatrol({
    required int patrolId,
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      SafetyPatrolModel result = await _safetyPatrolService.showSafetyPatrol(
        token: (await tokenRepository.getToken())!,
        patrolId: patrolId,
      );

      return result;
    } catch (error) {
      if (kDebugMode) log('Error fetching safety patrol: $error');
      errorCallback?.call(error);
      rethrow;
    }
  }

  Future<void> getMySubmissions({
    required Function(String) errorCallback,
    String? status,
  }) async {
    try {
      final token = await tokenRepository.getToken();
      if (token == null) throw 'Tidak ada token';
      _mySubmissions = await _safetyPatrolService.getMySubmissions(
        token: token,
        status: status,
      );
      notifyListeners();
    } catch (e) {
      errorCallback(e.toString());
    }
  }

  Future<void> getMyActions({
    required Function(String) errorCallback,
    String? status,
  }) async {
    try {
      final token = await tokenRepository.getToken();
      if (token == null) throw 'Tidak ada token';
      _myActions = await _safetyPatrolService.getMyActions(
        token: token,
        status: status,
      );
      notifyListeners();
    } catch (e) {
      errorCallback(e.toString());
    }
  }

  Future<SafetyPatrolModel> submitFeedback({
    required int patrolId,
    required String feedbackDate,
    required String pathFile,
    required String description,
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      SafetyPatrolModel result = await _safetyPatrolService.submitFeedback(
        token: (await tokenRepository.getToken())!,
        patrolId: patrolId,
        feedbackDate: feedbackDate,
        pathFile: pathFile,
        description: description,
      );

      _myActions = _myActions.map((patrol) {
        if (patrol.id == result.id) {
          return SafetyPatrolCardModel(
            id: patrol.id,
            type: patrol.type,
            location: patrol.location,
            description: patrol.description,
            status: result.status,
            createdAt: patrol.createdAt,
            deadline: patrol.deadline, // Preserve existing deadline
          );
        }
        return patrol;
      }).toList();

      _mySubmissions = _mySubmissions.map((patrol) {
        if (patrol.id == result.id) return result;
        return patrol;
      }).toList();

      notifyListeners();
      return result;
    } on SocketException {
      errorCallback?.call("Terjadi Kesalahan Koneksi");
      rethrow;
    } catch (e) {
      errorCallback?.call(e);
      rethrow;
    }
  }

  void resetManagers() {
    _managers = [];
    notifyListeners();
  }
}
