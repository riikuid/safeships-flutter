import 'dart:convert';

import 'package:safeships_flutter/models/safety_patrol/safety_patrol_action_model.dart';
import 'package:safeships_flutter/models/safety_patrol/safety_patrol_approval_model.dart';
import 'package:safeships_flutter/models/safety_patrol/safety_patrol_feedback_model.dart';
import 'package:safeships_flutter/models/user_model.dart';

enum SafetyPatrolType { condition, unsafeAction }

enum SafetyPatrolStatus {
  pendingSuperAdmin,
  pendingManager,
  pendingAction,
  actionInProgress,
  pendingFeedbackApproval,
  done,
  rejected
}

class SafetyPatrolModel {
  final int id;
  final int userId;
  final int managerId;
  final DateTime reportDate;
  final String imagePath;
  final SafetyPatrolType type;
  final String description;
  final String location;
  final SafetyPatrolStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final UserModel? user;
  final UserModel? manager;
  final List<SafetyPatrolApprovalModel>? approvals;
  final SafetyPatrolActionModel? action;
  final List<SafetyPatrolFeedbackModel>? feedbacks;

  SafetyPatrolModel({
    required this.id,
    required this.userId,
    required this.managerId,
    required this.reportDate,
    required this.imagePath,
    required this.type,
    required this.description,
    required this.location,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.user,
    this.manager,
    this.approvals,
    this.action,
    this.feedbacks,
  });

  factory SafetyPatrolModel.fromRawJson(String str) =>
      SafetyPatrolModel.fromJson(json.decode(str));

  factory SafetyPatrolModel.fromJson(Map<String, dynamic> json) =>
      SafetyPatrolModel(
        id: json["id"],
        userId: json["user_id"],
        managerId: json["manager_id"],
        reportDate: DateTime.parse(json["report_date"]),
        imagePath: json["image_path"],
        type: SafetyPatrolType.values.firstWhere(
          (e) => e.toString().split('.').last == json["type"],
          orElse: () => SafetyPatrolType.condition,
        ),
        description: json["description"],
        location: json["location"],
        status: SafetyPatrolStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json["status"],
          orElse: () => SafetyPatrolStatus.pendingSuperAdmin,
        ),
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"] != null
            ? DateTime.parse(json["deleted_at"])
            : null,
        user: json["user"] != null ? UserModel.fromJson(json["user"]) : null,
        manager: json["manager"] != null
            ? UserModel.fromJson(json["manager"])
            : null,
        approvals: json["approvals"] != null
            ? List<SafetyPatrolApprovalModel>.from(json["approvals"]
                .map((x) => SafetyPatrolApprovalModel.fromJson(x)))
            : null,
        action: json["action"] != null
            ? SafetyPatrolActionModel.fromJson(json["action"])
            : null,
        feedbacks: json["feedbacks"] != null
            ? List<SafetyPatrolFeedbackModel>.from(json["feedbacks"]
                .map((x) => SafetyPatrolFeedbackModel.fromJson(x)))
            : null,
      );
}
