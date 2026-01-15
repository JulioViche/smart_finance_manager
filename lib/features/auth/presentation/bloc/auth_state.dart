// Presentation Layer - Auth States
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

/// Clase base para todos los estados de autenticación
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial - verificando autenticación
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Estado: Cargando (realizando operación)
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Estado: Usuario autenticado
class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Estado: Usuario no autenticado
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Estado: Error de autenticación
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
