// Domain - Budget Repository Interface
// Contrato para el repositorio de presupuestos
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/budget_entity.dart';

/// Parámetros de filtro para presupuestos
class BudgetFilterParams {
  final String userId;
  final String? categoryId;

  const BudgetFilterParams({
    required this.userId,
    this.categoryId,
  });
}

/// Interfaz del repositorio de presupuestos
abstract class BudgetRepository {
  /// Obtiene todos los presupuestos del usuario
  Future<Either<Failure, List<BudgetEntity>>> getBudgets(BudgetFilterParams params);

  /// Obtiene un presupuesto por ID
  Future<Either<Failure, BudgetEntity>> getBudgetById(String id);

  /// Obtiene el presupuesto de una categoría específica
  Future<Either<Failure, BudgetEntity?>> getBudgetByCategory({
    required String userId,
    required String categoryId,
  });

  /// Crea un nuevo presupuesto
  Future<Either<Failure, BudgetEntity>> createBudget(BudgetEntity budget);

  /// Actualiza un presupuesto existente
  Future<Either<Failure, BudgetEntity>> updateBudget(BudgetEntity budget);

  /// Elimina un presupuesto
  Future<Either<Failure, void>> deleteBudget(String id);
}
