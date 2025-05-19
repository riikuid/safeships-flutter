import 'dart:convert';

import 'package:safeships_flutter/models/user_model.dart';

enum ApprovalStatus { pending, approved, rejected }

class SafetyPatrolApprovalModel {
  final int id;
  final int safetyPatrolId;
  final int approverId;
  final ApprovalStatus status;
  final String? comments;
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel? approver;

  SafetyPatrolApprovalModel({
    required this.id,
    required this.safetyPatrolId,
    required this.approverId,
    required this.status,
    this.comments,
    this.approvedAt,
    required this.createdAt,
    required this.updatedAt,
    this.approver,
  });

  factory SafetyPatrolApprovalModel.fromRawJson(String str) =>
      SafetyPatrolApprovalModel.fromJson(json.decode(str));

  factory SafetyPatrolApprovalModel.fromJson(Map<String, dynamic> json) =>
      SafetyPatrolApprovalModel(
        id: json["id"],
        safetyPatrolId: json["safety_patrol_id"],
        approverId: json["approver_id"],
        status: ApprovalStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json["status"],
          orElse: () => ApprovalStatus.pending,
        ),
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
