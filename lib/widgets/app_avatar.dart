import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class AppAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final double radius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? fontSize;
  final bool showEditBadge;
  final VoidCallback? onTap;
  final IconData? defaultIcon;

  const AppAvatar({
    super.key,
    required this.avatarUrl,
    required this.name,
    this.radius = 24,
    this.backgroundColor,
    this.foregroundColor,
    this.fontSize,
    this.showEditBadge = false,
    this.onTap,
    this.defaultIcon,
  });

  ImageProvider? _resolveImageProvider(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    final trimmed = url.trim();

    try {
      if (trimmed.startsWith('data:image')) {
        final commaIdx = trimmed.indexOf(',');
        final base64Data = commaIdx != -1
            ? trimmed.substring(commaIdx + 1)
            : trimmed;
        return MemoryImage(base64Decode(base64Data));
      } else if (trimmed.startsWith('http://') ||
          trimmed.startsWith('https://')) {
        return NetworkImage(trimmed);
      } else if (!kIsWeb &&
          (trimmed.startsWith('/') ||
              trimmed.contains('\\') ||
              File(trimmed).existsSync())) {
        return FileImage(File(trimmed));
      }
    } catch (e) {
      debugPrint('⚠️ [AppAvatar] Error resolving avatar image: $e');
    }
    return null;
  }

  String _getInitials(String rawName) {
    final parts = rawName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        backgroundColor ??
        (isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE2E8F0));
    final textColor =
        foregroundColor ?? (isDark ? Colors.white : const Color(0xFF0F4C81));
    final effectiveFontSize = fontSize ?? (radius * 0.75);

    final imageProvider = _resolveImageProvider(avatarUrl);
    final initials = _getInitials(name);

    Widget avatarWidget = CircleAvatar(
      radius: radius,
      backgroundColor: primaryColor,
      foregroundImage: imageProvider,
      onForegroundImageError: imageProvider != null ? (_, _) {} : null,
      child: Center(
        child: initials.isNotEmpty && initials != '?'
            ? Text(
                initials,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: effectiveFontSize,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              )
            : Icon(
                defaultIcon ?? Icons.person_rounded,
                size: radius * 1.1,
                color: textColor.withValues(alpha: 0.8),
              ),
      ),
    );

    if (showEditBadge) {
      avatarWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          avatarWidget,
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(radius > 35 ? 6 : 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0F4C81),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                size: (radius * 0.38).clamp(12.0, 22.0),
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: avatarWidget,
      );
    }

    return avatarWidget;
  }
}

/// Bottom Sheet modal to allow users to set/update their profile photo
void showProfilePhotoOptionsSheet({
  required BuildContext context,
  required String currentAvatarUrl,
  required Function(String newAvatarUrl) onPhotoUpdated,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final picker = ImagePicker();

  Future<void> pickFromSource(ImageSource source) async {
    Navigator.pop(context);
    try {
      final XFile? picked = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        onPhotoUpdated(base64String);
      }
    } catch (e) {
      debugPrint('⚠️ [ImagePicker] Error picking image: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  showModalBottomSheet(
    context: context,
    backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profile Photo',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.photo_library_rounded,
                  color: Colors.blue,
                ),
              ),
              title: const Text(
                'Choose from Gallery',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Upload a photo from your device gallery',
                style: TextStyle(fontSize: 12),
              ),
              onTap: () => pickFromSource(ImageSource.gallery),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.green,
                ),
              ),
              title: const Text(
                'Take Photo',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Capture a new photo using camera',
                style: TextStyle(fontSize: 12),
              ),
              onTap: () => pickFromSource(ImageSource.camera),
            ),

            if (currentAvatarUrl.isNotEmpty) ...[
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                  ),
                ),
                title: const Text(
                  'Remove Photo',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Reset to default circle avatar',
                  style: TextStyle(fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  onPhotoUpdated('');
                },
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
