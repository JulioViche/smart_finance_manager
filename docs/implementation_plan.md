# Plan de Implementación: Clean Architecture - Smart Finance Manager

## 🎯 Resumen Ejecutivo

Este documento proporciona un plan paso a paso para migrar el proyecto Smart Finance Manager a Clean Architecture.

---

## 📊 Estado Actual vs Estado Deseado

### Estado Actual
```
lib/
├── firebase_options.dart
└── main.dart (código básico de Flutter)
```

### Estado Deseado
```
lib/
├── core/                    # Código compartido
├── features/                # Features organizadas por Clean Architecture
│   ├── authentication/
│   ├── transactions/
│   ├── categories/
│   └── budgets/
├── injection_container.dart # Dependency Injection
└── main.dart               # Punto de entrada
```

---

## 🚀 Plan de Implementación (10 Pasos)

### **Paso 1: Actualizar Dependencias** ⏱️ 10 min

Agregar al `pubspec.yaml`:

```yaml
dependencies:
  # State Management
  flutter_bloc: ^8.1.6
  equatable: ^2.0.5
  
  # Functional Programming
  dartz: ^0.10.1
  
  # Dependency Injection
  get_it: ^8.0.3
  
  # Firebase (ya existentes, verificar versiones)
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.3
  cloud_firestore: ^5.5.2
  
  # Utils
  intl: ^0.19.0

dev_dependencies:
  mockito: ^5.4.4
  bloc_test: ^9.1.7
```

**Comando:**
```bash
flutter pub get
```

---

### **Paso 2: Crear Estructura de Carpetas** ⏱️ 5 min

Ejecutar el script de PowerShell (ver `setup_clean_architecture.md`):

```powershell
cd d:\julio\Android\AndoridStudioProjects\smart_finance_manager\lib

# Core
New-Item -ItemType Directory -Force -Path "core\constants"
New-Item -ItemType Directory -Force -Path "core\errors"
New-Item -ItemType Directory -Force -Path "core\utils"
New-Item -ItemType Directory -Force -Path "core\widgets"

# Features (ejemplo con Transactions)
New-Item -ItemType Directory -Force -Path "features\transactions\data\datasources"
New-Item -ItemType Directory -Force -Path "features\transactions\data\models"
New-Item -ItemType Directory -Force -Path "features\transactions\data\repositories"
New-Item -ItemType Directory -Force -Path "features\transactions\domain\entities"
New-Item -ItemType Directory -Force -Path "features\transactions\domain\repositories"
New-Item -ItemType Directory -Force -Path "features\transactions\domain\usecases"
New-Item -ItemType Directory -Force -Path "features\transactions\presentation\bloc"
New-Item -ItemType Directory -Force -Path "features\transactions\presentation\pages"
New-Item -ItemType Directory -Force -Path "features\transactions\presentation\widgets"
```

---

### **Paso 3: Implementar Core - Errors** ⏱️ 15 min

**3.1. Crear `lib/core/errors/failures.dart`:**

```dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}
```

**3.2. Crear `lib/core/errors/exceptions.dart`:**

```dart
class ServerException implements Exception {
  final String message;
  ServerException({required this.message});
}

class CacheException implements Exception {
  final String message;
  CacheException({required this.message});
}
```

---

### **Paso 4: Implementar Feature Transactions - Domain Layer** ⏱️ 30 min

**4.1. Entity: `lib/features/transactions/domain/entities/transaction.dart`**

```dart
import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final String id;
  final double amount;
  final String categoryId;
  final DateTime date;
  final String type; // 'income' o 'expense'
  final String userId;
  final bool isDeleted;

  const Transaction({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.date,
    required this.type,
    required this.userId,
    this.isDeleted = false,
  });

  @override
  List<Object?> get props => [id, amount, categoryId, date, type, userId, isDeleted];
}
```

