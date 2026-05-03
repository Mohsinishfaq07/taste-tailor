import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp

class RequestModel {
  final String itemName;
  final String date;
  final String arrivalTime;
  final String eventTime;
  final String totalPerson;
  final String fare;
  final String ingredients;
  final String clientId;
  final List<Map<String, dynamic>> chefResponses; // Array of maps
  final String acceptedChiefId;
  /// If set, only this chef should see the open request on their dashboard.
  /// [acceptedChiefId] stays `noChiefSelected` until the client accepts an offer.
  final String preferredChiefId;
  final String preferredChefName;
  final Timestamp timestamp; // Added Timestamp field
  final String orderStatus; // Added orderStatus field

  RequestModel({
    required this.itemName,
    required this.date,
    required this.arrivalTime,
    required this.eventTime,
    required this.totalPerson,
    required this.fare,
    required this.ingredients,
    required this.clientId,
    required this.chefResponses,
    required this.acceptedChiefId,
    this.preferredChiefId = '',
    this.preferredChefName = '',
    required this.timestamp, // Initialize timestamp
    required this.orderStatus, // Initialize order status
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      itemName: json['itemName'],
      date: json['date'],
      arrivalTime: json['arrivalTime'],
      eventTime: json['eventTime'],
      totalPerson: json['totalPerson'],
      fare: json['fare'],
      ingredients: json['ingredients'],
      clientId: json['clientId'],
      chefResponses: List<Map<String, dynamic>>.from(
        json['chefResponses'] ?? [],
      ),
      acceptedChiefId: json['acceptedChiefId'] ?? 'noChiefSelected',
      preferredChiefId: json['preferredChiefId']?.toString() ?? '',
      preferredChefName: json['preferredChefName']?.toString() ?? '',
      timestamp: json['timestamp'] ?? Timestamp.now(), // Ensure default value
      orderStatus: json['orderStatus'] ?? 'Pending', // Default order status
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemName': itemName,
      'date': date,
      'arrivalTime': arrivalTime,
      'eventTime': eventTime,
      'totalPerson': totalPerson,
      'fare': fare,
      'ingredients': ingredients,
      'clientId': clientId,
      'chefResponses': chefResponses,
      'acceptedChiefId': acceptedChiefId,
      'preferredChiefId': preferredChiefId,
      'preferredChefName': preferredChefName,
      'timestamp': timestamp,
      'orderStatus': orderStatus,
    };
  }
}
