// Domain - Get Budgets Use Case
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/budget_entity.dart';
import '../repositories/budget_repository.dart';

/// Caso de uso para obtener presupuestos
class GetBudgets {
  final BudgetRepository repository;

  GetBudgets(this.repository);

  Future<Either<Failure, List<BudgetEntity>>> call(BudgetFilterParams params) {
    return repository.getBudgets(params);
  }
}
