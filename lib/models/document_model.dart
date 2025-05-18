import 'dart:convert';

import 'package:safeships_flutter/models/category_model.dart';
import 'package:safeships_flutter/models/document_approval_model.dart';
import 'package:safeships_flutter/models/auth_model.dart';

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
  final DateTime? deletedAt;
  final AuthModel? user;
  final CategoryModel category;
  final List<DocumentApprovalModel>? documentApprovals;

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
    this.deletedAt,
    this.user,
    required this.category,
    this.documentApprovals,
  });

  factory DocumentModel.fromRawJson(String str) =>
      DocumentModel.fromJson(json.decode(str));

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
        deletedAt: json["deleted_at"] != null
            ? DateTime.parse(json["deleted_at"])
            : null,
        user: json["user"] != null ? AuthModel.fromJson(json["user"]) : null,
        category: CategoryModel.fromJson(json["category"]),
        documentApprovals: List<DocumentApprovalModel>.from(
            json["document_approvals"]
                .map((x) => DocumentApprovalModel.fromJson(x))),
      );
}
