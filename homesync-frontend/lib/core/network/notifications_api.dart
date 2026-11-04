import '../../core/network/api_client.dart';

/// In-app notification inbox plus family notification preferences.
///
/// Lightweight by design: polling only, no push or SMS.
class NotificationsApi {
  NotificationsApi(this.client);

  final ApiClient client;

  /// Own notifications, newest first.
  Future<List<dynamic>> fetchNotifications({bool unreadOnly = false}) async {
    final body = await client.get(
      '/notifications${unreadOnly ? '?unread_only=true' : ''}',
    );
    return body as List;
  }

  /// Marks one notification read. Returns the updated JSON.
  Future<Map<String, dynamic>> markRead(int id) async {
    final body = await client.put('/notifications/$id/read');
    return body as Map<String, dynamic>;
  }

  /// Marks all own notifications read. Returns how many were unread.
  Future<int> markAllRead() async {
    final body = await client.post('/notifications/read-all');
    return (body as Map<String, dynamic>)['marked_read'] as int? ?? 0;
  }

  /// Family notification preferences (all enabled by default).
  Future<Map<String, dynamic>> fetchPreferences() async {
    final body = await client.get('/families/me/preferences');
    return body as Map<String, dynamic>;
  }

  /// Saves merged notification preferences. Returns the saved JSON.
  Future<Map<String, dynamic>> updatePreferences(
    Map<String, bool> prefs,
  ) async {
    final body = await client.put('/families/me/preferences', body: prefs);
    return body as Map<String, dynamic>;
  }
}
