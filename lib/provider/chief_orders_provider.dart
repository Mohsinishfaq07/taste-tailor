// ignore_for_file: file_names

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyOrders extends ChangeNotifier {
  List<DocumentSnapshot> _orders = [];

  List<DocumentSnapshot> get orders => _orders;

  void updateRequests(List<DocumentSnapshot> newOrders) {
    _orders = newOrders;
    notifyListeners();
  }

  Future<void> rejectRequest(String documentId) async {
    try {
      await FirebaseFirestore.instance.collection('accepted_requests').doc(documentId).delete();
      // Remove the rejected request from the local list
      _orders.removeWhere((request) => request.id == documentId);
      notifyListeners();
    } catch (error) {
      if (kDebugMode) {
        print('Error rejecting request: $error');
      }
    }
  }
}
