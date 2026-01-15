// Domain Layer - Auth Repository Interface
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

/// Contrato del repositorio de autenticación
/// Define las operaciones disponibles sin importar la implementación
abstract class AuthRepository {
  /// Inicia sesión con email y contraseña
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Registra un nuevo usuario con email y contraseña
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  /// Inicia sesión con Google
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Cierra sesión
  Future<Either<Failure, void>> signOut();

  /// Obtiene el usuario actual (si está autenticado)
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Stream del estado de autenticación
  Stream<UserEntity?> get authStateChanges;
}
