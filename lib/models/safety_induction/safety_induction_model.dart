import 'dart:convert';

import 'package:safeships_flutter/models/safety_induction/certificate_model.dart';
import 'package:safeships_flutter/models/safety_induction/safety_induction_attempt_model.dart';

class SafetyInductionModel {
  final int id;
  final int userId;
  final String name;
  final String type;
  final String? address;
  final String? phoneNumber;
  final String? email;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<SafetyInductionAttemptModel>? attempts;
  final CertificateModel? certificate;

  SafetyInductionModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    this.address,
    this.phoneNumber,
    this.email,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.attempts,
    this.certificate,
  });

  factory SafetyInductionModel.fromRawJson(String str) =>
      SafetyInductionModel.fromJson(json.decode(str));

  factory SafetyInductionModel.fromJson(Map<String, dynamic> json) =>
      SafetyInductionModel(
        id: json["id"],
        userId: json["user_id"],
        name: json["name"],
        type: json["type"],
        address: json["address"],
        phoneNumber: json["phone_number"],
        email: json["email"],
        status: json["status"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        attempts: json["attempts"] != null
            ? List<SafetyInductionAttemptModel>.from(json["attempts"]
                .map((x) => SafetyInductionAttemptModel.fromJson(x)))
            : null,
        certificate: json["certificate"] != null
            ? CertificateModel.fromJson(json["certificate"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "name": name,
        "type": type,
        "address": address,
        "phone_number": phoneNumber,
        "email": email,
        "status": status,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "attempts": attempts?.map((x) => x.toJson()).toList(),
        "certificate": certificate?.toJson(),
      };
}
