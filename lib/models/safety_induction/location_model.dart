import 'dart:convert';

class LocationModel {
  final int id;
  final String name;
  final String youtubeUrl;

  LocationModel({
    required this.id,
    required this.name,
    required this.youtubeUrl,
  });

  factory LocationModel.fromRawJson(String str) =>
      LocationModel.fromJson(json.decode(str));

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
        id: json["id"],
        name: json["name"],
        youtubeUrl: json["youtube_url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "youtube_url": youtubeUrl,
      };
}
