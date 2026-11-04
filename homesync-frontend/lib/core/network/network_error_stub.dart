/// Web-safe fallback: `dart:io` (and therefore `SocketException`)
/// does not exist on Flutter Web, so no error can be one.
bool isConnectionError(Object error) => false;
