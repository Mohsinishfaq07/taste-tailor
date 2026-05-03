// ignore_for_file: file_names

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserMyRequsets extends ChangeNotifier {
  List<DocumentSnapshot> _myrequests = [];

  List<DocumentSnapshot> get requests => _myrequests;

  void updateRequests(List<DocumentSnapshot> newOrders) {
    _myrequests = newOrders;
    notifyListeners();
  }

  Future<void> rejectRequest(String documentId) async {
    try {
      await FirebaseFirestore.instance.collection('request_form').doc(documentId).delete();
      // Remove the rejected request from the local list
      _myrequests.removeWhere((request) => request.id == documentId);
      notifyListeners();
    } catch (error) {
      if (kDebugMode) {
        print('Error rejecting request: $error');
      }
    }
  }
}
