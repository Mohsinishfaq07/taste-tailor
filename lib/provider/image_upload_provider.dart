// import 'dart:io';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:image_picker/image_picker.dart';
//
// class ImageUploadProvider with ChangeNotifier {
//   String? _profileImageUrl;
//   List<String> _certificateImageUrls = [];
//   final ImagePicker _picker = ImagePicker();
//
//   String? get profileImageUrl => _profileImageUrl;
//   List<String> get certificateImageUrls => _certificateImageUrls;
//
//   Future<void> pickAndUploadProfileImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       _uploadImage(File(pickedFile.path), isProfileImage: true);
//     }
//   }
//
//   Future<void> pickAndUploadCertificateImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       _uploadImage(File(pickedFile.path), isProfileImage: false);
//     }
//   }
//
//   Future<void> _uploadImage(File imageFile, {required bool isProfileImage}) async {
//     String fileName = 'images/${DateTime.now().millisecondsSinceEpoch}.jpg';
//     Reference ref = FirebaseStorage.instance.ref().child(fileName);
//     UploadTask uploadTask = ref.putFile(imageFile);
//
//     try {
//       await uploadTask;
//       String imageUrl = await ref.getDownloadURL();
//       if (isProfileImage) {
//         _profileImageUrl = imageUrl;
//       } else {
//         _certificateImageUrls.add(imageUrl);
//       }
//       notifyListeners();
//     } catch (e) {
//       print("Error uploading image: $e");
//     }
//   }
// }
