import 'dart:convert';

class AuthModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? fcmToken;

  AuthModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.fcmToken,
  });

  factory AuthModel.fromRawJson(String str) =>
      AuthModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AuthModel.fromJson(Map<String, dynamic> json) => AuthModel(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        role: json["role"],
        fcmToken: json["fcm_token"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "role": role,
        "fcm_token": fcmToken,
      };
}
