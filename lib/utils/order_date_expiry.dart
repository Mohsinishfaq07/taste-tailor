import 'package:taste_tailor/model/request_model.dart';

/// Parses [RequestModel.date] as `day/month/year` from the dashboard date picker.
DateTime? parseOrderDateField(String raw) {
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

/// Calendar date for the scheduled event (local), from [RequestModel.date] or [timestamp].
DateTime orderEventCalendarDate(RequestModel r) {
  final parsed = parseOrderDateField(r.date);
  if (parsed != null) {
    return DateTime(parsed.year, parsed.month, parsed.day);
  }
  final t = r.timestamp.toDate();
  return DateTime(t.year, t.month, t.day);
}

/// Today's date only (local), for comparing with event day.
DateTime calendarToday() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

/// Order event is on a calendar day strictly before today.
bool isOrderEventDatePast(RequestModel r) {
  return orderEventCalendarDate(r).isBefore(calendarToday());
}

/// Open order (no chef chosen yet, not finished) whose event date is in the past.
/// Chefs must not apply; users should treat as expired.
bool isOpenOrderExpired(RequestModel r) {
  final st = r.orderStatus.trim();
  if (st == 'completed') return false;
  if (r.acceptedChiefId != 'noChiefSelected') return false;
  if (st == 'assigned') return false;
  final low = st.toLowerCase();
  if (low == 'expired') return true;
  return isOrderEventDatePast(r);
}

/// Pre-order messaging should stop once the offer / booking window is over.
///
/// Covers: expired open requests, terminal order states, and assigned jobs whose
/// event date has passed.
bool isOrderMessagingExpired(RequestModel r) {
  final st = r.orderStatus.trim().toLowerCase();
  if (st == 'completed' || st == 'expired' || st == 'cancelled') return true;

  if (isOpenOrderExpired(r)) return true;

  final chief = r.acceptedChiefId.trim();
  final hasChef = chief.isNotEmpty && chief.toLowerCase() != 'nochiefselected';
  if (hasChef && isOrderEventDatePast(r)) return true;

  return false;
}
