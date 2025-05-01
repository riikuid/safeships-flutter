import 'dart:convert';

class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? fcmToken;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.fcmToken,
  });

  factory UserModel.fromRawJson(String str) =>
      UserModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
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
