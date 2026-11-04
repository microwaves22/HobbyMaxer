import 'package:flutter/widgets.dart';

import '../../views/onboarding/models/user_profile.dart';
import 'api_client.dart';
import 'token_store.dart';

/// Backend user profile (`GET /auth/me`, `UserRead`).
class RemoteUser {
  const RemoteUser({
    required this.id,
    required this.displayName,
    required this.role,
    required this.mode,
    required this.pointsBalance,
    this.avatarUrl,
  });

  factory RemoteUser.fromJson(Map<String, dynamic> json) {
    return RemoteUser(
      id: json['id'] as int,
      displayName: json['display_name'] as String,
      role: json['role'] as String? ?? 'child',
      mode: json['mode'] as String?,
      pointsBalance: json['points_balance'] as int? ?? 0,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  final int id;
  final String displayName;
  final String role;
  final String? mode;
  final int pointsBalance;

  /// Backend avatar reference (`/avatars/...`), if the member set one.
  final String? avatarUrl;

  bool get isParent => role == 'parent';
}

/// Holds the JWT + active backend profile, persisted in secure storage.
///
/// Inject a client backed by `MockClient` and an [InMemoryTokenStore] in
/// tests to avoid the network and the platform keychain.
class AuthSession extends ChangeNotifier {
  AuthSession({ApiClient? client, TokenStore? tokenStore})
      : _store = tokenStore ?? SecureTokenStore(),
        _client = client ?? ApiClient() {
    // An injected test client may already carry its own provider.
    _client.tokenProvider ??= () => _token;
  }

  final TokenStore _store;
  final ApiClient _client;

  String? _token;
  RemoteUser? _user;

  String? get token => _token;
  RemoteUser? get user => _user;
  ApiClient get client => _client;
  bool get isAuthenticated => _token != null && _user != null;

  void _setToken(String? token) => _token = token;

  /// OAuth2 form login, then fetches the profile and persists the JWT.
  Future<void> login(String email, String password) async {
    final body = await _client.postForm(
      '/auth/login',
      {'username': email, 'password': password},
    ) as Map<String, dynamic>;
    _setToken(body['access_token'] as String);
    await _loadUser();
    await _store.writeToken(_token!);
    notifyListeners();
  }

  /// Parent registration (JSON). Returns with token + profile set.
  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final body = await _client.post('/auth/register', body: {
      'email': email,
      'password': password,
      'display_name': displayName,
    }) as Map<String, dynamic>;
    _setToken(body['access_token'] as String);
    _user = RemoteUser.fromJson(body['user'] as Map<String, dynamic>);
    await _store.writeToken(_token!);
    notifyListeners();
  }

  /// Restores a saved JWT (if any) and revalidates it via `GET /auth/me`.
  /// A dead token is discarded silently so the app falls back to login.
  Future<void> restore() async {
    final token = await _store.readToken();
    if (token == null || token.isEmpty) return;
    _setToken(token);
    try {
      await _loadUser();
    } catch (_) {
      _setToken(null);
      _user = null;
      await _store.deleteToken();
    }
    notifyListeners();
  }

  Future<void> logout() async {
    _setToken(null);
    _user = null;
    await _store.deleteToken();
    notifyListeners();
  }

  /// Persists the family Parent PIN (set during parent onboarding).
  /// Survives logout: the PIN belongs to the household device, not the
  /// login session.
  Future<void> setParentPin(String pin) => _store.writeParentPin(pin);

  /// Reads the stored Parent PIN, if any.
  Future<String?> getParentPin() => _store.readParentPin();

  Future<void> _loadUser() async {
    final body = await _client.get('/auth/me') as Map<String, dynamic>;
    _user = RemoteUser.fromJson(body);
  }

  /// Maps the backend profile onto the app's [UserProfile]. The API
  /// tracks no birthday, so it stays null (age unknown).
  UserProfile toProfile() {
    final user = _user;
    if (user == null) throw StateError('Not authenticated.');
    return UserProfile(
      name: user.displayName,
      role: user.isParent ? FamilyRole.parent : FamilyRole.child,
      mode: switch (user.mode) {
        'kids' => FamilyMode.kids,
        'teen' => FamilyMode.teen,
        _ => FamilyMode.parent,
      },
    );
  }
}

/// Provides the [AuthSession] above the app so login, home, and
/// controllers can share one authenticated client.
class AuthScope extends InheritedWidget {
  const AuthScope({
    super.key,
    required this.session,
    required super.child,
  });

  final AuthSession session;

  static AuthSession of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'AuthScope not found above this widget.');
    return scope!.session;
  }

  static AuthSession? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AuthScope>()?.session;

  @override
  bool updateShouldNotify(AuthScope oldWidget) =>
      session != oldWidget.session;
}
