// Data - Budget Repository Implementation
// Implementación del repositorio de presupuestos
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_remote_data_source.dart';
import '../models/budget_model.dart';

/// Implementación del repositorio de presupuestos
class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetRemoteDataSource remoteDataSource;

  BudgetRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<BudgetEntity>>> getBudgets(
    BudgetFilterParams params,
  ) async {
    try {
      final budgets = await remoteDataSource.getBudgets(params.userId);
      
      // Filtrar por categoría si se especifica
      List<BudgetEntity> result = budgets.map((b) => b.toEntity()).toList();
      
      if (params.categoryId != null) {
        result = result
            .where((b) => b.categoryId == params.categoryId)
            .toList();
      }
      
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BudgetEntity>> getBudgetById(String id) async {
    try {
      final budget = await remoteDataSource.getBudgetById(id);
      return Right(budget.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BudgetEntity?>> getBudgetByCategory({
    required String userId,
    required String categoryId,
  }) async {
    try {
      final budget = await remoteDataSource.getBudgetByCategory(
        userId: userId,
        categoryId: categoryId,
      );
      return Right(budget?.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BudgetEntity>> createBudget(BudgetEntity budget) async {
    try {
      final model = BudgetModel.fromEntity(budget);
      final created = await remoteDataSource.createBudget(model);
      return Right(created.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BudgetEntity>> updateBudget(BudgetEntity budget) async {
    try {
      final model = BudgetModel.fromEntity(budget);
      final updated = await remoteDataSource.updateBudget(model);
      return Right(updated.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBudget(String id) async {
    try {
      await remoteDataSource.deleteBudget(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
