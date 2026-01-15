// Data Layer - Auth Remote Data Source
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

/// Interfaz del data source remoto para autenticación
abstract class AuthRemoteDataSource {
  /// Iniciar sesión con email y contraseña
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });

  /// Registrar usuario con email y contraseña
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  /// Iniciar sesión con Google
  Future<UserModel> signInWithGoogle();

  /// Cerrar sesión
  Future<void> signOut();

  /// Obtener usuario actual
  Future<UserModel?> getCurrentUser();

  /// Stream del estado de autenticación
  Stream<UserModel?> get authStateChanges;
}

/// Implementación del data source con Firebase
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
    required this.googleSignIn,
  });

  /// Referencia a la colección de usuarios
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      firestore.collection('users');

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw AuthException(message: 'No se pudo iniciar sesión');
      }

      // Obtener datos del usuario desde Firestore
      return await _getUserFromFirestore(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _mapFirebaseAuthError(e.code));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(message: 'Error al iniciar sesión: $e');
    }
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw AuthException(message: 'No se pudo crear la cuenta');
      }

      // Actualizar displayName en Firebase Auth
      await credential.user!.updateDisplayName(displayName);

      // Crear el documento del usuario en Firestore
      final userModel = UserModel(
        id: credential.user!.uid,
        email: email,
        displayName: displayName,
        authProvider: 'email',
        photoUrl: null,
        preferences: const UserPreferencesModel(),
        createdAt: DateTime.now(),
      );

      await _usersCollection
          .doc(credential.user!.uid)
          .set(userModel.toFirestore());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _mapFirebaseAuthError(e.code));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(message: 'Error al crear la cuenta: $e');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // Iniciar flujo de Google Sign In
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw AuthException(message: 'Inicio de sesión cancelado');
      }

      // Obtener credenciales de autenticación
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // In google_sign_in v7.0.0+, accessToken and idToken are nullable String?
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      // Iniciar sesión en Firebase con las credenciales de Google
      final userCredential = await firebaseAuth.signInWithCredential(
        credential,
      );

      if (userCredential.user == null) {
        throw AuthException(message: 'No se pudo iniciar sesión con Google');
      }

      final user = userCredential.user!;

      // Verificar si el usuario ya existe en Firestore
      final userDoc = await _usersCollection.doc(user.uid).get();

      if (!userDoc.exists) {
        // Crear nuevo usuario en Firestore
        final userModel = UserModel(
          id: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? '',
          authProvider: 'google',
          photoUrl: user.photoURL,
          preferences: const UserPreferencesModel(),
          createdAt: DateTime.now(),
        );

        await _usersCollection.doc(user.uid).set(userModel.toFirestore());
        return userModel;
      }

      return UserModel.fromFirestore(userDoc);
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _mapFirebaseAuthError(e.code));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(message: 'Error al iniciar sesión con Google: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([firebaseAuth.signOut(), googleSignIn.signOut()]);
    } catch (e) {
      throw AuthException(message: 'Error al cerrar sesión: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return null;

      return await _getUserFromFirestore(user.uid);
    } catch (e) {
      throw AuthException(message: 'Error al obtener usuario: $e');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      try {
        return await _getUserFromFirestore(user.uid);
      } catch (e) {
        return null;
      }
    });
  }

  /// Obtiene el usuario desde Firestore
  Future<UserModel> _getUserFromFirestore(String uid) async {
    final doc = await _usersCollection.doc(uid).get();

    if (!doc.exists) {
      throw AuthException(message: 'Usuario no encontrado en la base de datos');
    }

    return UserModel.fromFirestore(doc);
  }

  /// Mapea códigos de error de Firebase a mensajes amigables
  String _mapFirebaseAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No existe una cuenta con este correo';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo';
      case 'invalid-email':
        return 'Correo electrónico inválido';
      case 'weak-password':
        return 'La contraseña es muy débil';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      case 'operation-not-allowed':
        return 'Operación no permitida';
      case 'invalid-credential':
        return 'Credenciales inválidas';
      default:
        return 'Error de autenticación: $code';
    }
  }
}
