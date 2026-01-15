// Data Layer - User Model
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

/// Modelo de preferencias del usuario para Firestore
class UserPreferencesModel extends UserPreferences {
  const UserPreferencesModel({
    super.currency,
    super.notificationsEnabled,
    super.theme,
  });

  /// Crear desde Map de Firestore
  factory UserPreferencesModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const UserPreferencesModel();
    }
    return UserPreferencesModel(
      currency: map['currency'] as String? ?? 'USD',
      notificationsEnabled: map['notifications_enabled'] as bool? ?? true,
      theme: map['theme'] as String? ?? 'light',
    );
  }

  /// Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'currency': currency,
      'notifications_enabled': notificationsEnabled,
      'theme': theme,
    };
  }

  /// Crear desde entidad
  factory UserPreferencesModel.fromEntity(UserPreferences entity) {
    return UserPreferencesModel(
      currency: entity.currency,
      notificationsEnabled: entity.notificationsEnabled,
      theme: entity.theme,
    );
  }
}

/// Modelo de Usuario para Firestore
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.displayName,
    required super.authProvider,
    super.photoUrl,
    required UserPreferencesModel preferences,
    required super.createdAt,
  }) : super(preferences: preferences);

  /// Crear desde DocumentSnapshot de Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['display_name'] as String? ?? '',
      authProvider: data['auth_provider'] as String? ?? 'email',
      photoUrl: data['photo_url'] as String?,
      preferences: UserPreferencesModel.fromMap(
        data['preferences'] as Map<String, dynamic>?,
      ),
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convertir a Map para guardar en Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'display_name': displayName,
      'auth_provider': authProvider,
      'photo_url': photoUrl,
      'preferences': (preferences as UserPreferencesModel).toMap(),
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  /// Crear desde entidad
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      authProvider: entity.authProvider,
      photoUrl: entity.photoUrl,
      preferences: UserPreferencesModel.fromEntity(entity.preferences),
      createdAt: entity.createdAt,
    );
  }
}
