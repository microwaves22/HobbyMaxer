import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// JWT persistence. Inject [InMemoryTokenStore] in tests to avoid the
/// platform secure-storage plugin.
abstract class TokenStore {
  Future<String?> readToken();
  Future<void> writeToken(String token);
  Future<void> deleteToken();

  Future<String?> readParentPin();
  Future<void> writeParentPin(String pin);
  Future<void> deleteParentPin();
}

/// Production store backed by the OS keychain/keystore.
class SecureTokenStore implements TokenStore {
  SecureTokenStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _key = 'homesync_jwt';
  static const _pinKey = 'homesync_parent_pin';

  @override
  Future<String?> readToken() => _storage.read(key: _key);

  @override
  Future<void> writeToken(String token) =>
      _storage.write(key: _key, value: token);

  @override
  Future<void> deleteToken() => _storage.delete(key: _key);

  @override
  Future<String?> readParentPin() => _storage.read(key: _pinKey);

  @override
  Future<void> writeParentPin(String pin) =>
      _storage.write(key: _pinKey, value: pin);

  @override
  Future<void> deleteParentPin() => _storage.delete(key: _pinKey);
}

/// Non-persistent store for tests and previews.
class InMemoryTokenStore implements TokenStore {
  String? _token;
  String? _pin;

  @override
  Future<String?> readToken() async => _token;

  @override
  Future<void> writeToken(String token) async => _token = token;

  @override
  Future<void> deleteToken() async => _token = null;

  @override
  Future<String?> readParentPin() async => _pin;

  @override
  Future<void> writeParentPin(String pin) async => _pin = pin;

  @override
  Future<void> deleteParentPin() async => _pin = null;
}
