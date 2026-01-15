// Domain Layer - Get Transaction By ID Use Case
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

/// Caso de uso para obtener una transacción por ID
class GetTransactionById {
  final TransactionRepository repository;

  GetTransactionById(this.repository);

  Future<Either<Failure, TransactionEntity>> call(String id) async {
    return await repository.getTransactionById(id);
  }
}
