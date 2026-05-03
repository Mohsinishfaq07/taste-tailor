import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_tailor/extensions/context_tri_l10n.dart';
import '../utils/location_address_helper.dart';

/// Row: use GPS to fill address, or user types manually in the adjacent field.
class AddressLocationOptions extends StatefulWidget {
  const AddressLocationOptions({
    super.key,
    required this.addressController,
  });

  final TextEditingController addressController;

  @override
  State<AddressLocationOptions> createState() => _AddressLocationOptionsState();
}

class _AddressLocationOptionsState extends State<AddressLocationOptions> {
  bool _busy = false;

  Future<void> _useCurrentLocation() async {
    if (!mounted) return;
    setState(() => _busy = true);
    final addr = await LocationAddressHelper.resolveAddressFromCurrentPosition(
      context,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (addr != null && addr.isNotEmpty) {
      widget.addressController.text = addr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.tri((l) => l.locationHelpLine),
          style: TextStyle(
            fontSize: 12.sp,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
            height: 1.35,
          ),
        ),
        SizedBox(height: 8.h),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: _busy ? null : _useCurrentLocation,
            icon: _busy
                ? SizedBox(
                    width: 16.w,
                    height: 16.w,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.my_location, size: 18.sp),
            label: Text(
              _busy
                  ? context.tri((l) => l.gettingLocation)
                  : context.tri((l) => l.useCurrentLocation),
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.deepOrange.shade700,
              side: BorderSide(color: Colors.deepOrange.shade300),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            ),
          ),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }
}
