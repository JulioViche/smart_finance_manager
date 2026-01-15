// Domain Layer - Transaction Repository Interface
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transaction_entity.dart';

/// Parámetros de filtro para obtener transacciones
class TransactionFilterParams {
  final String? userId;
  final DateTime? startDate;
  final DateTime? endDate;
  final TransactionType? type;
  final String? categoryId;
  final bool includeDeleted;

  const TransactionFilterParams({
    this.userId,
    this.startDate,
    this.endDate,
    this.type,
    this.categoryId,
    this.includeDeleted = false,
  });
}

/// Contrato del repositorio de transacciones
/// Define las operaciones CRUD sin importar la implementación
abstract class TransactionRepository {
  /// Crea una nueva transacción
  Future<Either<Failure, TransactionEntity>> createTransaction(
    TransactionEntity transaction,
  );

  /// Obtiene lista de transacciones con filtros opcionales
  Future<Either<Failure, List<TransactionEntity>>> getTransactions(
    TransactionFilterParams params,
  );

  /// Obtiene una transacción por su ID
  Future<Either<Failure, TransactionEntity>> getTransactionById(String id);

  /// Actualiza una transacción existente
  Future<Either<Failure, TransactionEntity>> updateTransaction(
    TransactionEntity transaction,
  );

  /// Elimina una transacción (soft delete: is_deleted = true)
  Future<Either<Failure, void>> deleteTransaction(String id);

  /// Stream de transacciones para actualizaciones en tiempo real
  Stream<List<TransactionEntity>> watchTransactions(
    TransactionFilterParams params,
  );
}
