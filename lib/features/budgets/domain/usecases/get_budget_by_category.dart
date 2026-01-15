// Domain - Get Budget By Category Use Case
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/budget_entity.dart';
import '../repositories/budget_repository.dart';

/// Parámetros para obtener presupuesto por categoría
class GetBudgetByCategoryParams {
  final String userId;
  final String categoryId;

  const GetBudgetByCategoryParams({
    required this.userId,
    required this.categoryId,
  });
}

/// Caso de uso para obtener el presupuesto de una categoría
class GetBudgetByCategory {
  final BudgetRepository repository;

  GetBudgetByCategory(this.repository);

  Future<Either<Failure, BudgetEntity?>> call(GetBudgetByCategoryParams params) {
    return repository.getBudgetByCategory(
      userId: params.userId,
      categoryId: params.categoryId,
    );
  }
}
