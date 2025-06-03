import 'dart:convert';

class SafetyInductionAttemptModel {
  final int id;
  final int safetyInductionId;
  final int questionPackageId;
  final int score;
  final bool passed;
  final DateTime attemptDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  SafetyInductionAttemptModel({
    required this.id,
    required this.safetyInductionId,
    required this.questionPackageId,
    required this.score,
    required this.passed,
    required this.attemptDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SafetyInductionAttemptModel.fromRawJson(String str) =>
      SafetyInductionAttemptModel.fromJson(json.decode(str));

  factory SafetyInductionAttemptModel.fromJson(Map<String, dynamic> json) =>
      SafetyInductionAttemptModel(
        id: json["id"],
        safetyInductionId: json["safety_induction_id"] as int,
        questionPackageId: json["question_package_id"],
        score: json["score"],
        passed: json["passed"],
        attemptDate: DateTime.parse(json["attempt_date"]),
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "safety_induction_id": safetyInductionId,
        "question_package_id": questionPackageId,
        "score": score,
        "passed": passed,
        "attempt_date": attemptDate.toIso8601String(),
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
