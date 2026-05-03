import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Permanently removes the signed-in Firebase Auth account and clears key
/// user-linked Firestore data (best-effort), as required by Google Play for
/// in-app account deletion.
class AccountDeletionService {
  AccountDeletionService._();
  static final AccountDeletionService instance = AccountDeletionService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Success: returns `null`. Failure: localized short message for the UI.
  Future<String?> deleteCurrentUserAccount({
    required String password,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return 'You are not signed in.';

    final email = user.email?.trim();
    if (email == null || email.isEmpty) {
      return 'This sign-in method cannot be verified here. Please contact '
          'support to delete your account.';
    }

    try {
      final cred =
          EmailAuthProvider.credential(email: email, password: password.trim());
      await user.reauthenticateWithCredential(cred);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
        case 'invalid-email':
          return 'Incorrect password.';
        case 'too-many-requests':
          return 'Too many attempts. Try again later.';
        case 'requires-recent-login':
          return 'Please sign out, sign back in, and try deleting again.';
        default:
          return e.message ?? e.code;
      }
    } catch (e) {
      return e.toString();
    }

    final uid = user.uid;

    await _silent(() => _deleteConversations(uid));
    await _silent(() => _deleteByField('chef_ratings', 'userId', uid));
    await _silent(() => _deleteByField('chef_ratings', 'chefId', uid));
    await _silent(() => _deleteByField('ratings', 'userId', uid));
    await _silent(() => _deleteByField('ratings', 'chefId', uid));
    await _silent(() => _deleteByField('chef_offers', 'chefId', uid));

    final orderQueries = [
      ['food_orders', 'clientId'],
      ['food_orders', 'acceptedChiefId'],
      ['food_orders', 'userid'],
      ['food_orders', 'cookId'],
      ['food_orders', 'shiefid'],
      ['requests', 'clientId'],
      ['requests', 'acceptedChiefId'],
      ['requests', 'userid'],
      ['requests', 'shiefid'],
    ];
    for (final pair in orderQueries) {
      await _silent(() => _deleteByField(pair[0], pair[1], uid));
    }

    await _silent(() async {
      await _db.collection('allusers').doc(uid).delete();
    });

    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return 'Your session expired. Sign in again and try deleting.';
      }
      return e.message ?? e.code;
    } catch (e) {
      return 'Could not remove login: ${e.toString()}';
    }

    return null;
  }

  Future<void> _silent(Future<void> Function() fn) async {
    try {
      await fn();
    } catch (_) {
      // Best-effort; rules or partial data may prevent some deletes.
    }
  }

  Future<void> _deleteByField(
    String collection,
    String field,
    dynamic value,
  ) async {
    while (true) {
      final snap = await _db
          .collection(collection)
          .where(field, isEqualTo: value)
          .limit(40)
          .get();
      if (snap.docs.isEmpty) break;
      final batch = _db.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  Future<void> _deleteConversations(String uid) async {
    final snap =
        await _db.collection('conversations').where('participantIds', arrayContains: uid).get();

    for (final conv in snap.docs) {
      await _silent(() => _purgeMessages(conv.reference));
      await _silent(() => conv.reference.delete());
    }
  }

  Future<void> _purgeMessages(DocumentReference convRef) async {
    while (true) {
      final msgs = await convRef.collection('messages').limit(80).get();
      if (msgs.docs.isEmpty) break;
      final batch = _db.batch();
      for (final m in msgs.docs) {
        batch.delete(m.reference);
      }
      await batch.commit();
    }
  }
}
