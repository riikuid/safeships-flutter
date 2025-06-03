import 'dart:convert';

class QuestionModel {
  final int id;
  // final int questionPackageId;
  final String text;
  final Map<String, String> options;
  // final DateTime createdAt;
  // final DateTime updatedAt;

  QuestionModel({
    required this.id,
    // required this.questionPackageId,
    required this.text,
    required this.options,
    // required this.createdAt,
    // required this.updatedAt,
  });

  factory QuestionModel.fromRawJson(String str) =>
      QuestionModel.fromJson(json.decode(str));

  factory QuestionModel.fromJson(Map<String, dynamic> json) => QuestionModel(
        id: json["id"],
        // questionPackageId: json["question_package_id"],
        text: json["text"],
        options: Map<String, String>.from(json["options"]),
        // createdAt: DateTime.parse(json["created_at"]),
        // updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        // "question_package_id": questionPackageId,
        "text": text,
        "options": options,
        // "created_at": createdAt.toIso8601String(),
        // "updated_at": updatedAt.toIso8601String(),
      };
}
