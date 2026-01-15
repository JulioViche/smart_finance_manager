// Presentation - Budget Events
// Eventos del BLoC de presupuestos
import 'package:equatable/equatable.dart';
import '../../domain/entities/budget_entity.dart';

/// Clase base para eventos de presupuesto
abstract class BudgetEvent extends Equatable {
  const BudgetEvent();

  @override
  List<Object?> get props => [];
}

/// Solicita cargar presupuestos
class BudgetLoadRequested extends BudgetEvent {
  final String userId;

  const BudgetLoadRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Solicita crear un presupuesto
class BudgetCreateRequested extends BudgetEvent {
  final BudgetEntity budget;

  const BudgetCreateRequested({required this.budget});

  @override
  List<Object?> get props => [budget];
}

/// Solicita actualizar un presupuesto
class BudgetUpdateRequested extends BudgetEvent {
  final BudgetEntity budget;

  const BudgetUpdateRequested({required this.budget});

  @override
  List<Object?> get props => [budget];
}

/// Solicita eliminar un presupuesto
class BudgetDeleteRequested extends BudgetEvent {
  final String budgetId;

  const BudgetDeleteRequested({required this.budgetId});

  @override
  List<Object?> get props => [budgetId];
}
