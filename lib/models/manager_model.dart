import 'package:meta/meta.dart';
import 'dart:convert';

class ManagerModel {
  final int id;
  final String name;
  final String email;

  ManagerModel({
    required this.id,
    required this.name,
    required this.email,
  });

  factory ManagerModel.fromRawJson(String str) =>
      ManagerModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ManagerModel.fromJson(Map<String, dynamic> json) => ManagerModel(
        id: json["id"],
        name: json["name"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
      };
}
