// Domain Layer - Get Transactions Use Case
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

/// Caso de uso para obtener lista de transacciones con filtros
class GetTransactions {
  final TransactionRepository repository;

  GetTransactions(this.repository);

  Future<Either<Failure, List<TransactionEntity>>> call(
    TransactionFilterParams params,
  ) async {
    return await repository.getTransactions(params);
  }
}
