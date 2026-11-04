import 'api_client.dart';

/// Meta AI quick-add endpoint: natural language (typed or voice
/// transcript) to draft events/tasks. Drafts only — nothing is saved
/// until the parent confirms through the events/tasks endpoints.
class AiApi {
  AiApi(this.client);

  final ApiClient client;

  /// Posts [text] to `POST /ai/quick-add`. Returns the decoded drafts
  /// map (`events`, `tasks`, `warnings`).
  Future<Map<String, dynamic>> quickAdd(String text) async {
    final body = await client.post('/ai/quick-add', body: {'text': text});
    return body as Map<String, dynamic>;
  }
}
