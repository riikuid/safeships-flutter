class InductionCardModel {
  final int id;
  final int userId;
  final String name;
  final String type;
  final String phoneNumber;
  final String email;
  final String status;
  final DateTime createdAt;

  InductionCardModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.phoneNumber,
    required this.email,
    required this.status,
    required this.createdAt,
  });

  factory InductionCardModel.fromJson(Map<String, dynamic> json) {
    return InductionCardModel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      type: json['type'],
      phoneNumber: json['phone_number'],
      status: json["status"],
      email: json['email'],
      createdAt: DateTime.parse(json["created_at"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type,
      'phone_number': phoneNumber,
      'email': email,
    };
  }
}