**4.2. Repository Interface: `lib/features/transactions/domain/repositories/transaction_repository.dart`**

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<Either<Failure, List<Transaction>>> getTransactions(String userId);
  Future<Either<Failure, void>> addTransaction(Transaction transaction);
  Future<Either<Failure, void>> deleteTransaction(String id);
}
```

**4.3. Use Cases:**

`lib/features/transactions/domain/usecases/get_transactions.dart`:
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class GetTransactions {
  final TransactionRepository repository;

  GetTransactions(this.repository);

  Future<Either<Failure, List<Transaction>>> call(String userId) async {
    return await repository.getTransactions(userId);
  }
}
```

`lib/features/transactions/domain/usecases/add_transaction.dart`:
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class AddTransaction {
  final TransactionRepository repository;

  AddTransaction(this.repository);

  Future<Either<Failure, void>> call(Transaction transaction) async {
    return await repository.addTransaction(transaction);
  }
}
```

---

### **Paso 5: Implementar Feature Transactions - Data Layer** ⏱️ 45 min

**5.1. Model: `lib/features/transactions/data/models/transaction_model.dart`**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.amount,
    required super.categoryId,
    required super.date,
    required super.type,
    required super.userId,
    super.isDeleted,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return TransactionModel(
      id: doc.id,
      amount: (data['amount'] as num).toDouble(),
      categoryId: data['category_id'] as String,
      date: (data['date'] as Timestamp).toDate(),
      type: data['type'] as String,
      userId: data['user_id'] as String,
      isDeleted: data['is_deleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'amount': amount,
      'category_id': categoryId,
      'date': Timestamp.fromDate(date),
      'type': type,
      'user_id': userId,
      'is_deleted': isDeleted,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  factory TransactionModel.fromEntity(Transaction transaction) {
    return TransactionModel(
      id: transaction.id,
      amount: transaction.amount,
      categoryId: transaction.categoryId,
      date: transaction.date,
      type: transaction.type,
      userId: transaction.userId,
      isDeleted: transaction.isDeleted,
    );
  }
}
```

