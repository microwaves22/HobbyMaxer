import 'dart:io';

/// Native platforms: transport failures surface as [SocketException].
bool isConnectionError(Object error) => error is SocketException;
