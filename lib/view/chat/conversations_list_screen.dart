import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_tailor/model/app_database.dart';
import 'package:taste_tailor/services/chat_service.dart';
import 'package:taste_tailor/view/chat/chat_conversation_screen.dart';

/// Inbox: open threads for the signed-in user (user or chef).
class ConversationsListScreen extends StatelessWidget {
  const ConversationsListScreen({super.key});

  static const String tag = 'ConversationsListScreen';

  static String _peerId(List<dynamic> participantIds, String myUid) {
    for (final id in participantIds) {
      final s = id.toString();
      if (s != myUid) return s;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final me = FirebaseAuth.instance.currentUser;
    final chat = ChatService.instance;
    final db = AppDatabase();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepOrange.shade200,
      ),
      body: me == null
          ? const Center(child: Text('Please sign in.'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: chat.conversationsForUser(me.uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.deepOrange.shade300,
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Text(
                        'No conversations yet.\nOpen a chef profile or reply from your dashboard to start chatting.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.brown.shade700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  );
                }

                final sorted = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(docs)
                  ..sort((a, b) {
                    final ta = a.data()['updatedAt'];
                    final tb = b.data()['updatedAt'];
                    if (ta is Timestamp && tb is Timestamp) {
                      return tb.compareTo(ta);
                    }
                    return 0;
                  });

                return ListView.separated(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  itemCount: sorted.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final doc = sorted[index];
                    final data = doc.data();
                    final ids =
                        (data['participantIds'] as List<dynamic>?) ?? [];
                    final peerId = _peerId(ids, me.uid);
                    final last = (data['lastMessage'] ?? '').toString();

                    return FutureBuilder<String>(
                      future: _resolveDisplayName(db, peerId),
                      builder: (context, nameSnap) {
                        final title = nameSnap.data ?? '…';
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.deepOrange.shade100,
                            child: Text(
                              title.isNotEmpty ? title[0].toUpperCase() : '?',
                              style: TextStyle(
                                color: Colors.deepOrange.shade900,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          title: Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15.sp,
                            ),
                          ),
                          subtitle: Text(
                            last,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12.sp),
                          ),
                          onTap: peerId.isEmpty
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatConversationScreen(
                                        peerUserId: peerId,
                                      ),
                                    ),
                                  );
                                },
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }

  static Future<String> _resolveDisplayName(AppDatabase db, String peerId) async {
    if (peerId.isEmpty) return 'Unknown';
    final chief = await db.getChiefById(docId: peerId);
    if (chief != null && chief.name.trim().isNotEmpty) return chief.name.trim();
    final client = await db.getUserById(docId: peerId);
    if (client != null && client.name.trim().isNotEmpty) return client.name.trim();
    return 'User';
  }
}
