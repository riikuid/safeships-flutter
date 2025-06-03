import 'dart:convert';

class QuestionPackageModel {
  final int id;
  final String name;
  // final String type;

  QuestionPackageModel({
    required this.id,
    required this.name,
    // required this.type,
  });

  factory QuestionPackageModel.fromRawJson(String str) =>
      QuestionPackageModel.fromJson(json.decode(str));

  factory QuestionPackageModel.fromJson(Map<String, dynamic> json) =>
      QuestionPackageModel(
        id: json["id"],
        name: json["name"],
        // type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        // "type": type,
      };
}
