import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:taste_tailor/extensions/context_tri_l10n.dart';
import 'package:taste_tailor/model/request_model.dart';
import 'package:taste_tailor/provider/locale_notifier.dart';
import 'package:taste_tailor/utils/order_date_expiry.dart';
import 'package:taste_tailor/view/drawer/chef_drawer.dart';

enum _ChefCalOrdStatus { completed, assigned, expired, pending }

DateTime _dayKeyUtc(DateTime d) => DateTime.utc(d.year, d.month, d.day);

class ChefOrdersCalendarScreen extends StatefulWidget {
  const ChefOrdersCalendarScreen({super.key});

  static const String tag = 'ChefOrdersCalendarScreen';

  @override
  State<ChefOrdersCalendarScreen> createState() =>
      _ChefOrdersCalendarScreenState();
}

class _ChefCalendarRow {
  _ChefCalendarRow({
    required this.docId,
    required this.request,
  });

  final String docId;
  final RequestModel request;
}

class _ChefOrdersCalendarScreenState extends State<ChefOrdersCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  static DateTime? _parseStoredDate(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;
    final parts = s.split('/');
    if (parts.length != 3) return null;
    final d = int.tryParse(parts[0].trim());
    final m = int.tryParse(parts[1].trim());
    final y = int.tryParse(parts[2].trim());
    if (d == null || m == null || y == null) return null;
    if (m < 1 || m > 12 || d < 1 || d > 31) return null;
    try {
      return DateTime(y, m, d);
    } catch (_) {
      return null;
    }
  }

  static DateTime _eventDay(RequestModel r) {
    final fromField = _parseStoredDate(r.date);
    if (fromField != null) {
      return DateTime(fromField.year, fromField.month, fromField.day);
    }
    final t = r.timestamp.toDate();
    return DateTime(t.year, t.month, t.day);
  }

  /// Same visibility as [ChefMyOrderScreen] — applied, assigned, or completed for this chef.
  static bool _isRelevantToChef(Map<String, dynamic> data, String chefUid) {
    final chefResponses = (data['chefResponses'] as List<dynamic>?) ?? [];
    final acceptedChiefId = (data['acceptedChiefId'] ?? '').toString();
    final orderStatus = (data['orderStatus'] ?? '').toString();

    final isPendingForChef = chefResponses.any((response) =>
        response is Map &&
        response['userId'] == chefUid &&
        response['reqStatus'] == 'applied' &&
        acceptedChiefId == 'noChiefSelected');

    final isActiveForChef =
        acceptedChiefId == chefUid && orderStatus == 'assigned';
    final isCompletedForChef =
        acceptedChiefId == chefUid && orderStatus == 'completed';

    return isPendingForChef || isActiveForChef || isCompletedForChef;
  }

  Map<DateTime, List<_ChefCalendarRow>> _mergeAndBucket(
    QuerySnapshot foodSnap,
    QuerySnapshot reqSnap,
    String chefUid,
  ) {
    final byId = <String, QueryDocumentSnapshot<Object?>>{};
    for (final d in [...foodSnap.docs, ...reqSnap.docs]) {
      byId[d.id] = d;
    }

    final rows = <_ChefCalendarRow>[];
    for (final e in byId.entries) {
      final raw = e.value.data();
      if (raw is! Map<String, dynamic>) continue;
      final data = Map<String, dynamic>.from(raw);
      if (!_isRelevantToChef(data, chefUid)) continue;
      rows.add(
        _ChefCalendarRow(
          docId: e.key,
          request: RequestModel.fromJson(data),
        ),
      );
    }
    rows.sort((a, b) => b.request.timestamp.compareTo(a.request.timestamp));

    final map = <DateTime, List<_ChefCalendarRow>>{};
    for (final row in rows) {
      final k = _dayKeyUtc(_eventDay(row.request));
      map.putIfAbsent(k, () => []).add(row);
    }
    for (final list in map.values) {
      list.sort((a, b) => b.request.timestamp.compareTo(a.request.timestamp));
    }
    return map;
  }

  _ChefCalOrdStatus _calOrdStatus(RequestModel r) {
    final id = r.acceptedChiefId;
    final st = r.orderStatus;
    if (st == 'completed') return _ChefCalOrdStatus.completed;
    if (id != 'noChiefSelected' && st == 'assigned') {
      return _ChefCalOrdStatus.assigned;
    }
    if (isOpenOrderExpired(r)) return _ChefCalOrdStatus.expired;
    return _ChefCalOrdStatus.pending;
  }

  Color _calOrdColor(_ChefCalOrdStatus s) {
    switch (s) {
      case _ChefCalOrdStatus.completed:
        return const Color(0xFF2E7D32);
      case _ChefCalOrdStatus.assigned:
        return const Color(0xFF01579B);
      case _ChefCalOrdStatus.expired:
        return const Color(0xFF455A64);
      case _ChefCalOrdStatus.pending:
        return const Color(0xFFE65100);
    }
  }

  String _calOrdLabel(BuildContext context, _ChefCalOrdStatus s) {
    switch (s) {
      case _ChefCalOrdStatus.completed:
        return context.tri((l) => l.orderStatusCompleted);
      case _ChefCalOrdStatus.assigned:
        return context.tri((l) => l.orderStatusAssigned);
      case _ChefCalOrdStatus.expired:
        return context.tri((l) => l.orderStatusExpired);
      case _ChefCalOrdStatus.pending:
        return context.tri((l) => l.orderStatusPending);
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _dayKeyUtc(_focusedDay);
  }

  @override
  Widget build(BuildContext context) {
    final chef = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tri((l) => l.chefOrdersCalendarTitle),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepOrange.shade200,
      ),
      drawer: const ChefDrawer(),
      body: chef == null
          ? Center(child: Text(context.tri((l) => l.pleaseSignInAgain)))
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('food_orders').snapshots(),
                builder: (context, foodSnap) {
                  if (foodSnap.hasError) {
                    return Center(
                      child: Text(context.tri((l) =>
                          l.errorWithMessage('${foodSnap.error}'))),
                    );
                  }

                  return StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance.collection('requests').snapshots(),
                    builder: (context, reqSnap) {
                      if (reqSnap.hasError) {
                        return Center(
                          child: Text(context.tri((l) =>
                              l.errorWithMessage('${reqSnap.error}'))),
                        );
                      }
                      if (foodSnap.connectionState == ConnectionState.waiting ||
                          reqSnap.connectionState == ConnectionState.waiting ||
                          !foodSnap.hasData ||
                          !reqSnap.hasData) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: Colors.pink.shade200,
                          ),
                        );
                      }

                      final events = _mergeAndBucket(
                        foodSnap.data!,
                        reqSnap.data!,
                        chef.uid,
                      );
                      final sel = _selectedDay != null
                          ? _dayKeyUtc(_selectedDay!)
                          : _dayKeyUtc(_focusedDay);

                      final List<_ChefCalendarRow> forSelected =
                          events[sel] ?? const [];

                      List<_ChefCalendarRow> eventLoader(DateTime day) =>
                          events[_dayKeyUtc(day)] ?? [];

                      return Column(
                        children: [
                          _calendarCard(eventLoader),
                          SizedBox(height: 12.h),
                          Expanded(
                            child: _detailsPanel(context, sel, forSelected),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
    );
  }

  Widget _calendarCard(
      List<_ChefCalendarRow> Function(DateTime day) eventLoader) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFFFB74D), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9800).withValues(alpha: 0.14),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TableCalendar<_ChefCalendarRow>(
        firstDay: DateTime.utc(2023, 1, 1),
        lastDay: DateTime.utc(2032, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) =>
            _selectedDay != null && isSameDay(_selectedDay!, _dayKeyUtc(day)),
        eventLoader: eventLoader,
        startingDayOfWeek: StartingDayOfWeek.monday,
        onFormatChanged: (f) => setState(() => _calendarFormat = f),
        onDaySelected: (selected, focused) {
          setState(() {
            _selectedDay = _dayKeyUtc(selected);
            _focusedDay = focused;
          });
        },
        onPageChanged: (focused) {
          setState(() => _focusedDay = focused);
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Colors.deepOrange.shade100,
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Colors.deepOrange.shade400,
            shape: BoxShape.circle,
          ),
          weekendTextStyle: TextStyle(color: Colors.brown.shade700),
          defaultTextStyle: TextStyle(
            color: Colors.brown.shade900,
            fontWeight: FontWeight.w600,
          ),
          outsideDaysVisible: true,
          markerDecoration: const BoxDecoration(
            color: Color(0xFF7E57C2),
            shape: BoxShape.circle,
          ),
          markersMaxCount: 4,
          markerMargin: const EdgeInsets.symmetric(horizontal: 1),
          markerSize: 6,
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonShowsNext: false,
          formatButtonDecoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.deepOrange.shade200),
          ),
          titleTextStyle: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF5D4037),
          ),
        ),
      ),
    );
  }

  Widget _detailsPanel(
    BuildContext context,
    DateTime selectedKey,
    List<_ChefCalendarRow> rows,
  ) {
    if (rows.isEmpty) {
      final dateLabel = _formatHeaderDate(context, selectedKey);
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Text(
            context.tri((l) => l.noOrdersOnDate(dateLabel)),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.brown.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.only(bottom: 16.h),
      itemCount: rows.length,
      separatorBuilder: (context, index) => SizedBox(height: 10.h),
      itemBuilder: (context, index) {
        final row = rows[index];
        final r = row.request;
        final ordStatus = _calOrdStatus(r);
        final lbl = _calOrdLabel(context, ordStatus);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: const Color(0xFFFFCC80)),
            boxShadow: [
              BoxShadow(
                color: Colors.deepOrange.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      r.itemName,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.sp,
                        color: const Color(0xFF4E342E),
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color:
                          _calOrdColor(ordStatus).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      lbl,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        color: _calOrdColor(ordStatus),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 12.w,
                runSpacing: 6.h,
                children: [
                  _miniInfo(
                    Icons.event_note_outlined,
                    r.date.trim().isNotEmpty
                        ? r.date
                        : _formatHeaderDate(context, selectedKey),
                  ),
                  _miniInfo(Icons.access_time_rounded, r.eventTime),
                  _miniInfo(Icons.groups_outlined, r.totalPerson),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _miniInfo(IconData icon, String text) {
    final t = text.trim().isEmpty ? '—' : text;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.deepOrange.shade400),
        SizedBox(width: 4.w),
        Text(
          t,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: Colors.brown.shade700,
          ),
        ),
      ],
    );
  }

  String _formatHeaderDate(BuildContext context, DateTime d) {
    final code = Provider.of<LocaleNotifier>(context, listen: false)
        .locale
        .languageCode;
    final localDay = DateTime(d.year, d.month, d.day);
    return DateFormat.yMMMd(code).format(localDay);
  }
}
