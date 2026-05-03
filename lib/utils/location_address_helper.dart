import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// Fills [controller] with a human-readable address from the device GPS,
/// or reports failure via snackbar/toast callers can handle.
class LocationAddressHelper {
  LocationAddressHelper._();

  /// Returns non-null trimmed address string on success, otherwise null.
  static Future<String?> resolveAddressFromCurrentPosition(
    BuildContext context,
  ) async {
    final messenger = ScaffoldMessenger.maybeOf(context);

    final servicesOn = await Geolocator.isLocationServiceEnabled();
    if (!servicesOn) {
      messenger?.showSnackBar(
        const SnackBar(
          content: Text('Turn on Location in device settings.'),
        ),
      );
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      messenger?.showSnackBar(
        const SnackBar(
          content:
              Text('Location permission denied. Enter your address manually.'),
        ),
      );
      return null;
    }
    if (permission == LocationPermission.deniedForever) {
      messenger?.showSnackBar(
        SnackBar(
          content: const Text(
            'Location blocked for this app. Enable it in settings or type your address.',
          ),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () => Geolocator.openAppSettings(),
          ),
        ),
      );
      return null;
    }

    Position pos;
    try {
      pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (e) {
      messenger?.showSnackBar(
        SnackBar(content: Text('Could not read location: $e')),
      );
      return null;
    }

    try {
      final marks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      if (marks.isEmpty) return null;

      final p = marks.first;
      void add(String? s, List<String> out) {
        if (s != null && s.trim().isNotEmpty) out.add(s.trim());
      }

      final parts = <String>[];
      final streetBits = <String>[
        if (p.subThoroughfare != null && p.subThoroughfare!.trim().isNotEmpty)
          p.subThoroughfare!.trim(),
        if (p.thoroughfare != null && p.thoroughfare!.trim().isNotEmpty)
          p.thoroughfare!.trim(),
      ];
      final line1 = streetBits.join(' ');
      if (line1.isNotEmpty) {
        parts.add(line1);
      } else {
        add(p.street, parts);
      }
      add(p.subLocality, parts);
      add(p.locality, parts);
      add(p.administrativeArea, parts);
      add(p.postalCode, parts);
      add(p.country, parts);

      final line = parts.join(', ');
      if (line.isEmpty) return null;

      return line;
    } catch (_) {
      messenger?.showSnackBar(
        const SnackBar(
          content: Text('Could not convert location to address. Try manual.'),
        ),
      );
      return null;
    }
  }
}
