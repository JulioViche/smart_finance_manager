// Domain - Create Budget Use Case
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/budget_entity.dart';
import '../repositories/budget_repository.dart';

/// Caso de uso para crear un presupuesto
class CreateBudget {
  final BudgetRepository repository;

  CreateBudget(this.repository);

  Future<Either<Failure, BudgetEntity>> call(BudgetEntity budget) {
    return repository.createBudget(budget);
  }
}
