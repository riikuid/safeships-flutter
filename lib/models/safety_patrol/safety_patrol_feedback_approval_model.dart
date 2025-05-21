import 'dart:convert';

import 'package:safeships_flutter/models/user_model.dart';

class SafetyPatrolFeedbackApprovalModel {
  final int id;
  final int feedbackId;
  final int approverId;
  final String status;
  final String? comments;
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel? approver;

  SafetyPatrolFeedbackApprovalModel({
    required this.id,
    required this.feedbackId,
    required this.approverId,
    required this.status,
    this.comments,
    this.approvedAt,
    required this.createdAt,
    required this.updatedAt,
    this.approver,
  });

  factory SafetyPatrolFeedbackApprovalModel.fromRawJson(String str) =>
      SafetyPatrolFeedbackApprovalModel.fromJson(json.decode(str));

  factory SafetyPatrolFeedbackApprovalModel.fromJson(
          Map<String, dynamic> json) =>
      SafetyPatrolFeedbackApprovalModel(
        id: json["id"],
        feedbackId: json["feedback_id"],
        approverId: json["approver_id"],
        status: json["status"] ?? "pending",
        comments: json["comments"],
        approvedAt: json["approved_at"] != null
            ? DateTime.parse(json["approved_at"])
            : null,
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        approver: json["approver"] != null
            ? UserModel.fromJson(json["approver"])
            : null,
      );
}
