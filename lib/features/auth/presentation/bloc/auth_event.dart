// Presentation Layer - Auth Events
import 'package:equatable/equatable.dart';

/// Clase base para todos los eventos de autenticación
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Evento: Verificar si hay un usuario autenticado
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Evento: Iniciar sesión con email y contraseña
class AuthSignInWithEmailRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInWithEmailRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Evento: Registrar usuario con email y contraseña
class AuthSignUpWithEmailRequested extends AuthEvent {
  final String email;
  final String password;
  final String displayName;

  const AuthSignUpWithEmailRequested({
    required this.email,
    required this.password,
    required this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}

/// Evento: Iniciar sesión con Google
class AuthSignInWithGoogleRequested extends AuthEvent {
  const AuthSignInWithGoogleRequested();
}

/// Evento: Cerrar sesión
class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}
