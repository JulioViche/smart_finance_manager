# Guía de Implementación: Clean Architecture en Smart Finance Manager

## 📋 Índice
1. [Introducción a Clean Architecture](#introducción)
2. [Estructura de Carpetas](#estructura-de-carpetas)
3. [Capas de la Arquitectura](#capas-de-la-arquitectura)
4. [Implementación Paso a Paso](#implementación-paso-a-paso)
5. [Ejemplos Prácticos](#ejemplos-prácticos)
6. [Dependencias Necesarias](#dependencias-necesarias)
7. [Mejores Prácticas](#mejores-prácticas)

---

## 🎯 Introducción

**Clean Architecture** es un patrón arquitectónico que separa el código en capas con responsabilidades bien definidas, facilitando:

- ✅ **Mantenibilidad**: Código más fácil de mantener y modificar
- ✅ **Testabilidad**: Cada capa puede ser testeada independientemente
- ✅ **Escalabilidad**: Fácil agregar nuevas funcionalidades
- ✅ **Independencia**: Las capas no dependen de frameworks específicos

### Principio de Dependencia

```
Presentation → Domain ← Data
```

- **Presentation** depende de **Domain**
- **Data** depende de **Domain**
- **Domain** NO depende de nadie (núcleo puro)

---

## 📁 Estructura de Carpetas

```
lib/
├── core/                          # Código compartido entre features
│   ├── constants/                 # Constantes globales
│   │   ├── app_constants.dart
│   │   └── firebase_constants.dart
│   ├── errors/                    # Manejo de errores
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/                   # Configuración de red
│   │   └── network_info.dart
│   ├── theme/                     # Temas de la app
│   │   ├── app_theme.dart
│   │   └── app_colors.dart
│   ├── utils/                     # Utilidades
│   │   ├── date_formatter.dart
│   │   └── validators.dart
│   └── widgets/                   # Widgets reutilizables
│       ├── custom_button.dart
│       └── loading_indicator.dart
│
├── features/                      # Características de la app
│   │
│   ├── authentication/            # Feature: Autenticación
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_data_source.dart
│   │   │   │   └── auth_local_data_source.dart
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── sign_in_with_google.dart
│   │   │       ├── sign_out.dart
│   │   │       └── get_current_user.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── auth_bloc.dart
│   │       │   ├── auth_event.dart
│   │       │   └── auth_state.dart
│   │       ├── pages/
│   │       │   ├── login_page.dart
│   │       │   └── splash_page.dart
│   │       └── widgets/
│   │           └── google_sign_in_button.dart
│   │
│   ├── transactions/              # Feature: Transacciones
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── transaction_remote_data_source.dart
│   │   │   ├── models/
│   │   │   │   └── transaction_model.dart
│   │   │   └── repositories/
│   │   │       └── transaction_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── transaction.dart
│   │   │   ├── repositories/
│   │   │   │   └── transaction_repository.dart
│   │   │   └── usecases/
│   │   │       ├── add_transaction.dart
│   │   │       ├── get_transactions.dart
│   │   │       ├── update_transaction.dart
│   │   │       └── delete_transaction.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── transaction_bloc.dart
│   │       │   ├── transaction_event.dart
│   │       │   └── transaction_state.dart
│   │       ├── pages/
│   │       │   ├── transactions_list_page.dart
│   │       │   └── add_transaction_page.dart
│   │       └── widgets/
│   │           ├── transaction_card.dart
│   │           └── transaction_form.dart
│   │
│   ├── categories/                # Feature: Categorías
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── category_remote_data_source.dart
│   │   │   ├── models/
│   │   │   │   └── category_model.dart
│   │   │   └── repositories/
│   │   │       └── category_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── category.dart
│   │   │   ├── repositories/
│   │   │   │   └── category_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_categories.dart
│   │   │       ├── add_category.dart
│   │   │       └── update_category.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── category_bloc.dart
│   │       │   ├── category_event.dart
│   │       │   └── category_state.dart
│   │       ├── pages/
│   │       │   └── categories_page.dart
│   │       └── widgets/
│   │           └── category_item.dart
│   │
│   └── budgets/                   # Feature: Presupuestos
│       ├── data/
│       │   ├── datasources/
│       │   │   └── budget_remote_data_source.dart
│       │   ├── models/
│       │   │   └── budget_model.dart
│       │   └── repositories/
│       │       └── budget_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── budget.dart
│       │   ├── repositories/
│       │   │   └── budget_repository.dart
│       │   └── usecases/
│       │       ├── create_budget.dart
│       │       ├── get_budgets.dart
│       │       └── check_budget_alert.dart
│       └── presentation/
│           ├── bloc/
│           │   ├── budget_bloc.dart
│           │   ├── budget_event.dart
│           │   └── budget_state.dart
│           ├── pages/
│           │   └── budgets_page.dart
│           └── widgets/
│               └── budget_card.dart
│
├── injection_container.dart       # Configuración de inyección de dependencias
└── main.dart                      # Punto de entrada
```

---

## 🏗️ Capas de la Arquitectura

### 1. **Domain Layer** (Capa de Dominio)

**Responsabilidad**: Contiene la lógica de negocio pura, independiente de frameworks.

#### Componentes:

##### **Entities** (Entidades)
Objetos de negocio puros sin dependencias externas.

```dart
// lib/features/transactions/domain/entities/transaction.dart
import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final String id;
  final double amount;
  final String categoryId;
  final DateTime date;
  final String type; // 'income' o 'expense'
  final String userId;
  final bool isDeleted;
  final String? receiptImagePath;
  final GeoPoint? location;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Transaction({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.date,
    required this.type,
    required this.userId,
    this.isDeleted = false,
    this.receiptImagePath,
    this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        amount,
        categoryId,
        date,
        type,
        userId,
        isDeleted,
        receiptImagePath,
        location,
        createdAt,
        updatedAt,
      ];
}

class GeoPoint extends Equatable {
  final double latitude;
  final double longitude;

  const GeoPoint({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}
```

##### **Repositories** (Interfaces)
Contratos que definen qué operaciones están disponibles.

```dart
// lib/features/transactions/domain/repositories/transaction_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<Either<Failure, List<Transaction>>> getTransactions(String userId);
  Future<Either<Failure, Transaction>> getTransactionById(String id);
  Future<Either<Failure, void>> addTransaction(Transaction transaction);
  Future<Either<Failure, void>> updateTransaction(Transaction transaction);
  Future<Either<Failure, void>> deleteTransaction(String id);
  Stream<List<Transaction>> watchTransactions(String userId);
}
```

##### **Use Cases** (Casos de Uso)
Lógica de negocio específica para cada acción.

```dart
// lib/features/transactions/domain/usecases/add_transaction.dart
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

```dart
// lib/features/transactions/domain/usecases/get_transactions.dart
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

---

### 2. **Data Layer** (Capa de Datos)

**Responsabilidad**: Implementa los repositorios y maneja fuentes de datos.

#### Componentes:

##### **Models** (Modelos)
Extensiones de entidades con métodos de serialización.

```dart
// lib/features/transactions/data/models/transaction_model.dart
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
    super.receiptImagePath,
    super.location,
    required super.createdAt,
    required super.updatedAt,
  });

  // Convertir desde Firestore
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
      receiptImagePath: data['receipt_image_path'] as String?,
      location: data['location'] != null
          ? GeoPoint(
              latitude: (data['location'] as GeoPoint).latitude,
              longitude: (data['location'] as GeoPoint).longitude,
            )
          : null,
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
    );
  }

  // Convertir a Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'amount': amount,
      'category_id': categoryId,
      'date': Timestamp.fromDate(date),
      'type': type,
      'user_id': userId,
      'is_deleted': isDeleted,
      'receipt_image_path': receiptImagePath ?? 'none',
      'location': location != null
          ? FirebaseGeoPoint(location!.latitude, location!.longitude)
          : null,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  // Convertir desde entidad
  factory TransactionModel.fromEntity(Transaction transaction) {
    return TransactionModel(
      id: transaction.id,
      amount: transaction.amount,
      categoryId: transaction.categoryId,
      date: transaction.date,
      type: transaction.type,
      userId: transaction.userId,
      isDeleted: transaction.isDeleted,
      receiptImagePath: transaction.receiptImagePath,
      location: transaction.location,
      createdAt: transaction.createdAt,
      updatedAt: transaction.updatedAt,
    );
  }
}
```

##### **Data Sources** (Fuentes de Datos)
Interactúan directamente con APIs, bases de datos, etc.

```dart
// lib/features/transactions/data/datasources/transaction_remote_data_source.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransactionModel>> getTransactions(String userId);
  Future<TransactionModel> getTransactionById(String id);
  Future<void> addTransaction(TransactionModel transaction);
  Future<void> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
  Stream<List<TransactionModel>> watchTransactions(String userId);
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
  Future<TransactionModel> getTransactionById(String id) async {
    try {
      final doc = await firestore.collection('transactions').doc(id).get();
      
      if (!doc.exists) {
        throw ServerException(message: 'Transaction not found');
      }

      return TransactionModel.fromFirestore(doc);
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
  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      await firestore
          .collection('transactions')
          .doc(transaction.id)
          .update(transaction.toFirestore());
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      // Soft delete
      await firestore.collection('transactions').doc(id).update({
        'is_deleted': true,
        'updated_at': Timestamp.now(),
      });
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Stream<List<TransactionModel>> watchTransactions(String userId) {
    return firestore
        .collection('transactions')
        .where('user_id', isEqualTo: '/users/$userId')
        .where('is_deleted', isEqualTo: false)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromFirestore(doc))
            .toList());
  }
}
```

##### **Repository Implementation** (Implementación del Repositorio)
Implementa la interfaz del dominio.

```dart
// lib/features/transactions/data/repositories/transaction_repository_impl.dart
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
  Future<Either<Failure, List<Transaction>>> getTransactions(
      String userId) async {
    try {
      final transactions = await remoteDataSource.getTransactions(userId);
      return Right(transactions);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, Transaction>> getTransactionById(String id) async {
    try {
      final transaction = await remoteDataSource.getTransactionById(id);
      return Right(transaction);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error occurred'));
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
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> updateTransaction(
      Transaction transaction) async {
    try {
      final transactionModel = TransactionModel.fromEntity(transaction);
      await remoteDataSource.updateTransaction(transactionModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String id) async {
    try {
      await remoteDataSource.deleteTransaction(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error occurred'));
    }
  }

  @override
  Stream<List<Transaction>> watchTransactions(String userId) {
    return remoteDataSource.watchTransactions(userId);
  }
}
```

---

### 3. **Presentation Layer** (Capa de Presentación)

**Responsabilidad**: Maneja la UI y el estado de la aplicación.

#### Componentes:

##### **BLoC** (Business Logic Component)

**Events:**
```dart
// lib/features/transactions/presentation/bloc/transaction_event.dart
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

class UpdateTransactionEvent extends TransactionEvent {
  final Transaction transaction;

  const UpdateTransactionEvent(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class DeleteTransactionEvent extends TransactionEvent {
  final String transactionId;

  const DeleteTransactionEvent(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

class WatchTransactions extends TransactionEvent {
  final String userId;

  const WatchTransactions(this.userId);

  @override
  List<Object?> get props => [userId];
}
```

**States:**
```dart
// lib/features/transactions/presentation/bloc/transaction_state.dart
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

class TransactionActionSuccess extends TransactionState {
  final String message;

  const TransactionActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
```

**BLoC:**
```dart
// lib/features/transactions/presentation/bloc/transaction_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_transaction.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/get_transactions.dart';
import '../../domain/usecases/update_transaction.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactions getTransactions;
  final AddTransaction addTransaction;
  final UpdateTransaction updateTransaction;
  final DeleteTransaction deleteTransaction;

  StreamSubscription? _transactionSubscription;

  TransactionBloc({
    required this.getTransactions,
    required this.addTransaction,
    required this.updateTransaction,
    required this.deleteTransaction,
  }) : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransactionEvent>(_onAddTransaction);
    on<UpdateTransactionEvent>(_onUpdateTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
    on<WatchTransactions>(_onWatchTransactions);
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
      (_) => emit(const TransactionActionSuccess('Transacción agregada')),
    );
  }

  Future<void> _onUpdateTransaction(
    UpdateTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    final result = await updateTransaction(event.transaction);

    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (_) => emit(const TransactionActionSuccess('Transacción actualizada')),
    );
  }

  Future<void> _onDeleteTransaction(
    DeleteTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    final result = await deleteTransaction(event.transactionId);

    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (_) => emit(const TransactionActionSuccess('Transacción eliminada')),
    );
  }

  Future<void> _onWatchTransactions(
    WatchTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());

    await _transactionSubscription?.cancel();
    
    // Aquí necesitarías un usecase que retorne un Stream
    // _transactionSubscription = watchTransactionsUseCase(event.userId).listen(
    //   (transactions) => emit(TransactionLoaded(transactions)),
    //   onError: (error) => emit(TransactionError(error.toString())),
    // );
  }

  @override
  Future<void> close() {
    _transactionSubscription?.cancel();
    return super.close();
  }
}
```

##### **Pages:**
```dart
// lib/features/transactions/presentation/pages/transactions_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../widgets/transaction_card.dart';

class TransactionsListPage extends StatelessWidget {
  final String userId;

  const TransactionsListPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transacciones'),
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TransactionError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<TransactionBloc>()
                          .add(LoadTransactions(userId));
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is TransactionLoaded) {
            if (state.transactions.isEmpty) {
              return const Center(
                child: Text('No hay transacciones'),
              );
            }

            return ListView.builder(
              itemCount: state.transactions.length,
              itemBuilder: (context, index) {
                return TransactionCard(
                  transaction: state.transactions[index],
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar a página de agregar transacción
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

---

## 🔧 Core Components

### Failures (Manejo de Errores)

```dart
// lib/core/errors/failures.dart
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

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}
```

### Exceptions

```dart
// lib/core/errors/exceptions.dart
class ServerException implements Exception {
  final String message;

  ServerException({required this.message});
}

class CacheException implements Exception {
  final String message;

  CacheException({required this.message});
}

class NetworkException implements Exception {
  final String message;

  NetworkException({required this.message});
}
```

---

## 💉 Dependency Injection

```dart
// lib/injection_container.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

// Features - Transactions
import 'features/transactions/data/datasources/transaction_remote_data_source.dart';
import 'features/transactions/data/repositories/transaction_repository_impl.dart';
import 'features/transactions/domain/repositories/transaction_repository.dart';
import 'features/transactions/domain/usecases/add_transaction.dart';
import 'features/transactions/domain/usecases/delete_transaction.dart';
import 'features/transactions/domain/usecases/get_transactions.dart';
import 'features/transactions/domain/usecases/update_transaction.dart';
import 'features/transactions/presentation/bloc/transaction_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Transactions
  
  // Bloc
  sl.registerFactory(
    () => TransactionBloc(
      getTransactions: sl(),
      addTransaction: sl(),
      updateTransaction: sl(),
      deleteTransaction: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetTransactions(sl()));
  sl.registerLazySingleton(() => AddTransaction(sl()));
  sl.registerLazySingleton(() => UpdateTransaction(sl()));
  sl.registerLazySingleton(() => DeleteTransaction(sl()));

  // Repository
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<TransactionRemoteDataSource>(
    () => TransactionRemoteDataSourceImpl(firestore: sl()),
  );

  //! Core

  //! External
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
}
```

### Main.dart actualizado

```dart
// lib/main.dart
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
        // Agregar más BlocProviders aquí
      ],
      child: MaterialApp(
        title: 'Smart Finance Manager',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}
```

---

## 📦 Dependencias Necesarias

Agrega estas dependencias a tu `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.3
  cloud_firestore: ^5.5.2
  
  # State Management
  flutter_bloc: ^8.1.6
  equatable: ^2.0.5
  
  # Functional Programming
  dartz: ^0.10.1
  
  # Dependency Injection
  get_it: ^8.0.3
  
  # Utils
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  bloc_test: ^9.1.7
```

---

## ✅ Mejores Prácticas

### 1. **Separación de Responsabilidades**
- Cada capa tiene una responsabilidad única
- No mezclar lógica de UI con lógica de negocio

### 2. **Inyección de Dependencias**
- Usar `get_it` para gestionar dependencias
- Facilita el testing y el mantenimiento

### 3. **Manejo de Errores**
- Usar `Either` de `dartz` para manejar errores
- Crear `Failures` específicos para cada tipo de error

### 4. **Testing**
- Cada capa debe ser testeable independientemente
- Usar mocks para las dependencias

### 5. **Nomenclatura Consistente**
- Seguir convenciones de nombres claras
- Usar sufijos descriptivos (`_bloc`, `_event`, `_state`, etc.)

### 6. **Inmutabilidad**
- Usar `const` cuando sea posible
- Usar `Equatable` para comparaciones de objetos

---

## 🚀 Pasos para Implementar

1. **Crear estructura de carpetas**
2. **Implementar Core (errors, utils)**
3. **Implementar Domain layer** (entities, repositories, use cases)
4. **Implementar Data layer** (models, data sources, repository impl)
5. **Implementar Presentation layer** (bloc, pages, widgets)
6. **Configurar Dependency Injection**
7. **Actualizar main.dart**
8. **Escribir tests**

---

*Última actualización: 14 de enero de 2026*
