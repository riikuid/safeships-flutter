import 'dart:convert';

import 'package:safeships_flutter/models/user_model.dart';

class DocumentApprovalModel {
  final int id;
  final int documentId;
  final int approverId;
  final String status;
  final String? comments;
  final UserModel approver;

  DocumentApprovalModel({
    required this.id,
    required this.documentId,
    required this.approverId,
    required this.status,
    this.comments,
    required this.approver,
  });

  factory DocumentApprovalModel.fromRawJson(String str) =>
      DocumentApprovalModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DocumentApprovalModel.fromJson(Map<String, dynamic> json) =>
      DocumentApprovalModel(
        id: json["id"],
        documentId: json["document_id"],
        approverId: json["approver_id"],
        status: json["status"],
        comments: json["comments"],
        approver: UserModel.fromJson(json["approver"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "document_id": documentId,
        "approver_id": approverId,
        "status": status,
        "comments": comments,
        "approver": approver.toJson(),
      };
}
