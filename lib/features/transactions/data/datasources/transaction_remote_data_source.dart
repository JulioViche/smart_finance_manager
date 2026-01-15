// Data Layer - Transaction Remote Data Source
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../models/transaction_model.dart';

/// Interfaz del data source remoto para transacciones
abstract class TransactionRemoteDataSource {
  /// Crea una nueva transacción
  Future<TransactionModel> createTransaction(TransactionEntity transaction);

  /// Obtiene lista de transacciones con filtros
  Future<List<TransactionModel>> getTransactions(TransactionFilterParams params);

  /// Obtiene una transacción por ID
  Future<TransactionModel> getTransactionById(String id);

  /// Actualiza una transacción
  Future<TransactionModel> updateTransaction(TransactionEntity transaction);

  /// Elimina una transacción (soft delete)
  Future<void> deleteTransaction(String id);

  /// Stream de transacciones en tiempo real
  Stream<List<TransactionModel>> watchTransactions(TransactionFilterParams params);
}

/// Implementación del data source con Firebase Firestore
class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final FirebaseFirestore firestore;

  TransactionRemoteDataSourceImpl({required this.firestore});

  /// Referencia a la colección de transacciones
  CollectionReference<Map<String, dynamic>> get _transactionsCollection =>
      firestore.collection('transactions');

  @override
  Future<TransactionModel> createTransaction(TransactionEntity transaction) async {
    try {
      final now = DateTime.now();
      final model = TransactionModel(
        id: '', // Se generará automáticamente
        amount: transaction.amount,
        categoryId: transaction.categoryId,
        createdAt: now,
        date: transaction.date,
        isDeleted: false,
        location: TransactionLocationModel.fromEntity(transaction.location),
        receiptImagePath: transaction.receiptImagePath,
        type: transaction.type,
        updatedAt: now,
        userId: transaction.userId,
      );

      final docRef = await _transactionsCollection.add(model.toFirestore());
      final createdDoc = await docRef.get();

      return TransactionModel.fromFirestore(createdDoc);
    } catch (e) {
      throw ServerException(message: 'Error al crear transacción: $e');
    }
  }

  @override
  Future<List<TransactionModel>> getTransactions(
    TransactionFilterParams params,
  ) async {
    try {
      Query<Map<String, dynamic>> query = _transactionsCollection;

      // Filtrar por usuario
      if (params.userId != null) {
        query = query.where('user_id', isEqualTo: params.userId);
      }

      // Filtrar por tipo
      if (params.type != null) {
        query = query.where('type', isEqualTo: params.type!.name);
      }

      // Filtrar por categoría
      if (params.categoryId != null) {
        query = query.where('category_id', isEqualTo: params.categoryId);
      }

      // Excluir eliminados por defecto
      if (!params.includeDeleted) {
        query = query.where('is_deleted', isEqualTo: false);
      }

      // Ordenar por fecha descendente
      query = query.orderBy('date', descending: true);

      final snapshot = await query.get();

      List<TransactionModel> transactions = snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();

      // Filtrar por rango de fechas en memoria (Firestore no permite múltiples orderBy con where)
      if (params.startDate != null) {
        transactions = transactions
            .where((t) => t.date.isAfter(params.startDate!) || 
                         t.date.isAtSameMomentAs(params.startDate!))
            .toList();
      }
      if (params.endDate != null) {
        transactions = transactions
            .where((t) => t.date.isBefore(params.endDate!) || 
                         t.date.isAtSameMomentAs(params.endDate!))
            .toList();
      }

      return transactions;
    } catch (e) {
      throw ServerException(message: 'Error al obtener transacciones: $e');
    }
  }

  @override
  Future<TransactionModel> getTransactionById(String id) async {
    try {
      final doc = await _transactionsCollection.doc(id).get();

      if (!doc.exists) {
        throw ServerException(message: 'Transacción no encontrada');
      }

      return TransactionModel.fromFirestore(doc);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Error al obtener transacción: $e');
    }
  }

  @override
  Future<TransactionModel> updateTransaction(TransactionEntity transaction) async {
    try {
      final model = TransactionModel.forUpdate(transaction);

      await _transactionsCollection.doc(transaction.id).update(model.toFirestore());

      final updatedDoc = await _transactionsCollection.doc(transaction.id).get();
      return TransactionModel.fromFirestore(updatedDoc);
    } catch (e) {
      throw ServerException(message: 'Error al actualizar transacción: $e');
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      // Soft delete: solo marcamos como eliminado
      await _transactionsCollection.doc(id).update({
        'is_deleted': true,
        'updated_at': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw ServerException(message: 'Error al eliminar transacción: $e');
    }
  }

  @override
  Stream<List<TransactionModel>> watchTransactions(
    TransactionFilterParams params,
  ) {
    Query<Map<String, dynamic>> query = _transactionsCollection;

    // Filtrar por usuario
    if (params.userId != null) {
      query = query.where('user_id', isEqualTo: params.userId);
    }

    // Excluir eliminados por defecto
    if (!params.includeDeleted) {
      query = query.where('is_deleted', isEqualTo: false);
    }

    // Ordenar por fecha descendente
    query = query.orderBy('date', descending: true);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => TransactionModel.fromFirestore(doc)).toList();
    });
  }
}
