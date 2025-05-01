import 'dart:convert';

import 'package:safeships_flutter/models/category_model.dart';
import 'package:safeships_flutter/models/document_approval_model.dart';
import 'package:safeships_flutter/models/user_model.dart';

class DocumentModel {
  final int id;
  final int userId;
  final int categoryId;
  final int managerId;
  final String filePath;
  final String title;
  final String description;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel user;
  final CategoryModel category;
  final List<DocumentApprovalModel> documentApprovals;

  DocumentModel({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.managerId,
    required this.filePath,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.category,
    required this.documentApprovals,
  });

  factory DocumentModel.fromRawJson(String str) =>
      DocumentModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DocumentModel.fromJson(Map<String, dynamic> json) => DocumentModel(
        id: json["id"],
        userId: json["user_id"],
        categoryId: json["category_id"],
        managerId: json["manager_id"],
        filePath: json["file_path"],
        title: json["title"],
        description: json["description"],
        status: json["status"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        user: UserModel.fromJson(json["user"]),
        category: CategoryModel.fromJson(json["category"]),
        documentApprovals: List<DocumentApprovalModel>.from(
            json["document_approvals"]
                .map((x) => DocumentApprovalModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "category_id": categoryId,
        "manager_id": managerId,
        "file_path": filePath,
        "title": title,
        "description": description,
        "status": status,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "user": user.toJson(),
        "category": category.toJson(),
        "document_approvals":
            List<dynamic>.from(documentApprovals.map((x) => x.toJson())),
      };
}
