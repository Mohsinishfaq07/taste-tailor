import 'package:cloud_firestore/cloud_firestore.dart';

/// Pre-order direct messages between two users (user ↔ chef) using Firestore.
///
/// Layout:
/// - `conversations/{conversationId}` — metadata (`participantIds`, `lastMessage`, `updatedAt`)
/// - `conversations/{conversationId}/messages/{messageId}` — `{ senderId, text, createdAt }`
///
/// [conversationId] is deterministic from two UIDs so both parties join the same thread.
/// Deploy Firestore security rules so only participants can read/write (see project README).
class ChatService {
  ChatService._();
  static final ChatService instance = ChatService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Stable id for the pair (order-independent).
  static String conversationIdFor(String uidA, String uidB) {
    final ids = [uidA, uidB]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  CollectionReference<Map<String, dynamic>> _messages(String conversationId) =>
      _db.collection('conversations').doc(conversationId).collection('messages');

  DocumentReference<Map<String, dynamic>> _conversationDoc(String conversationId) =>
      _db.collection('conversations').doc(conversationId);

  /// Ensures parent `conversations/{id}` exists with [participantIds] before any
  /// listener on `messages` runs — rules deny subcollection reads if [get(conversation)] fails.
  Future<void> ensureConversationDocument({
    required String conversationId,
    required String myUid,
    required String peerUid,
  }) async {
    final participants = [myUid, peerUid]..sort();
    await _conversationDoc(conversationId).set(
      {
        'participantIds': participants,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String peerId,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final participants = [senderId, peerId]..sort();

    /// Parent doc must exist before the batch: rules evaluate reads against
    /// pre-batch state; [get(conversation)] fails on the first message otherwise.
    await _conversationDoc(conversationId).set(
      {
        'participantIds': participants,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    final msgRef = _messages(conversationId).doc();

    final batch = _db.batch();
    batch.set(msgRef, {
      'senderId': senderId,
      'text': trimmed,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.set(
      _conversationDoc(conversationId),
      {
        'participantIds': participants,
        'lastMessage': trimmed,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> messagesStream(String conversationId) {
    return _messages(conversationId)
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  /// Lists threads where [myUid] is a participant (sort `updatedAt` in UI if needed).
  Stream<QuerySnapshot<Map<String, dynamic>>> conversationsForUser(String myUid) {
    return _db
        .collection('conversations')
        .where('participantIds', arrayContains: myUid)
        .snapshots();
  }
}
