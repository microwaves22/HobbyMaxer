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
  bool _restoring = false;
  bool _restored = false;
  Future<void>? _restoreFuture;

  String? get token => _token;
  RemoteUser? get user => _user;
  ApiClient get client => _client;
  bool get isAuthenticated => _token != null && _user != null;

  /// True while a [restore] is in flight.
  bool get isRestoring => _restoring;

  /// True once the auth state is known: the startup [restore] has
  /// finished (valid, dead, or absent token), or a login, registration,
  /// or logout has resolved it. Gates splash routing so the app never
  /// flashes login for a user with a valid saved JWT.
  bool get hasRestored => _restored;

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
    _restored = true;
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
    _restored = true;
    notifyListeners();
  }

  /// Switches the shared-device session to another profile. Child
  /// targets need no parent PIN; a set child PIN is verified instead.
  Future<void> switchProfile({required int userId, String? pin}) async {
    final body = await _client.post('/auth/switch-profile', body: {
      'user_id': userId,
      if (pin != null) 'pin': pin,
    }) as Map<String, dynamic>;
    await _applyAuthResponse(body);
  }

  /// Independent child login with the child's own PIN (optional).
  Future<void> childLogin({required int userId, String? pin}) async {
    final body = await _client.post('/auth/child-login', body: {
      'user_id': userId,
      if (pin != null) 'child_pin': pin,
    }) as Map<String, dynamic>;
    await _applyAuthResponse(body);
  }

  /// Applies an AuthResponse (token + user), persisting the JWT.
  Future<void> _applyAuthResponse(Map<String, dynamic> body) async {
    _setToken(body['access_token'] as String);
    _user = RemoteUser.fromJson(body['user'] as Map<String, dynamic>);
    await _store.writeToken(_token!);
    _restored = true;
    notifyListeners();
  }

  /// Restores a saved JWT (if any) and revalidates it via `GET /auth/me`.
  /// A dead token is discarded silently so the app falls back to login.
  ///
  /// Concurrent calls share one in-flight restore, and calls after the
  /// first completed restore are no-ops: the session already knows its
  /// state. Always notifies, so splash routing observes both the
  /// loading and the resolved state.
  Future<void> restore() {
    final pending = _restoreFuture;
    if (pending != null) return pending;
    if (_restored) return Future.value();
    _restoreFuture = _doRestore();
    return _restoreFuture!;
  }

  Future<void> _doRestore() async {
    _restoring = true;
    notifyListeners();
    try {
      String? token;
      try {
        token = await _store.readToken();
      } catch (_) {
        token = null;
      }
      if (token == null || token.isEmpty) {
        // No saved session — but never clobber a login that landed
        // while the keychain read was in flight.
        if (_token == null) _user = null;
        return;
      }
      // A login that completed first wins; its token is already live.
      if (isAuthenticated) return;
      _setToken(token);
      try {
        await _loadUser();
      } catch (_) {
        // Only discard what we restored; a concurrent login owns its
        // token and must survive a stale saved JWT.
        if (_token == token) {
          _setToken(null);
          _user = null;
        }
        try {
          await _store.deleteToken();
        } catch (_) {
          // Keychain unavailable: the in-memory state is already clear.
        }
      }
    } finally {
      _restoring = false;
      _restored = true;
      _restoreFuture = null;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _setToken(null);
    _user = null;
    await _store.deleteToken();
    _restored = true;
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
///
/// An [InheritedNotifier], so dependents rebuild when the session
/// notifies (login, logout, and restore completion) — a plain
/// [InheritedWidget] would never notify because the session identity
/// never changes.
class AuthScope extends InheritedNotifier<AuthSession> {
  const AuthScope({
    super.key,
    required AuthSession session,
    required super.child,
  }) : super(notifier: session);

  AuthSession get session => notifier!;

  static AuthSession of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'AuthScope not found above this widget.');
    return scope!.session;
  }

  static AuthSession? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AuthScope>()?.session;
}
