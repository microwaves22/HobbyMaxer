import 'dart:typed_data';

import '../../core/network/api_client.dart';
import '../../core/widgets/member_avatar.dart';

/// Backend member endpoints (`POST /members/{id}/avatar`).
class MembersApi {
  MembersApi(this.client);

  final ApiClient client;

  /// Uploads [bytes] as the member's avatar.
  /// Returns the updated member JSON (including `avatar_url`).
  Future<Map<String, dynamic>> uploadAvatar(
    int memberId,
    Uint8List bytes, {
    String filename = 'avatar.jpg',
  }) async {
    final body = await client.postMultipart(
      '/members/$memberId/avatar',
      fileField: 'avatar',
      fileBytes: bytes,
      filename: filename,
    );
    return body as Map<String, dynamic>;
  }

  /// Uploads [bytes] and returns the display-ready avatar URL, or `null`
  /// when the backend answered without one.
  Future<String?> uploadAvatarUrl(
    int memberId,
    Uint8List bytes, {
    String filename = 'avatar.jpg',
  }) async {
    final json = await uploadAvatar(memberId, bytes, filename: filename);
    return resolveAvatarUrl(json['avatar_url'] as String?, client.baseUrl);
  }
}
