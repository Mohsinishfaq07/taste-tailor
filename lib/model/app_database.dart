// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:async';
import 'dart:io';

import 'package:taste_tailor/model/all_user_detail_model.dart';
import 'package:taste_tailor/model/chief_detail_model.dart';
import 'package:taste_tailor/model/client_detail_model.dart';
import 'package:taste_tailor/model/request_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:taste_tailor/view/auth/login_screen.dart';
import 'package:taste_tailor/view/dashboard/User_dashboard_request_form.dart';
import 'package:taste_tailor/view/get_started_screen.dart';
import 'package:taste_tailor/view/user_screens/rehman/orders/user_orders_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:taste_tailor/provider/locale_notifier.dart';
import 'package:taste_tailor/utils/tri_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../view/dashboard/chef_dashboard_screen.dart';
import '../services/push_registration_service.dart';
import '../utils/chef_city_extractor.dart';
import '../utils/shared_preferences_manager.dart';
import '../utils/order_date_expiry.dart';

class AppDatabase {
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void signIn(String email, String pass, BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.orange)),
    );
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: pass);
      final user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
            .collection('allusers')
            .doc(user.uid)
            .get();

        if (snapshot.exists) {
          final data = snapshot.data()!;
          await SharedPreferencesManager.saveUserSession(
            userId: user.uid,
            name: (data['name'] ?? data['Name'] ?? '').toString(),
            email: (data['email'] ?? data['Email'] ?? '').toString(),
            role: data['role'] ?? '',
            image: data['image'],
          );

          await PushRegistrationService.syncForAuthenticatedUser(
            role: data['role']?.toString(),
          );

          Navigator.of(context).popUntil((route) => route.isFirst);
          if (data['role'] == 'chief') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const ChefDashboardScreen(),
              ),
              (Route<dynamic> route) => false,
            );
          } else if (data['role'] == 'user') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (navContext) => UserOrdersScreen(
                  type: UserOrderScreenType.all,
                  title: TriLocalization.triSilent(
                    navContext.read<LocaleNotifier>(),
                    (l) => l.myOrdersTitle,
                  ),
                ),
              ),
              (Route<dynamic> route) => false,
            );
          }
          Fluttertoast.showToast(
            msg: LocaleNotifier.toast('Login Successful', 'لاگ اِن کامیاب'),
          );
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: '$e');
      Navigator.of(context).pop();
    }
  }

  Future<void> resetPassword(BuildContext context, String email) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.orange)),
    );

    try {
      // Reference to your Firestore collection
      CollectionReference users = FirebaseFirestore.instance.collection(
        'allusers',
      );

      // Query Firestore to check if the email exists
      QuerySnapshot querySnapshot = await users
          .where('Email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Email exists, send reset password email
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
        Navigator.of(context).pop(); // Dismiss the loading dialog
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        Fluttertoast.showToast(
          msg: LocaleNotifier.toast(
            'Reset password email sent',
            'ری سیٹ ای میل بھیج دی گئی',
          ),
        );
      } else {
        // Email does not exist
        Navigator.of(context).pop(); // Dismiss the loading dialog
        Fluttertoast.showToast(
          msg: LocaleNotifier.toast(
            'enter correct email',
            'درست ای میل درج کریں',
          ),
        );
      }
    } catch (e) {
      // Error occurred
      Navigator.of(context).pop(); // Dismiss the loading dialog
      Fluttertoast.showToast(
        msg: LocaleNotifier.toast(
          'An error occurred. Please try again later.',
          'خرابی آئی ہے۔ بعد میں کوشش کریں۔',
        ),
      );
      if (kDebugMode) {
        print('Error resetting password: $e');
      }
    }
  }

  Future<String> getUserRole() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
            .collection('allusers')
            .doc(user.uid)
            .get();
        if (snapshot.exists) {
          final data = snapshot.data();
          if (data != null && data.containsKey('role')) {
            return data['role'] as String;
          } else {
            // Handle the case where the role field is missing or not found
            return 'unknown';
          }
        } else {
          // Handle the case where the document does not exist
          return 'unknown';
        }
      } else {
        // Handle the case where the current user is null
        return 'unknown';
      }
    } catch (e) {
      // Handle any errors that occur during the process
      Fluttertoast.showToast(msg: "Error fetching user role: $e");
      return 'unknown';
    }
  }

  Future<void> chefDetailToFireStore({
    required BuildContext context,
    required ChiefDetailModel chiefDetail,
    required AllUserDetailModel allUserDetail,
  }) async {
    try {
      final user = _auth.currentUser!;
      // Canonical allusers chef doc (single name/email/userId — no duplicates).
      await FirebaseFirestore.instance
          .collection('allusers')
          .doc(user.uid)
          .set({
            'userId': user.uid,
            'role': chiefDetail.role,
            'timestamp': allUserDetail.timestamp,
            'name': allUserDetail.name,
            'email': allUserDetail.email,
            'address': chiefDetail.address,
            'city': chiefDetail.city.trim().isNotEmpty
                ? chiefDetail.city.trim()
                : ChefCityExtractor.fromAddress(chiefDetail.address),
            'number': chiefDetail.number,
            'password': chiefDetail.password,
            'image': chiefDetail.image,
            'certificateImage': chiefDetail.certificateImage,
            'certifications': chiefDetail.certifications,
            'rating': chiefDetail.rating,
            'workExperience': chiefDetail.workExperience,
            'specialties': chiefDetail.specialties,
          });

      // Save user info to SharedPreferences
      await saveUserInfo(
        userId: user.uid,
        name: allUserDetail.name,
        email: allUserDetail.email,
        role: allUserDetail.role,
        image: chiefDetail.image,
      );

      await PushRegistrationService.syncForAuthenticatedUser(role: 'chief');

      Fluttertoast.showToast(msg: "Chief Account Created");
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const GetStartedScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      if (context.mounted) {
        final nav = Navigator.of(context, rootNavigator: true);
        if (nav.canPop()) nav.pop(); // signup loading overlay
      }
      print("Error chefDetailToFireStore: $e");
      rethrow;
    }
  }

  Future<void> userDetailsToFireStore({
    required BuildContext context,
    required ClientDetailModel clientDetail,
    required AllUserDetailModel allUserDetail,
  }) async {
    try {
      final user = _auth.currentUser!;
      // Canonical allusers client doc (single name/email/userId — no duplicates).
      await FirebaseFirestore.instance
          .collection('allusers')
          .doc(user.uid)
          .set({
            'userId': user.uid,
            'role': clientDetail.role,
            'timestamp': allUserDetail.timestamp,
            'name': allUserDetail.name,
            'email': allUserDetail.email,
            'address': clientDetail.address,
            'number': clientDetail.number,
            'password': clientDetail.password,
            'image': clientDetail.image,
          });

      // Save user info to SharedPreferences
      await saveUserInfo(
        userId: user.uid,
        name: allUserDetail.name,
        email: allUserDetail.email,
        role: allUserDetail.role,
        image: clientDetail.image,
      );

      await PushRegistrationService.syncForAuthenticatedUser(
        role: clientDetail.role.toString(),
      );

      Fluttertoast.showToast(msg: "User Account Created");
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const GetStartedScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      if (context.mounted) {
        final nav = Navigator.of(context, rootNavigator: true);
        if (nav.canPop()) nav.pop(); // signup loading overlay
      }
      print("Error userDetailsToFireStore: $e");
      rethrow;
    }
  }

  Future<void> requestToFireStore({
    required BuildContext context,
    required RequestModel requestModel,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('food_orders')
          .add(requestModel.toJson());
      Fluttertoast.showToast(msg: 'Request Added Successfully');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }

  Future<RequestModel?> _requestModelFromFoodOrRequests(String docId) async {
    final foodSnap = await FirebaseFirestore.instance
        .collection('food_orders')
        .doc(docId)
        .get();
    final foodData = foodSnap.data();
    if (foodData != null) {
      return RequestModel.fromJson(Map<String, dynamic>.from(foodData));
    }
    final reqSnap = await FirebaseFirestore.instance
        .collection('requests')
        .doc(docId)
        .get();
    final reqData = reqSnap.data();
    if (reqData != null) {
      return RequestModel.fromJson(Map<String, dynamic>.from(reqData));
    }
    return null;
  }

  Future<void> acceptByChief({
    required String docId,
    required String userId,
    required String fare,
  }) async {
    try {
      final pending = await _requestModelFromFoodOrRequests(docId);
      if (pending == null) {
        Fluttertoast.showToast(msg: 'Order not found.');
        return;
      }
      if (isOpenOrderExpired(pending)) {
        Fluttertoast.showToast(msg: 'This order has expired.');
        return;
      }

      CollectionReference ref = FirebaseFirestore.instance.collection(
        'food_orders',
      );

      await ref.doc(docId).update({
        'chefResponses': FieldValue.arrayUnion([
          {'userId': userId, 'reqStatus': 'applied', 'fare': fare}, // Accepted
        ]),
      });

      Fluttertoast.showToast(msg: 'Request accepted.');
    } catch (e) {
      Fluttertoast.showToast(msg: '$e');
      print("Error: $e");
    }
  }

  Future<void> rejectByChief({
    required String docId,
    required String userId,
  }) async {
    try {
      CollectionReference ref = FirebaseFirestore.instance.collection(
        'food_orders',
      );

      await ref.doc(docId).update({
        'chefResponses': FieldValue.arrayUnion([
          {'userId': userId, 'reqStatus': 'rejected', 'fare': '0'}, // Rejected
        ]),
      });

      Fluttertoast.showToast(msg: 'Request rejected.');
    } catch (e) {
      Fluttertoast.showToast(msg: '$e');
      print("Error: $e");
    }
  }

  Future<void> acceptedByClient({
    required String docId,
    required String chiefId,
  }) async {
    try {
      final pending = await _requestModelFromFoodOrRequests(docId);
      if (pending == null) {
        Fluttertoast.showToast(msg: 'Order not found.');
        return;
      }
      if (isOpenOrderExpired(pending)) {
        Fluttertoast.showToast(msg: 'This order has expired.');
        return;
      }

      CollectionReference ref = FirebaseFirestore.instance.collection(
        'food_orders',
      );
      await ref.doc(docId).update({
        'acceptedChiefId': chiefId,
        'orderStatus': 'assigned',
      });
    } catch (e) {
      Fluttertoast.showToast(msg: '$e');
      print("Error: $e");
    }
  }

  Future<void> rejectByClient({
    required String docId,
    required String chiefId,
  }) async {
    try {
      CollectionReference ref = FirebaseFirestore.instance.collection(
        'food_orders',
      );
      await ref.doc(docId).update({
        'chefResponses': FieldValue.arrayUnion([
          {'userId': chiefId, 'reqStatus': 'rejected', 'fare': '0'}, // Rejected
        ]),
      });
      // await ref.doc(docId).update({
      //   'acceptedChiefId': chiefId,
      // });
    } catch (e) {
      Fluttertoast.showToast(msg: '$e');
      print("Error: $e");
    }
  }

  Future<void> orderCompleted({required String docId}) async {
    try {
      CollectionReference ref = FirebaseFirestore.instance.collection(
        'food_orders',
      );
      await ref.doc(docId).update({'orderStatus': 'completed'});
      Fluttertoast.showToast(msg: 'order completed');
      // await ref.doc(docId).update({
      //   'acceptedChiefId': chiefId,
      // });
    } catch (e) {
      Fluttertoast.showToast(msg: '$e');
      print("Error: $e");
    }
  }

  Future<ChiefDetailModel?> getChiefById({required String docId}) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('allusers')
          .doc(docId)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        if ((data['role'] ?? '').toString() == 'chief') {
          return ChiefDetailModel.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching chief user: $e');
      return null;
    }
  }

  Future<ClientDetailModel?> getUserById({required String docId}) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('allusers')
          .doc(docId)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        if ((data['role'] ?? '').toString() == 'user') {
          return ClientDetailModel.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching  user: $e');
      return null;
    }
  }

  Future<bool> updateClientProfileFields({
    required String name,
    required String number,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        Fluttertoast.showToast(msg: 'Please sign in again.');
        return false;
      }

      await _firestore.collection('allusers').doc(user.uid).update({
        'name': name.trim(),
        'number': number.trim(),
      });

      final session = await SharedPreferencesManager.getUserSession();
      final savedEmail =
          ((session['userEmail'] as String?) ?? '').trim().isEmpty
          ? user.email ?? ''
          : session['userEmail'] as String;
      final savedRole = ((session['userRole'] as String?) ?? '').trim().isEmpty
          ? 'user'
          : session['userRole'] as String;
      await SharedPreferencesManager.saveUserSession(
        userId: user.uid,
        name: name.trim(),
        email: savedEmail,
        role: savedRole,
        image: session['userImage'] as String?,
      );

      Fluttertoast.showToast(msg: 'Profile updated');
      return true;
    } catch (e) {
      Fluttertoast.showToast(msg: '$e');
      return false;
    }
  }

  Future<bool> updateChiefProfileFields({
    required String name,
    required String number,
    required String address,
    required String specialties,
    required String workExperience,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        Fluttertoast.showToast(msg: 'Please sign in again.');
        return false;
      }

      await _firestore.collection('allusers').doc(user.uid).update({
        'name': name.trim(),
        'number': number.trim(),
        'address': address.trim(),
        'city': ChefCityExtractor.fromAddress(address.trim()),
        'specialties': specialties.trim(),
        'workExperience': workExperience.trim(),
      });

      final session = await SharedPreferencesManager.getUserSession();
      final savedEmail =
          ((session['userEmail'] as String?) ?? '').trim().isEmpty
          ? user.email ?? ''
          : session['userEmail'] as String;
      final savedRole = ((session['userRole'] as String?) ?? '').trim().isEmpty
          ? 'chief'
          : session['userRole'] as String;
      await SharedPreferencesManager.saveUserSession(
        userId: user.uid,
        name: name.trim(),
        email: savedEmail,
        role: savedRole,
        image: session['userImage'] as String?,
      );

      Fluttertoast.showToast(msg: 'Profile updated');
      return true;
    } catch (e) {
      Fluttertoast.showToast(msg: '$e');
      return false;
    }
  }

  /// Uploads [imageFile] to Firebase Storage and sets `image` on the signed-in user's `allusers` doc + session cache.
  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        Fluttertoast.showToast(
          msg: LocaleNotifier.toast(
            'Please sign in again.',
            'براہ کرم دوبارہ سائن اِن کریں۔',
          ),
        );
        return null;
      }

      final stamp = DateTime.now().millisecondsSinceEpoch;
      final ref = FirebaseStorage.instance
          .ref()
          .child('images/profile_${user.uid}_$stamp.jpg');
      await ref.putFile(imageFile, SettableMetadata(contentType: 'image/jpeg'));
      final url = await ref.getDownloadURL();

      await _firestore.collection('allusers').doc(user.uid).update({
        'image': url,
      });

      final snapshot = await _firestore.collection('allusers').doc(user.uid).get();
      final data = snapshot.data() ?? {};
      final session = await SharedPreferencesManager.getUserSession();
      var name =
          '${data['name'] ?? session['userName'] ?? ''}'.trim();
      if (name.isEmpty && user.displayName != null) {
        name = user.displayName!.trim();
      }
      if (name.isEmpty) {
        name = 'User';
      }
      final emailRaw =
          '${data['email'] ?? session['userEmail'] ?? user.email ?? ''}'.trim();
      final email = emailRaw.isEmpty ? (user.email ?? '') : emailRaw;
      var role =
          '${data['role'] ?? session['userRole'] ?? 'user'}'.trim();
      if (role.isEmpty) {
        role = 'user';
      }

      await SharedPreferencesManager.saveUserSession(
        userId: user.uid,
        name: name,
        email: email,
        role: role,
        image: url,
      );

      Fluttertoast.showToast(
        msg: LocaleNotifier.toast(
          'Profile photo updated',
          'پروفائل تصویر اپ ڈیٹ ہو گئی',
        ),
      );
      return url;
    } catch (e) {
      Fluttertoast.showToast(
        msg: LocaleNotifier.toast(
          'Could not upload photo',
          'تصویر اپ لوڈ نہیں ہو سکی',
        ),
      );
      if (kDebugMode) {
        debugPrint('uploadProfileImage error: $e');
      }
      return null;
    }
  }

  Future<bool> updateClientPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      final email = user?.email?.trim();
      if (user == null || email == null || email.isEmpty) {
        Fluttertoast.showToast(msg: 'No email on this account.');
        return false;
      }

      final cred = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);

      await _firestore.collection('allusers').doc(user.uid).update({
        'password': newPassword,
      });

      Fluttertoast.showToast(msg: 'Password updated');
      return true;
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.message ?? e.code);
      return false;
    } catch (e) {
      Fluttertoast.showToast(msg: '$e');
      return false;
    }
  }

  Future<ClientDetailModel> getClientById({required String docId}) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('allusers')
        .doc(docId)
        .get();

    if (!snapshot.exists) {
      throw Exception('User not found');
    }

    return ClientDetailModel.fromJson(snapshot.data()!);
  }

  Future<void> rateChef({
    required String docId,
    required String givenRating,
  }) async {
    try {
      DocumentReference chefRef = FirebaseFirestore.instance
          .collection('allusers')
          .doc(docId);

      DocumentSnapshot chefSnapshot = await chefRef.get();

      if (chefSnapshot.exists) {
        final role = (chefSnapshot['role'] ?? '').toString();
        if (role != 'chief') {
          return;
        }
        String previousRatingStr = (chefSnapshot['rating'] ?? "0");
        double previousRating = double.tryParse(previousRatingStr) ?? 0.0;

        double newRatingValue = double.tryParse(givenRating) ?? 0.0;

        double newRating = (previousRating + newRatingValue) / 2;

        await chefRef.update({'rating': newRating.toString()});

        print("Chef rating updated successfully: $newRating");
      } else {
        print("Chef document does not exist.");
      }
    } catch (e) {
      print("Error updating chef rating: $e");
    }
  }

  Future<void> cookSideRequest(
    BuildContext context,
    String userid,
    String itemName,
    String date,
    String arrivelTime,
    String eventTime,
    String noOfPeople,
    String fare,
    String availabeingred,
    String name,
    String image,
    String collection,
    String action,
    String status,
    String cookPhoneNumber,
    String cookEmail,
    String cookId,
  ) async {
    final user = _auth.currentUser;
    try {
      CollectionReference ref = FirebaseFirestore.instance.collection(
        collection,
      );
      ref.doc().set({
        'userid': user!.uid,
        'addedby': userid,
        'User_Name': name,
        'Item_Name': itemName,
        'Date': date,
        'Arrivel_Time': arrivelTime,
        'Event_Time': eventTime,
        'No_of_People': noOfPeople,
        'Fare': fare,
        'Action': action,
        'Availabe_Ingredients': availabeingred,
        'image': image,
        'timestamp': FieldValue.serverTimestamp(),
        'status': status,
        'cookPhoneNumber': cookPhoneNumber,
        'cookEmail': cookEmail,
        'cookId': cookId,
      });
    } catch (e) {
      Fluttertoast.showToast(msg: '$e');
    }
    if (collection == 'request_form') {
      Fluttertoast.showToast(msg: "Request Added");
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const UserDashboardRequestForm(),
        ),
      );
    }
  }

  Future<void> addAcceptedRequest(
    BuildContext context,
    String userid,
    String shiefid,
    String itemName,
    String date,
    String arrivelTime,
    String eventTime,
    String noOfPeople,
    int fare,
    String availabeingred,
    String name,
    String image,
    String collection,
  ) async {
    try {
      CollectionReference ref = FirebaseFirestore.instance.collection(
        collection,
      );
      ref.doc().set({
        'shiefid': shiefid,
        'userid': userid,
        'User_Name': name,
        'Item_Name': itemName,
        'Date': date,
        'Arrivel_Time': arrivelTime,
        'Event_Time': eventTime,
        'No_of_People': noOfPeople,
        'Fare': fare,
        'Availabe_Ingredients': availabeingred,
        'image': image,
        'timestamp': FieldValue.serverTimestamp(),
        // Note: serverTimestamp() should not be updated if you want to retain the original creation time
      });
      Fluttertoast.showToast(msg: "Request Updated");
      // Navigator.of(context).pop(); // Typically you might want to pop back instead of navigating to a new route
    } catch (e) {
      Fluttertoast.showToast(msg: '$e');
    }
  }

  Future<void> addChefRequest(
    BuildContext context,
    String documentId,
    String userid,
    String itemName,
    String date,
    String arrivelTime,
    String eventTime,
    String noOfPeople,
    int fare,
    String availabeingred,
    String name,
    String image,
    String collection,
    String rating,
    int newfare,
  ) async {
    final user = _auth.currentUser;
    try {
      CollectionReference ref = FirebaseFirestore.instance.collection(
        collection,
      );
      ref.doc().set({
        'shiefid': user!.uid,
        'userid': userid,
        'oldDocumentid': documentId,
        'User_Name': name,
        'Item_Name': itemName,
        'Date': date,
        'Arrivel_Time': arrivelTime,
        'Event_Time': eventTime,
        'No_of_People': noOfPeople,
        'New_fare': newfare,
        'Fare': fare,
        'Shiefrating,': rating,
        'Availabe_Ingredients': availabeingred,
        'image': image,
        'timestamp': FieldValue.serverTimestamp(),
        // Note: serverTimestamp() should not be updated if you want to retain the original creation time
      });
      Fluttertoast.showToast(msg: "Request Updated");
      // Navigator.of(context).pop(); // Typically you might want to pop back instead of navigating to a new route
    } catch (e) {
      Fluttertoast.showToast(msg: '$e');
    }
  }

  Future<void> acceptRequestAndUpdateVisibility(String requestId) async {
    await FirebaseFirestore.instance
        .collection('new_requestform')
        .doc(requestId)
        .update({
          'status': 'accepted',
          'isVisibleToChef': false,
          'isVisibleToUser': true,
        })
        .then((value) {
          Fluttertoast.showToast(msg: "Request moved to My Orders");
        })
        .catchError((error) {
          Fluttertoast.showToast(msg: "Error updating request: $error");
        });
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    try {
      await _firestore.collection('request_form').doc(requestId).update({
        'status': status,
      });
    } catch (e) {
      // Handle exceptions
      print(e);
    }
  }

  Future<void> chefAcceptsRequest(String requestId) async {
    await FirebaseFirestore.instance
        .collection('new_requestform')
        .doc(requestId)
        .update({'Action': 'in processing'})
        .then((value) {
          Fluttertoast.showToast(
            msg: "Request accepted, awaiting user confirmation.",
          );
        })
        .catchError((error) {
          Fluttertoast.showToast(msg: "Error accepting request: $error");
        });
  }

  Future<void> userAcceptsRequest(String requestId) async {
    await _firestore
        .collection('accepted_requests')
        .doc(requestId)
        .update({
          'status': 'accepted',
          'isVisibleToChef': false,
          'isVisibleToUser': true,
        })
        .then((value) {
          Fluttertoast.showToast(msg: "Request accepted by user.");
        })
        .catchError((error) {
          Fluttertoast.showToast(msg: "Error on user's acceptance: $error");
        });
  }

  Future<void> acceptRequest(BuildContext context, String documentId) async {
    await _firestore
        .collection('request_form')
        .doc(documentId)
        .update({'Action': 'accepted', 'isVisibleToChef': false})
        .then((_) {
          Fluttertoast.showToast(msg: 'Request accepted.');
        })
        .catchError((error) {
          Fluttertoast.showToast(msg: 'Error accepting request: $error');
        });
  }

  Future<String> getUserName() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
            .collection('allusers')
            .doc(user.uid)
            .get();
        if (snapshot.exists && snapshot.data() != null) {
          final data = snapshot.data()!;
          return (data['name'] ?? data['Name'] ?? 'No Name').toString();
        } else {
          return 'No Name';
        }
      } else {
        return 'No User';
      }
    } catch (e) {
      print('Error fetching user name: $e');
      return 'Error';
    }
  }

  Future<void> completeOrder(String documentId) async {
    try {
      await _firestore.collection('accepted_requests').doc(documentId).update({
        'status': 'completed',
      });
      print("Order marked as completed.");
    } catch (e) {
      print("An error occurred while completing the order: $e");
    }
  }

  Future<bool> hasRatedChef(String chefId, String userId) async {
    try {
      var querySnapshot = await _firestore
          .collection('ratings')
          .where('chefId', isEqualTo: chefId)
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print("Error checking rating status: $e");
      return false;
    }
  }

  Future<void> logout(BuildContext context) async {
    final session = await SharedPreferencesManager.getUserSession();
    await PushRegistrationService.onLogoutCleanup(
      role: session['userRole'] as String?,
    );
    await SharedPreferencesManager.clearUserSession();
    await _auth.signOut();
    if (!context.mounted) return;
    await Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamedAndRemoveUntil(GetStartedScreen.tag, (route) => false);
  }

  Future<void> saveUserInfo({
    required String userId,
    required String name,
    required String email,
    required String role,
    String? image,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userId', userId);
    await prefs.setString('userName', name);
    await prefs.setString('userEmail', email);
    await prefs.setString('userRole', role);
    if (image != null) {
      await prefs.setString('userImage', image);
    }
  }
}

