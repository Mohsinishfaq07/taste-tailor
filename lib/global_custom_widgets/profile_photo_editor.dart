import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

/// Bottom sheet to pick gallery vs camera ([ImagePicker] uses the result).
Future<ImageSource?> showProfilePhotoSourceSheet({
  required BuildContext context,
  required String galleryLabel,
  required String cameraLabel,
  required String dismissLabel,
}) {
  return showModalBottomSheet<ImageSource>(
    context: context,
    showDragHandle: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library_rounded,
                  color: Colors.deepOrange.shade700),
              title: Text(galleryLabel,
                  style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 15.sp)),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: Icon(Icons.photo_camera_rounded,
                  color: Colors.deepOrange.shade700),
              title: Text(cameraLabel,
                  style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 15.sp)),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(dismissLabel),
            ),
          ],
        ),
      ),
    ),
  );
}

bool profilePhotoUrlLooksValid(String raw) {
  final t = raw.trim();
  return t.startsWith('http://') || t.startsWith('https://');
}

/// Avatar preview + camera affordance used on user & chef profile screens.
class ProfilePhotoEditorBanner extends StatelessWidget {
  const ProfilePhotoEditorBanner({
    super.key,
    required this.imageUrl,
    required this.uploading,
    required this.headingLabel,
    required this.hintLabel,
    required this.onChangeTap,
    this.avatarSize,
  });

  final String imageUrl;
  final bool uploading;
  final String headingLabel;
  final String hintLabel;
  final VoidCallback onChangeTap;
  final double? avatarSize;

  @override
  Widget build(BuildContext context) {
    final size = avatarSize ?? 96.w;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          headingLabel,
          style: TextStyle(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF5D4037),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 6.h),
        Text(
          hintLabel,
          style: TextStyle(
            fontSize: 11.5.sp,
            color: Colors.brown.shade600,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 14.h),
        Center(
          child: GestureDetector(
            onTap: uploading ? null : onChangeTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: const Color(0xFFFFB74D), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.deepOrange.withValues(alpha: 0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: uploading
                        ? ColoredBox(
                            color: Colors.grey.shade200,
                            child: Center(
                              child: SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.deepOrange.shade400,
                                ),
                              ),
                            ),
                          )
                        : profilePhotoUrlLooksValid(imageUrl)
                            ? Image.network(
                                imageUrl.trim(),
                                fit: BoxFit.cover,
                                loadingBuilder: (_, child, progress) =>
                                    progress == null
                                        ? child
                                        : ColoredBox(
                                            color: Colors.grey.shade200,
                                            child: Center(
                                              child:
                                                  CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors
                                                    .deepOrange.shade400,
                                              ),
                                            ),
                                          ),
                                errorBuilder: (_, _, _) => _placeholder(size),
                              )
                            : _placeholder(size),
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Material(
                    color: Colors.white,
                    elevation: 2,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: uploading ? null : onChangeTap,
                      child: Padding(
                        padding: EdgeInsets.all(8.r),
                        child: Icon(
                          Icons.photo_camera_rounded,
                          size: 20.sp,
                          color: Colors.deepOrange.shade800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _placeholder(double size) {
    return ColoredBox(
      color: Colors.grey.shade200,
      child: Icon(
        Icons.person_rounded,
        size: size * 0.42,
        color: Colors.grey.shade500,
      ),
    );
  }
}
