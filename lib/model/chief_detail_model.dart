import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp

import '../utils/chef_city_extractor.dart';

class ChiefDetailModel {
  final String city;
  final String address;
  final String certificateImage;
  final String certifications;
  final String email;
  final String name;
  final String number;
  final String password;
  final String rating;
  final String specialties;
  final String workExperience;
  final String userId;
  final String image;
  final String role;
  final Timestamp timestamp;

  ChiefDetailModel({
    this.city = '',
    required this.address,
    required this.certificateImage,
    required this.certifications,
    required this.email,
    required this.name,
    required this.number,
    required this.password,
    required this.rating,
    required this.specialties,
    required this.workExperience,
    required this.userId,
    required this.image,
    required this.role,
    required this.timestamp,
  });

  factory ChiefDetailModel.fromJson(Map<String, dynamic> json) {
    final dynamic ts = json['timestamp'];
    var specialties = '';
    for (final key in ['specialties', 'speciality', 'specialities']) {
      final v = json[key];
      if (v != null && v.toString().trim().isNotEmpty) {
        specialties = v.toString();
        break;
      }
    }
    var workExperience = '';
    for (final key in ['workExperience', 'experience', 'workExperienceYears']) {
      final v = json[key];
      if (v != null && v.toString().trim().isNotEmpty) {
        workExperience = v.toString();
        break;
      }
    }
    return ChiefDetailModel(
      city: json['city']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      certificateImage: (json['certificateImage'] ?? json['certificateUrl'])
              ?.toString() ??
          '',
      certifications: json['certifications']?.toString() ?? '',
      email: (json['email'] ?? json['Email'])?.toString() ?? '',
      name: (json['name'] ?? json['Name'])?.toString() ?? '',
      number: json['number']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      rating: json['rating']?.toString() ?? '0',
      specialties: specialties,
      workExperience: workExperience,
      userId:
          (json['userId'] ?? json['id'] ?? json['uid'])?.toString() ?? '',
      image: (json['image'] ?? json['profileImage'])?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      timestamp: ts is Timestamp ? ts : Timestamp.now(),
    );
  }

  /// Firestore `city`, or inferred from [address] for older documents.
  String get effectiveCityDisplay =>
      city.trim().isNotEmpty ? city.trim() : ChefCityExtractor.fromAddress(address);

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'address': address,
      'certificateImage': certificateImage,
      'certifications': certifications,
      'email': email,
      'name': name,
      'number': number,
      'password': password,
      'rating': rating,
      'specialties': specialties,
      'workExperience': workExperience,
      'userId': userId,
      'image': image,
      'role': role,
      'timestamp': timestamp,
    };
  }
}
