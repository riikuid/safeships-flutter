import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:safeships_flutter/common/token_repository.dart';
import 'package:safeships_flutter/models/manager_model.dart';
import 'package:safeships_flutter/models/safety_patrol/safety_patrol_approval_model.dart';
import 'package:safeships_flutter/models/safety_patrol/safety_patrol_feedback_model.dart';
import 'package:safeships_flutter/models/safety_patrol/safety_patrol_model.dart';
import 'package:safeships_flutter/models/user_model.dart';
import 'package:safeships_flutter/services/safety_patrol_service.dart';

class SafetyPatrolProvider with ChangeNotifier {
  final TokenRepository tokenRepository = TokenRepository();
  final SafetyPatrolService _safetyPatrolService = SafetyPatrolService();

  List<ManagerModel> _managers = [];
  List<ManagerModel> get managers => _managers;

  List<SafetyPatrolModel> _managerialPatrols = [];
  List<SafetyPatrolModel> get managerialPatrols => _managerialPatrols;

  List<SafetyPatrolModel> _mySubmissions = [];
  List<SafetyPatrolModel> get mySubmissions => _mySubmissions;

  List<SafetyPatrolModel> _myActions = [];
  List<SafetyPatrolModel> get myActions => _myActions;

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

  Future<bool> submitSafetyPatrol({
    required String managerId,
    required String reportDate,
    required String pathFile,
    required String type,
    required String description,
    required String location,
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      bool result = await _safetyPatrolService.submitSafetyPatrol(
        token: (await tokenRepository.getToken())!,
        managerId: managerId,
        reportDate: reportDate,
        pathFile: pathFile,
        type: type,
        description: description,
        location: location,
      );

      notifyListeners();
      return result;
    } on SocketException {
      errorCallback?.call("Terjadi Kesalahan Koneksi");
      return false;
    } catch (e) {
      errorCallback?.call(e);
      return false;
    }
  }

  Future<void> getManagerial({
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      List<SafetyPatrolModel> result = await _safetyPatrolService.getManagerial(
        token: (await tokenRepository.getToken())!,
      );

      _managerialPatrols = result;
      notifyListeners();
    } catch (error) {
      if (kDebugMode) log('Error fetching managerial patrols: $error');
      errorCallback?.call(error);
    }
  }

