class SafetyPatrolCardModel {
  final int id;
  final String type;
  final String location;
  final String description;
  final String status;
  final DateTime createdAt;
  final String? userApprovalStatus; // Optional, used for managerial endpoint
  final DateTime? deadline; // Optional, used for my-actions endpoint

  SafetyPatrolCardModel({
    required this.id,
    required this.type,
    required this.location,
    required this.description,
    required this.status,
    required this.createdAt,
    this.userApprovalStatus,
    this.deadline,
  });

  factory SafetyPatrolCardModel.fromJson(Map<String, dynamic> json) {
    return SafetyPatrolCardModel(
      id: json['id'],
      type: json['type'],
      location: json['location'],
      description: json['description'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      userApprovalStatus: json['user_approval_status'],
      deadline:
          json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'location': location,
      'description': description,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      if (userApprovalStatus != null)
        'user_approval_status': userApprovalStatus,
      if (deadline != null) 'deadline': deadline,
    };
  }
}
