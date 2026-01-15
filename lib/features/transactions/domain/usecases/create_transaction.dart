// Domain Layer - Create Transaction Use Case
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

/// Caso de uso para crear una nueva transacción
class CreateTransaction {
  final TransactionRepository repository;

  CreateTransaction(this.repository);

  Future<Either<Failure, TransactionEntity>> call(
    TransactionEntity transaction,
  ) async {
    return await repository.createTransaction(transaction);
  }
}
