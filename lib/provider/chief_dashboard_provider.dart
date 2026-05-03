// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RequestData extends ChangeNotifier {
  List<QueryDocumentSnapshot> _requests = [];
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Defined here

  List<QueryDocumentSnapshot> get requests => _requests;

  String _fare = "";
  String get fare => _fare;
  void updateFare(String newRequests) {
    _fare = newRequests;
    notifyListeners();
  }

  void updaeRequests(List<QueryDocumentSnapshot> newRequests) {
    _requests = newRequests;
    notifyListeners();
  }

  // Future<void> rejectRequest(String documentId) async {
  //   try {
  //     await _firestore.collection('request_form').doc(documentId).delete(); // Use _firestore
  //     _requests.removeWhere((request) => request.id == documentId); // Update local data
  //     notifyListeners();
  //   } catch (error) {
  //     if (kDebugMode) {
  //       print('Error rejecting request: $error');
  //     }
  //   }
  // }

  // Method to handle acceptance
  Future<void> acceptRequest(BuildContext context, String documentId) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      await _firestore
          .collection('request_form')
          .doc(documentId)
          .update({'status': 'accepted'});

      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Request accepted");
    } catch (e) {
      Navigator.pop(context); // Close the loading indicator
      Fluttertoast.showToast(msg: "Failed to accept request: $e");
    }
  }

  // Method to handle rejection
  Future<void> rejectRequest(BuildContext context, String documentId) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      await _firestore
          .collection('request_form')
          .doc(documentId)
          .update({'status': 'rejected'});

      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Request rejected");
    } catch (e) {
      Navigator.pop(context); // Close the loading indicator
      Fluttertoast.showToast(msg: "Failed to reject request: $e");
    }
  }
}
