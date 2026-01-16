// Injection Container - Configuración de dependencias con GetIt
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Auth Feature
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/sign_in_with_email.dart';
import 'features/auth/domain/usecases/sign_in_with_google.dart';
import 'features/auth/domain/usecases/sign_out.dart';
import 'features/auth/domain/usecases/sign_up_with_email.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

// Transaction Feature
import 'features/transactions/data/datasources/transaction_remote_data_source.dart';
import 'features/transactions/data/repositories/transaction_repository_impl.dart';
import 'features/transactions/domain/repositories/transaction_repository.dart';
import 'features/transactions/domain/usecases/create_transaction.dart';
import 'features/transactions/domain/usecases/delete_transaction.dart';
import 'features/transactions/domain/usecases/get_transaction_by_id.dart';
import 'features/transactions/domain/usecases/get_transactions.dart';
import 'features/transactions/domain/usecases/update_transaction.dart';
import 'features/transactions/presentation/bloc/transaction_bloc.dart';

// Budget Feature
import 'features/budgets/data/datasources/budget_remote_data_source.dart';
import 'features/budgets/data/repositories/budget_repository_impl.dart';
import 'features/budgets/domain/repositories/budget_repository.dart';
import 'features/budgets/domain/usecases/create_budget.dart';
import 'features/budgets/domain/usecases/delete_budget.dart';
import 'features/budgets/domain/usecases/get_budgets.dart';
import 'features/budgets/domain/usecases/update_budget.dart';
import 'features/budgets/presentation/bloc/budget_bloc.dart';

// Core Services
import 'core/services/budget_alert_service.dart';
import 'core/services/category_service.dart';
import 'core/services/location_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/notification_storage_service.dart';

/// Instancia global del contenedor de dependencias
final sl = GetIt.instance;

/// Inicializa todas las dependencias
Future<void> initializeDependencies() async {
  //! =============================================
  //! AUTH FEATURE
  //! =============================================

  // BLoC
  sl.registerFactory(
    () => AuthBloc(
      signInWithEmail: sl(),
      signUpWithEmail: sl(),
      signInWithGoogle: sl(),
      signOut: sl(),
      getCurrentUser: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => SignInWithEmail(sl()));
  sl.registerLazySingleton(() => SignUpWithEmail(sl()));
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
      googleSignIn: sl(),
    ),
  );

  //! =============================================
  //! TRANSACTION FEATURE
  //! =============================================

  // BLoC
  sl.registerFactory(
    () => TransactionBloc(
      createTransaction: sl(),
      getTransactions: sl(),
      getTransactionById: sl(),
      updateTransaction: sl(),
      deleteTransaction: sl(),
      budgetAlertService: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => CreateTransaction(sl()));
  sl.registerLazySingleton(() => GetTransactions(sl()));
  sl.registerLazySingleton(() => GetTransactionById(sl()));
  sl.registerLazySingleton(() => UpdateTransaction(sl()));
  sl.registerLazySingleton(() => DeleteTransaction(sl()));

  // Repository
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<TransactionRemoteDataSource>(
    () => TransactionRemoteDataSourceImpl(firestore: sl()),
  );

  //! =============================================
  //! BUDGET FEATURE
  //! =============================================

  // BLoC
  sl.registerFactory(
    () => BudgetBloc(
      createBudget: sl(),
      getBudgets: sl(),
      updateBudget: sl(),
      deleteBudget: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => CreateBudget(sl()));
  sl.registerLazySingleton(() => GetBudgets(sl()));
  sl.registerLazySingleton(() => UpdateBudget(sl()));
  sl.registerLazySingleton(() => DeleteBudget(sl()));

  // Repository
  sl.registerLazySingleton<BudgetRepository>(
    () => BudgetRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<BudgetRemoteDataSource>(
    () => BudgetRemoteDataSourceImpl(firestore: sl()),
  );

  //! =============================================
  //! CORE SERVICES
  //! =============================================

  // Notification Storage Service
  sl.registerLazySingleton<NotificationStorageService>(
    () => NotificationStorageService(),
  );

  // Category Service
  sl.registerLazySingleton<CategoryService>(
    () => CategoryService(firestore: sl<FirebaseFirestore>()),
  );

  // Location Service
  sl.registerLazySingleton<LocationService>(() => LocationService());
  
  // Notification Service
  sl.registerLazySingleton<NotificationService>(() {
    final notificationService = NotificationService();
    notificationService.setStorageService(sl<NotificationStorageService>());
    return notificationService;
  });

  // Budget Alert Service
  sl.registerLazySingleton<BudgetAlertService>(
    () => BudgetAlertService(
      firestore: sl<FirebaseFirestore>(),
      notificationService: sl<NotificationService>(),
      categoryService: sl<CategoryService>(),
    ),
  );

  //! =============================================
  //! EXTERNAL (Firebase, etc.)
  //! =============================================

  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());
}

