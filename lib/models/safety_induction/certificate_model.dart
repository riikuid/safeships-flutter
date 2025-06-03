import 'dart:convert';

class CertificateModel {
  final int id;
  final int userId;
  final int safetyInductionId;
  final DateTime issuedDate;
  final DateTime expiredDate;
  final String url;
  final DateTime createdAt;
  final DateTime updatedAt;

  CertificateModel({
    required this.id,
    required this.userId,
    required this.safetyInductionId,
    required this.issuedDate,
    required this.expiredDate,
    required this.url,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CertificateModel.fromRawJson(String str) =>
      CertificateModel.fromJson(json.decode(str));

  factory CertificateModel.fromJson(Map<String, dynamic> json) =>
      CertificateModel(
        id: json["id"],
        userId: json["user_id"],
        safetyInductionId: json["safety_induction_id"],
        issuedDate: DateTime.parse(json["issued_date"]),
        expiredDate: DateTime.parse(json["expired_date"]),
        url: json["url"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "safety_induction_id": safetyInductionId,
        "issued_date": issuedDate.toIso8601String(),
        "expired_date": expiredDate.toIso8601String(),
        "url": url,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
