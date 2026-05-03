// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:taste_tailor/view/rating_screens/rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:googleapis_auth/auth_io.dart';
import '../../global_custom_widgets/custom_app_bar.dart';
import '../../global_custom_widgets/custom_large_button.dart';

class RatingScreen extends StatefulWidget {
  final String? chefId; // Chef ID is required to construct this widget

  const RatingScreen({Key? key, this.chefId}) : super(key: key);

  static const String tag = '/RatingScreen';

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  double _rating = 0.0; // Variable to hold the rating value
  final TextEditingController _reviewController =
      TextEditingController(); // Controller for the review input field

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<bool> _isUserLoggedIn() async {
    return FirebaseAuth.instance.currentUser != null;
  }

  Future<void> sendNotification(
      String fcmToken, String title, String body) async {
    final accountCredentials = ServiceAccountCredentials.fromJson({
      // Replace these fields with your actual service account credentials
      "type": "service_account",
      "project_id": "chief-24f12",
      "private_key_id": "ba82fda03876df719b3a7ff1d6a8a0ab2cebae75",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCnYdjVz+NpHnJp\nzSBJfFPSdm1HpIRSAQp1gCEwQ0gBqA7hX/zZ/eeXl9+j7q4PmZPGiA2ZczFOX7+k\nWFnf95tZMxBQzdJ78hYHcxJ2+gUZE6wb/4fjVquMGPzWOEbygSxj0ktNFaTC+VyS\nxnnu7Lb5s3jMO6z8Xmwg7/uQ+eGBQSDSTStjfazAjUHSor09k/EyJT+Iub3n+SbV\nAgeqEAlbk4j256NTdK712bSs7oLeZru+xB3U6vAjCIZ7+A/zNJBK6wdQaSMFNEIt\nJIcp9nNt+xSLMcwRMyIoI2j8LxOR6vCS389ZURddz4VgyHeDZEei0VD0eU3He6xO\nF0onG/ZhAgMBAAECggEAFTbLXCH6gRQDopGFx4/d3H1M/A5dBOWuioDgSUp7DFay\nosbfIvkmtT8MRa3WWrzMuWtR9Je1xpNPvzJsGvzksAlO8TwniApWghWICr3vuni/\nUKxyGmfy2xE/A57jWGXzFyhhNIELPk42I5YggHMjp6x4TBjozkg2AnYCrM0MKIJA\n+yBETH03eHINU1j6y2cVTTxwY/Mkxj3X3UfKFV4LcAQe6ycI9/UpVP3fuFp4BE4n\nemBMcBR4HEIIYvbtj6HeQtQyKzFMJ2LVXCmi2pACQEZFFF2jcNb6ODzznF1yBdeh\nCaogFry3zebrPzOIe8X9DWG15ufFdFoEEf+jRnPLPwKBgQDUstB1Zillvkmmwu/Z\nRdPj2WQ0B9vaV6bt1CFJUsgzi/bHv6Om5+7HtWXo5/irzjw4R4DUYQh5/pZ1P7F8\nSxAz6flh74aLCd0ecpeJl/WlPNZ3jpqJqKvniZV45GB66UKTj/La/nJ+iknnnxoz\nIZ/Mt0d/xfR7nVEZcKUqmKa6zwKBgQDJdUnyXogIBa848osiAgRmiAPW2uxSR5Iq\nsEsERy2Xqi3WyXQiVvY4OQNbOf7IMwDbJ4GfNuIsULBoVY3fwC3WF8r4tc6OCVqU\nKCNg5goWkKuhx7y/ikTXAD1jWL/JEFPzIlD9bkGkdmF24MJ6yohEeCyiCHiDMujy\n89nbRqzHzwKBgELZqLcdUumNcyycnDHXxo8YZmwMBEeNwQOC5qta/11kIj4Jt2/f\n+aZ/Fvaq4fdtrHOr1Yvqq3VcVQGo8Sm1lfQbF6x2Uf0lLoBBV+uA/U3f3zBYe63E\ne7McBQSoEsLOyYQDfDrkOiwXXr8TvHJRoR4AhNJd70di3Hh4dRD8RXr1AoGAKW/e\njeOzxzKkH+qDg7M2hIBlicPt596gyfcI9xBM6G0wkIVPReDtNBNGBXWgWj1jZ7Bw\nkPcQ/lx6bHtseyFkTC0Iqq96lOyHnQHEhSHL4WhQZS5YPG2MS0zZU53llM2u9suQ\nLRCIn/NZiMIiPm96J9swEwP7BcFq+M3/eYLH9zECgYEAwDlyauLMpSmzBc2qo4KI\nmIheChrJfq5ZlG2fW6c6UJFnQH88NutcF8D7Dnw8EkYOn7eUJuVsy64bwlA1qff7\nc0CzLezyC8MGj3s79k9C8DmnrXoBhY0FM3cuzJsfPplkLMHleA8SnXavXRdbytgk\nmuRQisTaEKueJIY6EcN2X9E=\n-----END PRIVATE KEY-----\n",
      "client_email":
          "firebase-adminsdk-6pvlb@chief-24f12.iam.gserviceaccount.com",
      "client_id": "114485518466141194225",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-6pvlb%40chief-24f12.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    });

    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    final httpClient =
        await clientViaServiceAccount(accountCredentials, scopes);

    const url =
        'https://fcm.googleapis.com/v1/projects/chief-24f12 /messages:send';

    final message = {
      "message": {
        "token": fcmToken,
        "notification": {
          "title": title,
          "body": body,
        },
      },
    };

    final response = await httpClient.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(message),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print(
          'Failed to send notification: ${response.statusCode} ${response.body}');
    }

    httpClient.close();
  }

  Future<void> submitRating() async {
    if (!await _isUserLoggedIn()) {
      Fluttertoast.showToast(msg: 'You must be logged in to submit a rating.');
      return;
    }

    String userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      // Push the rating to Firestore
      await FirebaseFirestore.instance.collection('chef_ratings').add({
        'chefId': widget.chefId,
        'userId': userId,
        'rating': _rating,
        'review': _reviewController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      // Retrieve the chef's FCM token
      // DocumentSnapshot chefDoc = await FirebaseFirestore.instance.collection('chefs').doc(widget.chefId).get();
      // String fcmToken = chefDoc['fcmToken'];

      // // Send notification to the chef
      // await sendNotification(fcmToken, 'New Rating', 'You have received a new rating.');

      Fluttertoast.showToast(msg: 'Thank you for your feedback!');

      // Clear the input fields after submission
      setState(() {
        _rating = 0.0;
        _reviewController.clear();
      });

      if (mounted) {
        // Optionally navigate back
        Navigator.of(context).pop();
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error submitting rating: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          const CustomAppBarWidget(title: 'Rate Chef', showBackButton: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              Text(
                'Your Rating',
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20.h),
              CustomRatingBar(
                initialRating: _rating,
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
              SizedBox(height: 20.h),
              TextField(
                controller: _reviewController,
                decoration: const InputDecoration(
                  labelText: 'Write your review here...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              SizedBox(height: 20.h),
              CustomLargeButton(
                title: 'Submit Review',
                ontap: submitRating,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Ensure that CustomRatingBar widget accepts an onRatingUpdate callback and updates the rating accordingly.
// The CustomLargeButton should be a simple ElevatedButton or similar with styling applied.
