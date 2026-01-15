// Core - Exceptions (excepciones para capturar en try-catch)

/// Excepción del servidor
class ServerException implements Exception {
  final String message;
  ServerException({required this.message});

  @override
  String toString() => 'ServerException: $message';
}

/// Excepción de autenticación
class AuthException implements Exception {
  final String message;
  AuthException({required this.message});

  @override
  String toString() => 'AuthException: $message';
}

/// Excepción de caché
class CacheException implements Exception {
  final String message;
  CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}
