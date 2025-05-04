import 'dart:convert';

class CategoryModel {
  final int id;
  final String name;
  final String code;
  final int? parentId;
  final List<CategoryModel>? children;

  CategoryModel({
    required this.id,
    required this.name,
    required this.code,
    this.parentId,
    this.children,
  });

  factory CategoryModel.fromRawJson(String str) =>
      CategoryModel.fromJson(json.decode(str));

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json["id"],
        name: json["name"],
        code: json["code"],
        parentId: json["parent_id"],
        children: json["children"] != null
            ? List<CategoryModel>.from(
                json["children"].map((x) => CategoryModel.fromJson(x)))
            : [],
      );
}
