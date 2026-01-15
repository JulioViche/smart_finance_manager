// Domain - Update Budget Use Case
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/budget_entity.dart';
import '../repositories/budget_repository.dart';

/// Caso de uso para actualizar un presupuesto
class UpdateBudget {
  final BudgetRepository repository;

  UpdateBudget(this.repository);

  Future<Either<Failure, BudgetEntity>> call(BudgetEntity budget) {
    return repository.updateBudget(budget);
  }
}
