import 'dart:convert';

import 'package:safeships_flutter/models/user_model.dart';

class SafetyPatrolActionModel {
  final int id;
  final int safetyPatrolId;
  final int actorId;
  final DateTime deadline;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel? actor;

  SafetyPatrolActionModel({
    required this.id,
    required this.safetyPatrolId,
    required this.actorId,
    required this.deadline,
    required this.createdAt,
    required this.updatedAt,
    this.actor,
  });

  factory SafetyPatrolActionModel.fromRawJson(String str) =>
      SafetyPatrolActionModel.fromJson(json.decode(str));

  factory SafetyPatrolActionModel.fromJson(Map<String, dynamic> json) =>
      SafetyPatrolActionModel(
        id: json["id"],
        safetyPatrolId: json["safety_patrol_id"],
        actorId: json["actor_id"],
        deadline: DateTime.parse(json["deadline"]),
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        actor: json["actor"] != null ? UserModel.fromJson(json["actor"]) : null,
      );
}
