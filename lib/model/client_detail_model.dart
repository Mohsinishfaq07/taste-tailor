import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp

class ClientDetailModel {
  final String address;
  final String email;
  final String name;
  final String number;
  final String password;
  final String userId;
  final String image;
  final String role;
  final Timestamp timestamp;

  ClientDetailModel({
    required this.address,
    required this.email,
    required this.name,
    required this.number,
    required this.password,
    required this.userId,
    required this.image,
    required this.role,
    required this.timestamp,
  });

  factory ClientDetailModel.fromJson(Map<String, dynamic> json) {
    final dynamic ts = json['timestamp'];
    return ClientDetailModel(
      address: json['address']?.toString() ?? '',
      email: (json['email'] ?? json['Email'])?.toString() ?? '',
      name: (json['name'] ?? json['Name'])?.toString() ?? '',
      number: json['number']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      userId: (json['userId'] ?? json['id'])?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      timestamp: ts is Timestamp ? ts : Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'email': email,
      'name': name,
      'number': number,
      'password': password,
      'userId': userId,
      'image': image,
      'role': role,
      'timestamp': timestamp,
    };
  }
}
