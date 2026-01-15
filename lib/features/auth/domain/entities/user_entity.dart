// Domain Layer - User Entity
import 'package:equatable/equatable.dart';

/// Preferencias del usuario
class UserPreferences extends Equatable {
  final String currency;
  final bool notificationsEnabled;
  final String theme;

  const UserPreferences({
    this.currency = 'USD',
    this.notificationsEnabled = true,
    this.theme = 'light',
  });

  @override
  List<Object?> get props => [currency, notificationsEnabled, theme];
}

/// Entidad de Usuario - representa el modelo de negocio puro
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String authProvider;
  final String? photoUrl;
  final UserPreferences preferences;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    required this.authProvider,
    this.photoUrl,
    required this.preferences,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    authProvider,
    photoUrl,
    preferences,
    createdAt,
  ];
}