class EmailVerificationDialog extends StatefulWidget {
  final User user;

  const EmailVerificationDialog({required this.user});

  @override
  _EmailVerificationDialogState createState() =>
      _EmailVerificationDialogState();
}

class _EmailVerificationDialogState extends State<EmailVerificationDialog> {
  int _secondsRemaining = 30;
  Timer? _timer;
  bool _isEmailVerified = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) async {
      setState(() {
        _secondsRemaining--;
      });

      if (_secondsRemaining == 0) {
        _timer?.cancel();
        await _checkEmailVerification();
      }
    });
  }

  Future<void> _checkEmailVerification() async {
    await widget.user.reload();
    setState(() {
      _isEmailVerified = widget.user.emailVerified;
    });

    if (_isEmailVerified) {
      Navigator.of(context).pop(true);
    } else {
      Fluttertoast.showToast(
        msg: "Email not verified yet. Please check your email.",
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Verify Your Email"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "You need to verify your email to complete the sign-up process.",
          ),
          SizedBox(height: 10),
          Text("Returning in $_secondsRemaining seconds..."),
          SizedBox(height: 10),
          CircularProgressIndicator(),
        ],
      ),
      actions: [
        TextButton(
          child: Text("Check Now"),
          onPressed: _checkEmailVerification,
        ),
      ],
    );
  }
}
