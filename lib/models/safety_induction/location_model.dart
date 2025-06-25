import 'dart:convert';

class LocationModel {
  final int id;
  final String name;
  final String youtubeUrl;
  final String thumbnailUrl;

  LocationModel({
    required this.id,
    required this.name,
    required this.youtubeUrl,
    required this.thumbnailUrl,
  });

  factory LocationModel.fromRawJson(String str) =>
      LocationModel.fromJson(json.decode(str));

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
        id: json["id"],
        name: json["name"],
        youtubeUrl: json["youtube_url"],
        thumbnailUrl: json["thumbnail_url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "youtube_url": youtubeUrl,
        "thumbnail_url": thumbnailUrl,
      };
}
