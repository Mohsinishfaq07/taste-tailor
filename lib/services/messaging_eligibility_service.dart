import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taste_tailor/model/request_model.dart';
import 'package:taste_tailor/utils/order_date_expiry.dart';

/// Pre-order chat is only allowed while an order/offer linking the client and
/// chef is still active (not expired, completed, or past event for assigned jobs).
class MessagingEligibilityService {
  MessagingEligibilityService._();
  static final MessagingEligibilityService instance =
      MessagingEligibilityService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  RequestModel? _tryParse(Map<String, dynamic>? data) {
    if (data == null) return null;
    try {
      return RequestModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  /// True when [r] links [clientUid] to [chefUid] and messaging is still allowed.
  bool requestAllowsPair(
    RequestModel r,
    String clientUid,
    String chefUid,
  ) {
    if (r.clientId != clientUid) return false;
    if (isOrderMessagingExpired(r)) return false;

    final ac = r.acceptedChiefId.trim();
    final hasAssignedChef =
        ac.isNotEmpty && ac.toLowerCase() != 'nochiefselected';
    if (hasAssignedChef) {
      return ac == chefUid;
    }

    // Open request: client may contact any chef while offers are still valid.
    return true;
  }

  /// Whether the signed-in user ([uidA]) may chat with [uidB] (chef ↔ client).
  Future<bool> canChatPair(String uidA, String uidB) async {
    if (uidA.isEmpty || uidB.isEmpty || uidA == uidB) return false;

    final snapA = await _db.collection('allusers').doc(uidA).get();
    final snapB = await _db.collection('allusers').doc(uidB).get();

    final roleA = (snapA.data()?['role'] ?? '').toString().trim();
    final roleB = (snapB.data()?['role'] ?? '').toString().trim();

    String? clientUid;
    String? chefUid;
    if (roleA == 'user' && roleB == 'chief') {
      clientUid = uidA;
      chefUid = uidB;
    } else if (roleA == 'chief' && roleB == 'user') {
      clientUid = uidB;
      chefUid = uidA;
    } else {
      return false;
    }

    for (final collection in const ['food_orders', 'requests']) {
      final qs = await _db
          .collection(collection)
          .where('clientId', isEqualTo: clientUid)
          .limit(50)
          .get();

      for (final doc in qs.docs) {
        final model = _tryParse(doc.data());
        if (model != null && requestAllowsPair(model, clientUid, chefUid)) {
          return true;
        }
      }
    }

    return false;
  }
}
