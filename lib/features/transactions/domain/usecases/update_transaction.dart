// Domain Layer - Update Transaction Use Case
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

/// Caso de uso para actualizar una transacción existente
class UpdateTransaction {
  final TransactionRepository repository;

  UpdateTransaction(this.repository);

  Future<Either<Failure, TransactionEntity>> call(
    TransactionEntity transaction,
  ) async {
    return await repository.updateTransaction(transaction);
  }
}
