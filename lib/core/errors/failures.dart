// Core - Failures (manejo de errores)
import 'package:equatable/equatable.dart';

/// Clase base abstracta para todos los fallos de la aplicación
abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Fallo del servidor (Firebase, API, etc.)
class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

/// Fallo de autenticación
class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

/// Fallo de caché local
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

/// Fallo de red
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

/// Fallo de validación
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}
