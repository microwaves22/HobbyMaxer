import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Picks a profile picture in a web-safe way.
///
/// Returns the compressed bytes via [XFile.readAsBytes] (never a
/// `dart:io` File, which crashes on Flutter Web), or `null` when the
/// user cancels the picker.
Future<Uint8List?> pickAvatarBytes(
  ImagePicker picker,
  ImageSource source,
) async {
  final xfile = await picker.pickImage(
    source: source,
    maxWidth: 512,
    imageQuality: 70,
  );
  if (xfile == null) return null;
  return xfile.readAsBytes();
}

/// Initials for [name]: first + last word initials, or the first two
/// characters of a single word. Empty when [name] is blank.
String avatarInitials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '';
  if (parts.length == 1) {
    return parts.first.characters.take(2).toString().toUpperCase();
  }
  return (parts.first.characters.first + parts.last.characters.first)
      .toUpperCase();
}

/// Resolves a backend avatar reference to a fetchable URL.
///
/// The API stores relative paths (`/avatars/....png`); absolute URLs
/// pass through unchanged. Returns `null` for null/empty input.
String? resolveAvatarUrl(String? avatarUrl, String baseUrl) {
  if (avatarUrl == null || avatarUrl.isEmpty) return null;
  if (avatarUrl.startsWith('http://') ||
      avatarUrl.startsWith('https://')) {
    return avatarUrl;
  }
  final base =
      baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
  final path = avatarUrl.startsWith('/') ? avatarUrl : '/$avatarUrl';
  return '$base$path';
}

/// Shared circular member avatar used on every screen that shows members.
///
/// Priority: in-memory [bytes] preview (freshly picked photo) first,
/// then the persisted [imageUrl] (backend avatar URL), then a
/// placeholder with the member's initials (or a person icon when the
/// name is blank). Image failures fall back to the placeholder.
class MemberAvatar extends StatelessWidget {
  const MemberAvatar({
    super.key,
    this.bytes,
    this.imageUrl,
    required this.name,
    this.background,
    this.size = 40,
  });

  /// Freshly picked photo bytes (web-safe preview via [Image.memory]).
  final Uint8List? bytes;

  /// Persisted avatar URL, rendered with [Image.network].
  final String? imageUrl;

  /// Member name driving the placeholder initials.
  final String name;

  /// Placeholder background. Defaults to a neutral sage tint.
  final Color? background;

  /// Diameter in logical pixels.
  final double size;

  @override
  Widget build(BuildContext context) {
    final preview = bytes;
    if (preview != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: Image.memory(
          preview,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(),
        ),
      );
    }
    final url = imageUrl;
    if (url != null && url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    final initials = avatarInitials(name);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background ?? const Color(0xFFA9BE9C),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      alignment: Alignment.center,
      child: initials.isEmpty
          ? Icon(
              Icons.person_outline,
              size: size * 0.55,
              color: const Color(0xFF2B3A2B),
            )
          : Text(
              initials,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w800,
                fontSize: size * 0.38,
                color: const Color(0xFF2B3A2B),
              ),
            ),
    );
  }
}
