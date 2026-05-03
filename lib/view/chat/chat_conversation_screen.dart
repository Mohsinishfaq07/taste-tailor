import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:taste_tailor/model/app_database.dart';
import 'package:taste_tailor/services/chat_service.dart';
import 'package:taste_tailor/services/messaging_eligibility_service.dart';

/// One-to-one chat with [peerUserId] (chef or client UID).
class ChatConversationScreen extends StatefulWidget {
  const ChatConversationScreen({
    super.key,
    required this.peerUserId,
  });

  final String peerUserId;

  static const String tag = 'ChatConversationScreen';

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final AppDatabase _database = AppDatabase();
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final ChatService _chat = ChatService.instance;

  String _peerName = 'Chat';
  bool _loadingName = true;
  bool _prepareDone = false;
  Object? _prepareError;
  bool _messagingAllowed = false;

  String get _conversationId {
    final me = FirebaseAuth.instance.currentUser?.uid;
    if (me == null) return '';
    return ChatService.conversationIdFor(me, widget.peerUserId);
  }

  @override
  void initState() {
    super.initState();
    _loadPeerName();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prepareChat());
  }

  Future<void> _prepareChat() async {
    final me = FirebaseAuth.instance.currentUser;
    final peer = widget.peerUserId;

    if (me == null || peer.isEmpty || me.uid == peer) {
      if (mounted) {
        setState(() {
          _prepareDone = true;
          _prepareError = null;
          _messagingAllowed = true;
        });
      }
      return;
    }

    Object? err;
    try {
      await _chat.ensureConversationDocument(
        conversationId: ChatService.conversationIdFor(me.uid, peer),
        myUid: me.uid,
        peerUid: peer,
      );
    } catch (e) {
      err = e;
    }

    final allowed =
        await MessagingEligibilityService.instance.canChatPair(me.uid, peer);

    if (!mounted) return;
    setState(() {
      _prepareError = err;
      _prepareDone = true;
      _messagingAllowed = allowed;
    });
  }

  void _retryPrepare() {
    setState(() {
      _prepareDone = false;
      _prepareError = null;
    });
    _prepareChat();
  }

  Future<void> _loadPeerName() async {
    final chief = await _database.getChiefById(docId: widget.peerUserId);
    if (!mounted) return;
    if (chief != null && chief.name.trim().isNotEmpty) {
      setState(() {
        _peerName = chief.name.trim();
        _loadingName = false;
      });
      return;
    }
    final client = await _database.getUserById(docId: widget.peerUserId);
    if (!mounted) return;
    setState(() {
      _peerName = client?.name.trim().isNotEmpty == true
          ? client!.name.trim()
          : 'User';
      _loadingName = false;
    });
  }

  Future<void> _send() async {
    final me = FirebaseAuth.instance.currentUser;
    if (me == null) return;
    if (!_messagingAllowed) {
      Fluttertoast.showToast(
        msg: 'This offer has ended — you can’t send new messages.',
      );
      return;
    }
    final text = _input.text;
    if (text.trim().isEmpty) return;

    await _chat.sendMessage(
      conversationId: _conversationId,
      senderId: me.uid,
      peerId: widget.peerUserId,
      text: text,
    );
    _input.clear();
    if (_scroll.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(
            _scroll.position.maxScrollExtent + 80,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final me = FirebaseAuth.instance.currentUser;

    if (me == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chat'),
          backgroundColor: Colors.deepOrange.shade200,
        ),
        body: const Center(child: Text('Please sign in to chat.')),
      );
    }

    if (me.uid == widget.peerUserId) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chat'),
          backgroundColor: Colors.deepOrange.shade200,
        ),
        body: const Center(child: Text('Cannot chat with yourself.')),
      );
    }

    final cid = _conversationId;

    Widget bodyContent;
    if (!_prepareDone) {
      bodyContent = Center(
        child: CircularProgressIndicator(color: Colors.deepOrange.shade300),
      );
    } else if (_prepareError != null) {
      bodyContent = Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Could not prepare this chat.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8.h),
              Text(
                '$_prepareError',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.sp, color: Colors.brown.shade700),
              ),
              SizedBox(height: 16.h),
              TextButton.icon(
                onPressed: _retryPrepare,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    } else {
      bodyContent = Column(
        children: [
          if (!_messagingAllowed)
            Material(
              color: Colors.amber.shade100,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        color: Colors.brown.shade800, size: 22.sp),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        'This offer or booking is no longer active — you can read '
                        'past messages but can’t send new ones.',
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.brown.shade900,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _chat.messagesStream(cid),
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
                if (docs.isNotEmpty) {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    if (_scroll.hasClients) {
                      _scroll.jumpTo(_scroll.position.maxScrollExtent);
                    }
                  });
                }
                if (docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Text(
                        _messagingAllowed
                            ? 'Say hello — ask about menu, timing, or ingredients before you book.'
                            : 'No new messages. This chat is read-only because the offer has ended.',
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

                return ListView.builder(
                  controller: _scroll,
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    final senderId = (data['senderId'] ?? '').toString();
                    final text = (data['text'] ?? '').toString();
                    final mine = senderId == me.uid;
                    final createdAt = data['createdAt'];
                    String timeStr = '';
                    if (createdAt is Timestamp) {
                      final d = createdAt.toDate();
                      timeStr =
                          '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
                    }

                    return Align(
                      alignment:
                          mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 8.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.78,
                        ),
                        decoration: BoxDecoration(
                          color: mine
                              ? Colors.deepOrange.shade100
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(14),
                            topRight: const Radius.circular(14),
                            bottomLeft: Radius.circular(mine ? 14 : 4),
                            bottomRight: Radius.circular(mine ? 4 : 14),
                          ),
                          border: Border.all(
                            color: mine
                                ? Colors.deepOrange.shade200
                                : Colors.grey.shade400,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              text,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFF4E342E),
                                height: 1.35,
                              ),
                            ),
                            if (timeStr.isNotEmpty) ...[
                              SizedBox(height: 4.h),
                              Text(
                                timeStr,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.brown.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_messagingAllowed)
            Container(
              padding: EdgeInsets.fromLTRB(
                10.w,
                6.h,
                10.w,
                MediaQuery.of(context).padding.bottom + 8.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Type a message…',
                        filled: true,
                        fillColor: const Color(0xFFFFF8E1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.r),
                          borderSide:
                              BorderSide(color: Colors.deepOrange.shade200),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 10.h,
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.deepOrange.shade400,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _send,
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                14.w,
                12.h,
                14.w,
                MediaQuery.of(context).padding.bottom + 10.h,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Text(
                'Messaging disabled — offer expired or order finished.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.brown.shade800,
                ),
              ),
            ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: _loadingName
            ? const Text('Chat', style: TextStyle(fontWeight: FontWeight.bold))
            : Text(
                _peerName,
                style:
                    const TextStyle(fontWeight: FontWeight.bold),
              ),
        centerTitle: true,
        backgroundColor: Colors.deepOrange.shade200,
      ),
      body: bodyContent,
    );
  }
}