  Future<bool> approveSafetyPatrol({
    required int patrolId,
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
          return result;
        }
        return patrol;
      }).toList();

      _mySubmissions = _mySubmissions.map((patrol) {
        if (patrol.id == result.id) {
          return result;
        }
        return patrol;
      }).toList();

      notifyListeners();
      return true;
    } catch (error) {
      if (kDebugMode) log('Error approving safety patrol: $error');
      errorCallback?.call(error);
      return false;
    }
  }

  Future<bool> rejectSafetyPatrol({
    required int patrolId,
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
          return result;
        }
        return patrol;
      }).toList();

      _mySubmissions = _mySubmissions.map((patrol) {
        if (patrol.id == result.id) {
          return result;
        }
        return patrol;
      }).toList();

      notifyListeners();
      return true;
    } catch (error) {
      if (kDebugMode) log('Error rejecting safety patrol: $error');
      errorCallback?.call(error);
      return false;
    }
  }

  Future<bool> approveFeedback({
    required int feedbackId,
    required int patrolId,
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      SafetyPatrolFeedbackModel result =
          await _safetyPatrolService.approveFeedback(
        token: (await tokenRepository.getToken())!,
        feedbackId: feedbackId,
      );

      _managerialPatrols = _managerialPatrols.map((patrol) {
        if (patrol.id == patrolId) {
          return SafetyPatrolModel(
            id: patrol.id,
            userId: patrol.userId,
            managerId: patrol.managerId,
            reportDate: patrol.reportDate,
            imagePath: patrol.imagePath,
            type: patrol.type,
            description: patrol.description,
            location: patrol.location,
            status: result.status == ApprovalStatus.approved
                ? SafetyPatrolStatus.done
                : patrol.status,
            createdAt: patrol.createdAt,
            updatedAt: patrol.updatedAt,
            deletedAt: patrol.deletedAt,
            user: patrol.user,
            manager: patrol.manager,
            approvals: patrol.approvals,
            action: patrol.action,
            feedbacks: patrol.feedbacks
                ?.map((f) => f.id == feedbackId ? result : f)
                .toList(),
          );
        }
        return patrol;
      }).toList();

      _mySubmissions = _mySubmissions.map((patrol) {
        if (patrol.id == patrolId) {
          return SafetyPatrolModel(
            id: patrol.id,
            userId: patrol.userId,
            managerId: patrol.managerId,
            reportDate: patrol.reportDate,
            imagePath: patrol.imagePath,
            type: patrol.type,
            description: patrol.description,
            location: patrol.location,
            status: result.status == ApprovalStatus.approved
                ? SafetyPatrolStatus.done
                : patrol.status,
            createdAt: patrol.createdAt,
            updatedAt: patrol.updatedAt,
            deletedAt: patrol.deletedAt,
            user: patrol.user,
            manager: patrol.manager,
            approvals: patrol.approvals,
            action: patrol.action,
            feedbacks: patrol.feedbacks
                ?.map((f) => f.id == feedbackId ? result : f)
                .toList(),
          );
        }
        return patrol;
      }).toList();

      _myActions = _myActions.map((patrol) {
        if (patrol.id == patrolId) {
          return SafetyPatrolModel(
            id: patrol.id,
            userId: patrol.userId,
            managerId: patrol.managerId,
            reportDate: patrol.reportDate,
            imagePath: patrol.imagePath,
            type: patrol.type,
            description: patrol.description,
            location: patrol.location,
            status: result.status == ApprovalStatus.approved
                ? SafetyPatrolStatus.done
                : patrol.status,
            createdAt: patrol.createdAt,
            updatedAt: patrol.updatedAt,
            deletedAt: patrol.deletedAt,
            user: patrol.user,
            manager: patrol.manager,
            approvals: patrol.approvals,
            action: patrol.action,
            feedbacks: patrol.feedbacks
                ?.map((f) => f.id == feedbackId ? result : f)
                .toList(),
          );
        }
        return patrol;
      }).toList();

      notifyListeners();
      return true;
    } catch (error) {
      if (kDebugMode) log('Error approving feedback: $error');
      errorCallback?.call(error);
      return false;
    }
  }

  Future<bool> rejectFeedback({
    required int feedbackId,
    required int patrolId,
    required String comments,
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      SafetyPatrolFeedbackModel result =
          await _safetyPatrolService.rejectFeedback(
        token: (await tokenRepository.getToken())!,
        feedbackId: feedbackId,
        comments: comments,
      );

      _managerialPatrols = _managerialPatrols.map((patrol) {
        if (patrol.id == patrolId) {
          return SafetyPatrolModel(
            id: patrol.id,
            userId: patrol.userId,
            managerId: patrol.managerId,
            reportDate: patrol.reportDate,
            imagePath: patrol.imagePath,
            type: patrol.type,
            description: patrol.description,
            location: patrol.location,
            status: SafetyPatrolStatus.pendingAction,
            createdAt: patrol.createdAt,
            updatedAt: patrol.updatedAt,
            deletedAt: patrol.deletedAt,
            user: patrol.user,
            manager: patrol.manager,
            approvals: patrol.approvals,
            action: patrol.action,
            feedbacks: patrol.feedbacks
                ?.map((f) => f.id == feedbackId ? result : f)
                .toList(),
          );
        }
        return patrol;
      }).toList();

      _mySubmissions = _mySubmissions.map((patrol) {
        if (patrol.id == patrolId) {
          return SafetyPatrolModel(
            id: patrol.id,
            userId: patrol.userId,
            managerId: patrol.managerId,
            reportDate: patrol.reportDate,
            imagePath: patrol.imagePath,
            type: patrol.type,
            description: patrol.description,
            location: patrol.location,
            status: SafetyPatrolStatus.pendingAction,
            createdAt: patrol.createdAt,
            updatedAt: patrol.updatedAt,
            deletedAt: patrol.deletedAt,
            user: patrol.user,
            manager: patrol.manager,
            approvals: patrol.approvals,
            action: patrol.action,
            feedbacks: patrol.feedbacks
                ?.map((f) => f.id == feedbackId ? result : f)
                .toList(),
          );
        }
        return patrol;
      }).toList();

      _myActions = _myActions.map((patrol) {
        if (patrol.id == patrolId) {
          return SafetyPatrolModel(
            id: patrol.id,
            userId: patrol.userId,
            managerId: patrol.managerId,
            reportDate: patrol.reportDate,
            imagePath: patrol.imagePath,
            type: patrol.type,
            description: patrol.description,
            location: patrol.location,
            status: SafetyPatrolStatus.pendingAction,
            createdAt: patrol.createdAt,
            updatedAt: patrol.updatedAt,
            deletedAt: patrol.deletedAt,
            user: patrol.user,
            manager: patrol.manager,
            approvals: patrol.approvals,
            action: patrol.action,
            feedbacks: patrol.feedbacks
                ?.map((f) => f.id == feedbackId ? result : f)
                .toList(),
          );
        }
        return patrol;
      }).toList();

      notifyListeners();
      return true;
    } catch (error) {
      if (kDebugMode) log('Error rejecting feedback: $error');
      errorCallback?.call(error);
      return false;
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
  }) async {
    try {
      final token = await tokenRepository.getToken();
      if (token == null) throw 'No token found';
      _mySubmissions = await _safetyPatrolService.getMySubmissions(
        token: token,
      );
      notifyListeners();
    } catch (e) {
      errorCallback(e.toString());
    }
  }

  Future<void> getMyActions({
    required Function(String) errorCallback,
  }) async {
    try {
      final token = await tokenRepository.getToken();
      if (token == null) throw 'No token found';
      _myActions = await _safetyPatrolService.getMyActions(
        token: token,
      );
      notifyListeners();
    } catch (e) {
      errorCallback(e.toString());
    }
  }

  Future<bool> submitFeedback({
    required int patrolId,
    required String feedbackDate,
    required String pathFile,
    required String description,
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      bool result = await _safetyPatrolService.submitFeedback(
        token: (await tokenRepository.getToken())!,
        patrolId: patrolId,
        feedbackDate: feedbackDate,
        pathFile: pathFile,
        description: description,
      );

      notifyListeners();
      return result;
    } on SocketException {
      errorCallback?.call("Terjadi Kesalahan Koneksi");
      return false;
    } catch (e) {
      errorCallback?.call(e);
      return false;
    }
  }

  void resetManagers() {
    _managers = [];
    notifyListeners();
  }
}
