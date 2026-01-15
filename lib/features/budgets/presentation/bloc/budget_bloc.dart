// Presentation - Budget BLoC
// BLoC para gestionar el estado de presupuestos
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../domain/usecases/create_budget.dart';
import '../../domain/usecases/delete_budget.dart';
import '../../domain/usecases/get_budgets.dart';
import '../../domain/usecases/update_budget.dart';
import 'budget_event.dart';
import 'budget_state.dart';

/// BLoC para gestionar presupuestos
class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final CreateBudget createBudget;
  final GetBudgets getBudgets;
  final UpdateBudget updateBudget;
  final DeleteBudget deleteBudget;

  String? _currentUserId;

  BudgetBloc({
    required this.createBudget,
    required this.getBudgets,
    required this.updateBudget,
    required this.deleteBudget,
  }) : super(const BudgetInitial()) {
    on<BudgetLoadRequested>(_onLoadRequested);
    on<BudgetCreateRequested>(_onCreateRequested);
    on<BudgetUpdateRequested>(_onUpdateRequested);
    on<BudgetDeleteRequested>(_onDeleteRequested);
  }

  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }

  Future<void> _onLoadRequested(
    BudgetLoadRequested event,
    Emitter<BudgetState> emit,
  ) async {
    emit(const BudgetLoading());
    _currentUserId = event.userId;

    final result = await getBudgets(
      BudgetFilterParams(userId: event.userId),
    );

    result.fold(
      (failure) => emit(BudgetError(message: failure.message)),
      (budgets) => emit(BudgetLoaded(
        budgets: budgets,
        userId: event.userId,
      )),
    );
  }

  Future<void> _onCreateRequested(
    BudgetCreateRequested event,
    Emitter<BudgetState> emit,
  ) async {
    emit(const BudgetLoading());

    final result = await createBudget(event.budget);

    await result.fold(
      (failure) async => emit(BudgetError(message: failure.message)),
      (created) async {
        // Recargar la lista
        if (_currentUserId != null) {
          final reloadResult = await getBudgets(
            BudgetFilterParams(userId: _currentUserId!),
          );

          reloadResult.fold(
            (failure) => emit(BudgetError(message: failure.message)),
            (budgets) => emit(BudgetOperationSuccess(
              message: 'Presupuesto creado exitosamente',
              budgets: budgets,
              userId: _currentUserId!,
            )),
          );
        }
      },
    );
  }

  Future<void> _onUpdateRequested(
    BudgetUpdateRequested event,
    Emitter<BudgetState> emit,
  ) async {
    emit(const BudgetLoading());

    final result = await updateBudget(event.budget);

    await result.fold(
      (failure) async => emit(BudgetError(message: failure.message)),
      (updated) async {
        if (_currentUserId != null) {
          final reloadResult = await getBudgets(
            BudgetFilterParams(userId: _currentUserId!),
          );

          reloadResult.fold(
            (failure) => emit(BudgetError(message: failure.message)),
            (budgets) => emit(BudgetOperationSuccess(
              message: 'Presupuesto actualizado',
              budgets: budgets,
              userId: _currentUserId!,
            )),
          );
        }
      },
    );
  }

  Future<void> _onDeleteRequested(
    BudgetDeleteRequested event,
    Emitter<BudgetState> emit,
  ) async {
    emit(const BudgetLoading());

    final result = await deleteBudget(event.budgetId);

    await result.fold(
      (failure) async => emit(BudgetError(message: failure.message)),
      (_) async {
        if (_currentUserId != null) {
          final reloadResult = await getBudgets(
            BudgetFilterParams(userId: _currentUserId!),
          );

          reloadResult.fold(
            (failure) => emit(BudgetError(message: failure.message)),
            (budgets) => emit(BudgetOperationSuccess(
              message: 'Presupuesto eliminado',
              budgets: budgets,
              userId: _currentUserId!,
            )),
          );
        }
      },
    );
  }
}
