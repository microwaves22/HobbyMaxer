import '../../core/network/api_client.dart';

/// Backend calendar endpoints (shared family events).
class CalendarApi {
  CalendarApi(this.client);

  final ApiClient client;

  /// Family events, earliest first.
  Future<List<Map<String, dynamic>>> fetchEvents() async {
    final raw = await client.get('/calendar/events') as List;
    return [for (final item in raw) item as Map<String, dynamic>];
  }

  /// Creates a family event. Returns the created event JSON.
  Future<Map<String, dynamic>> createEvent({
    required String title,
    String? description,
    required DateTime startsAt,
    DateTime? endsAt,
  }) async {
    final body = await client.post('/calendar/events', body: {
      'title': title,
      if (description != null) 'description': description,
      'starts_at': startsAt.toIso8601String(),
      if (endsAt != null) 'ends_at': endsAt.toIso8601String(),
    });
    return body as Map<String, dynamic>;
  }

  /// Deletes a family event.
  Future<void> deleteEvent(int serverId) async {
    await client.delete('/calendar/events/$serverId');
  }
}
