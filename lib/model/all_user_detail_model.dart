import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp

class AllUserDetailModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final Timestamp timestamp;

  AllUserDetailModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.timestamp,
  });

  factory AllUserDetailModel.fromJson(Map<String, dynamic> json) {
    final dynamic ts = json['timestamp'];
    return AllUserDetailModel(
      id: (json['id'] ?? json['userId'])?.toString() ?? '',
      name: (json['name'] ?? json['Name'])?.toString() ?? '',
      email: (json['email'] ?? json['Email'])?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      timestamp: ts is Timestamp ? ts : Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'timestamp': timestamp,
    };
  }
}
