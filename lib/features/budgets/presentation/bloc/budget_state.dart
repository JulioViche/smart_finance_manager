// Presentation - Budget States
// Estados del BLoC de presupuestos
import 'package:equatable/equatable.dart';
import '../../domain/entities/budget_entity.dart';

/// Clase base para estados de presupuesto
abstract class BudgetState extends Equatable {
  const BudgetState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class BudgetInitial extends BudgetState {
  const BudgetInitial();
}

/// Estado de carga
class BudgetLoading extends BudgetState {
  const BudgetLoading();
}

/// Presupuestos cargados exitosamente
class BudgetLoaded extends BudgetState {
  final List<BudgetEntity> budgets;
  final String userId;

  const BudgetLoaded({
    required this.budgets,
    required this.userId,
  });

  @override
  List<Object?> get props => [budgets, userId];
}

/// Operación exitosa (crear, actualizar, eliminar)
class BudgetOperationSuccess extends BudgetState {
  final String message;
  final List<BudgetEntity> budgets;
  final String userId;

  const BudgetOperationSuccess({
    required this.message,
    required this.budgets,
    required this.userId,
  });

  @override
  List<Object?> get props => [message, budgets, userId];
}

/// Error en operación
class BudgetError extends BudgetState {
  final String message;

  const BudgetError({required this.message});

  @override
  List<Object?> get props => [message];
}