**5.2. Data Source: `lib/features/transactions/data/datasources/transaction_remote_data_source.dart`**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/transaction_model.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransactionModel>> getTransactions(String userId);
  Future<void> addTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final FirebaseFirestore firestore;

  TransactionRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<TransactionModel>> getTransactions(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection('transactions')
          .where('user_id', isEqualTo: '/users/$userId')
          .where('is_deleted', isEqualTo: false)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      await firestore
          .collection('transactions')
          .doc(transaction.id)
          .set(transaction.toFirestore());
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      await firestore.collection('transactions').doc(id).update({
        'is_deleted': true,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
```

**5.3. Repository Implementation: `lib/features/transactions/data/repositories/transaction_repository_impl.dart`**

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_data_source.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;

  TransactionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions(String userId) async {
    try {
      final transactions = await remoteDataSource.getTransactions(userId);
      return Right(transactions);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> addTransaction(Transaction transaction) async {
    try {
      final transactionModel = TransactionModel.fromEntity(transaction);
      await remoteDataSource.addTransaction(transactionModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String id) async {
    try {
      await remoteDataSource.deleteTransaction(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
```

---

### **Paso 6: Implementar Feature Transactions - Presentation Layer** ⏱️ 45 min

**6.1. Events: `lib/features/transactions/presentation/bloc/transaction_event.dart`**

```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionEvent {
  final String userId;

  const LoadTransactions(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AddTransactionEvent extends TransactionEvent {
  final Transaction transaction;

  const AddTransactionEvent(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class DeleteTransactionEvent extends TransactionEvent {
  final String transactionId;

  const DeleteTransactionEvent(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}
```

**6.2. States: `lib/features/transactions/presentation/bloc/transaction_state.dart`**

```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions;

  const TransactionLoaded(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

class TransactionError extends TransactionState {
  final String message;

  const TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}

class TransactionSuccess extends TransactionState {
  final String message;

  const TransactionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
```

**6.3. BLoC: `lib/features/transactions/presentation/bloc/transaction_bloc.dart`**

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_transaction.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/get_transactions.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactions getTransactions;
  final AddTransaction addTransaction;
  final DeleteTransaction deleteTransaction;

  TransactionBloc({
    required this.getTransactions,
    required this.addTransaction,
    required this.deleteTransaction,
  }) : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransactionEvent>(_onAddTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());

    final result = await getTransactions(event.userId);

    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (transactions) => emit(TransactionLoaded(transactions)),
    );
  }

  Future<void> _onAddTransaction(
    AddTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    final result = await addTransaction(event.transaction);

    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (_) => emit(const TransactionSuccess('Transacción agregada')),
    );
  }

  Future<void> _onDeleteTransaction(
    DeleteTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    final result = await deleteTransaction(event.transactionId);

    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (_) => emit(const TransactionSuccess('Transacción eliminada')),
    );
  }
}
```

---

### **Paso 7: Configurar Dependency Injection** ⏱️ 20 min

**Crear `lib/injection_container.dart`:**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

// Transactions
import 'features/transactions/data/datasources/transaction_remote_data_source.dart';
import 'features/transactions/data/repositories/transaction_repository_impl.dart';
import 'features/transactions/domain/repositories/transaction_repository.dart';
import 'features/transactions/domain/usecases/add_transaction.dart';
import 'features/transactions/domain/usecases/delete_transaction.dart';
import 'features/transactions/domain/usecases/get_transactions.dart';
import 'features/transactions/presentation/bloc/transaction_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Transactions
  
  // Bloc
  sl.registerFactory(
    () => TransactionBloc(
      getTransactions: sl(),
      addTransaction: sl(),
      deleteTransaction: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetTransactions(sl()));
  sl.registerLazySingleton(() => AddTransaction(sl()));
  sl.registerLazySingleton(() => DeleteTransaction(sl()));

  // Repository
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<TransactionRemoteDataSource>(
    () => TransactionRemoteDataSourceImpl(firestore: sl()),
  );

  //! External
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
}
```

---

### **Paso 8: Actualizar main.dart** ⏱️ 10 min

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'injection_container.dart' as di;
import 'features/transactions/presentation/bloc/transaction_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<TransactionBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Smart Finance Manager',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Finance Manager'),
      ),
      body: const Center(
        child: Text('Clean Architecture implementada!'),
      ),
    );
  }
}
```

---

### **Paso 9: Verificar y Probar** ⏱️ 15 min

```bash
# Verificar que no hay errores
flutter analyze

# Ejecutar la app
flutter run
```

---

### **Paso 10: Repetir para Otras Features** ⏱️ Variable

Repetir los pasos 4-6 para:
- **Authentication** (usuarios, login con Google)
- **Categories** (categorías de gastos/ingresos)
- **Budgets** (presupuestos)

---

## 📋 Checklist de Implementación

- [ ] Paso 1: Actualizar dependencias
- [ ] Paso 2: Crear estructura de carpetas
- [ ] Paso 3: Implementar Core (errors)
- [ ] Paso 4: Implementar Transactions - Domain
- [ ] Paso 5: Implementar Transactions - Data
- [ ] Paso 6: Implementar Transactions - Presentation
- [ ] Paso 7: Configurar Dependency Injection
- [ ] Paso 8: Actualizar main.dart
- [ ] Paso 9: Verificar y probar
- [ ] Paso 10: Implementar otras features

---

## ⏱️ Estimación de Tiempo Total

- **Primera feature (Transactions)**: ~3-4 horas
- **Features adicionales**: ~2-3 horas cada una
- **Total estimado**: 10-15 horas

---

## 🎓 Recursos Adicionales

- **Guía completa**: Ver `clean_architecture_guide.md`
- **Script de setup**: Ver `setup_clean_architecture.md`
- **Diagrama**: Ver imagen generada de arquitectura

---

*Última actualización: 14 de enero de 2026*
