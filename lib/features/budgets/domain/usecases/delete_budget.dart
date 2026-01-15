// Domain - Delete Budget Use Case
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/budget_repository.dart';

/// Caso de uso para eliminar un presupuesto
class DeleteBudget {
  final BudgetRepository repository;

  DeleteBudget(this.repository);

  Future<Either<Failure, void>> call(String budgetId) {
    return repository.deleteBudget(budgetId);
  }
}
