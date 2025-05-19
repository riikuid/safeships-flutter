import 'dart:convert';

import 'package:safeships_flutter/models/safety_patrol/safety_patrol_approval_model.dart';
import 'package:safeships_flutter/models/safety_patrol/safety_patrol_feedback_approval_model.dart';
import 'package:safeships_flutter/models/user_model.dart';

class SafetyPatrolFeedbackModel {
  final int id;
  final int safetyPatrolId;
  final int actorId;
  final DateTime feedbackDate;
  final String imagePath;
  final String description;
  final ApprovalStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final UserModel? actor;
  final List<SafetyPatrolFeedbackApprovalModel>? approvals;

  SafetyPatrolFeedbackModel({
    required this.id,
    required this.safetyPatrolId,
    required this.actorId,
    required this.feedbackDate,
    required this.imagePath,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.actor,
    this.approvals,
  });

  factory SafetyPatrolFeedbackModel.fromRawJson(String str) =>
      SafetyPatrolFeedbackModel.fromJson(json.decode(str));

  factory SafetyPatrolFeedbackModel.fromJson(Map<String, dynamic> json) =>
      SafetyPatrolFeedbackModel(
        id: json["id"],
        safetyPatrolId: json["safety_patrol_id"],
        actorId: json["actor_id"],
        feedbackDate: DateTime.parse(json["feedback_date"]),
        imagePath: json["image_path"],
        description: json["description"],
        status: ApprovalStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json["status"],
          orElse: () => ApprovalStatus.pending,
        ),
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"] != null
            ? DateTime.parse(json["deleted_at"])
            : null,
        actor: json["actor"] != null ? UserModel.fromJson(json["actor"]) : null,
        approvals: json["approvals"] != null
            ? List<SafetyPatrolFeedbackApprovalModel>.from(json["approvals"]
                .map((x) => SafetyPatrolFeedbackApprovalModel.fromJson(x)))
            : null,
      );
}
