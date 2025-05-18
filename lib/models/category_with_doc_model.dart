import 'dart:convert';

class CategoryWithDocModel {
  final int id;
  final String name;
  final String code;
  final List<DocModel> items;

  CategoryWithDocModel({
    required this.id,
    required this.name,
    required this.code,
    required this.items,
  });

  factory CategoryWithDocModel.fromRawJson(String str) =>
      CategoryWithDocModel.fromJson(json.decode(str));

  factory CategoryWithDocModel.fromJson(Map<String, dynamic> json) {
    return CategoryWithDocModel(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as String,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => DocModel.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class DocModel {
  final int id;
  final String title;
  final String description;
  final String filePath;
  final DateTime updatedAt;

  DocModel({
    required this.id,
    required this.title,
    required this.description,
    required this.filePath,
    required this.updatedAt,
  });

  factory DocModel.fromRawJson(String str) =>
      DocModel.fromJson(json.decode(str));

  factory DocModel.fromJson(Map<String, dynamic> json) => DocModel(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        filePath: json["file_path"],
        updatedAt: DateTime.parse(json["updated_at"]),
      );
}
