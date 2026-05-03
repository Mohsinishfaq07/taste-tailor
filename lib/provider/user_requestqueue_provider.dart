// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UserRequestQueueProvider extends ChangeNotifier {
  List<DocumentSnapshot> _requests = [];

  List<DocumentSnapshot> get requests => _requests;


  void updateRequests(List<DocumentSnapshot> newRequests) {
    _requests = newRequests;
    notifyListeners();
  }

  Future<void> rejectRequest(String documentId) async {
    try {
      await FirebaseFirestore.instance.collection('requests').doc(documentId).delete();
      _requests.removeWhere((request) => request.id == documentId);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error rejecting request: $error');
      }
    }
  }

  // Implementing the acceptRequest method
  Future<void> acceptRequest(BuildContext context, String documentId) async {
    try {
      await FirebaseFirestore.instance.collection('requests').doc(documentId).update({
        'status': 'accepted'
      });
      notifyListeners();  // Notify listeners to refresh the UI
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Request accepted"),
        duration: Duration(seconds: 2),
      ));
    } catch (error) {
      if (kDebugMode) {
        print('Error accepting request: $error');
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Failed to accept request"),
        duration: Duration(seconds: 2),
      ));
    }
  }


  Future<void> deleteRequest(String documentId) async {
    try {
      await FirebaseFirestore.instance.collection('new_requestform').doc(documentId).delete();
      // Optionally remove the request from the local list and notify listeners
      _requests.removeWhere((request) => request.id == documentId);
      notifyListeners();
      Fluttertoast.showToast(msg: 'Request successfully deleted');
    } catch (error) {
      Fluttertoast.showToast(msg: 'Error deleting request: $error');
      if (kDebugMode) {
        print('Error deleting request: $error');
      }
    }
  }
}
