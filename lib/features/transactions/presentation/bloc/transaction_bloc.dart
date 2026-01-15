// Presentation Layer - Transaction BLoC
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/create_transaction.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/get_transaction_by_id.dart';
import '../../domain/usecases/get_transactions.dart';
import '../../domain/usecases/update_transaction.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

/// BLoC de transacciones - maneja la lógica de estado de transacciones
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final CreateTransaction createTransaction;
  final GetTransactions getTransactions;
  final GetTransactionById getTransactionById;
  final UpdateTransaction updateTransaction;
  final DeleteTransaction deleteTransaction;

  /// ID del usuario actual (se obtiene del estado global de auth)
  String? _currentUserId;

  TransactionBloc({
    required this.createTransaction,
    required this.getTransactions,
    required this.getTransactionById,
    required this.updateTransaction,
    required this.deleteTransaction,
  }) : super(const TransactionInitial()) {
    // Registrar handlers de eventos
    on<TransactionLoadRequested>(_onLoadRequested);
    on<TransactionCreateRequested>(_onCreateRequested);
    on<TransactionUpdateRequested>(_onUpdateRequested);
    on<TransactionDeleteRequested>(_onDeleteRequested);
    on<TransactionSelected>(_onTransactionSelected);
    on<TransactionSelectionCleared>(_onSelectionCleared);
    on<TransactionFilterApplied>(_onFilterApplied);
    on<TransactionFilterCleared>(_onFilterCleared);
  }

  /// Establece el ID del usuario actual
  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }

  /// Cargar lista de transacciones
  Future<void> _onLoadRequested(
    TransactionLoadRequested event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionLoading());

    final result = await getTransactions(event.params);

    result.fold(
      (failure) => emit(TransactionError(message: failure.message)),
      (transactions) {
        final totals = _calculateTotals(transactions);
        emit(TransactionLoaded(
          transactions: transactions,
          currentFilters: event.params,
          totalIncome: totals.income,
          totalExpense: totals.expense,
        ));
      },
    );
  }

  /// Crear nueva transacción
  Future<void> _onCreateRequested(
    TransactionCreateRequested event,
    Emitter<TransactionState> emit,
  ) async {
    final currentState = state;
    emit(const TransactionLoading());

    final result = await createTransaction(event.transaction);

    await result.fold(
      (failure) async => emit(TransactionError(message: failure.message)),
      (transaction) async {
        emit(TransactionOperationSuccess(
          message: 'Transacción creada exitosamente',
          transaction: transaction,
        ));

        // Recargar lista si teníamos un estado previo
        if (currentState is TransactionLoaded) {
          add(TransactionLoadRequested(params: currentState.currentFilters));
        } else if (_currentUserId != null) {
          add(TransactionLoadRequested(
            params: TransactionFilterParams(userId: _currentUserId),
          ));
        }
      },
    );
  }

  /// Actualizar transacción
  Future<void> _onUpdateRequested(
    TransactionUpdateRequested event,
    Emitter<TransactionState> emit,
  ) async {
    final currentState = state;
    emit(const TransactionLoading());

    final result = await updateTransaction(event.transaction);

    await result.fold(
      (failure) async => emit(TransactionError(message: failure.message)),
      (transaction) async {
        emit(TransactionOperationSuccess(
          message: 'Transacción actualizada exitosamente',
          transaction: transaction,
        ));

        // Recargar lista
        if (currentState is TransactionLoaded) {
          add(TransactionLoadRequested(params: currentState.currentFilters));
        } else if (_currentUserId != null) {
          add(TransactionLoadRequested(
            params: TransactionFilterParams(userId: _currentUserId),
          ));
        }
      },
    );
  }

  /// Eliminar transacción
  Future<void> _onDeleteRequested(
    TransactionDeleteRequested event,
    Emitter<TransactionState> emit,
  ) async {
    final currentState = state;
    emit(const TransactionLoading());

    final result = await deleteTransaction(event.transactionId);

    await result.fold(
      (failure) async => emit(TransactionError(message: failure.message)),
      (_) async {
        emit(const TransactionOperationSuccess(
          message: 'Transacción eliminada exitosamente',
        ));

        // Recargar lista
        if (currentState is TransactionLoaded) {
          add(TransactionLoadRequested(params: currentState.currentFilters));
        } else if (_currentUserId != null) {
          add(TransactionLoadRequested(
            params: TransactionFilterParams(userId: _currentUserId),
          ));
        }
      },
    );
  }

  /// Seleccionar transacción para ver detalles
  Future<void> _onTransactionSelected(
    TransactionSelected event,
    Emitter<TransactionState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TransactionLoaded) return;

    emit(const TransactionLoading());

    final result = await getTransactionById(event.transactionId);

    result.fold(
      (failure) => emit(TransactionError(message: failure.message)),
      (transaction) => emit(currentState.copyWith(
        selectedTransaction: transaction,
      )),
    );
  }

  /// Limpiar selección
  void _onSelectionCleared(
    TransactionSelectionCleared event,
    Emitter<TransactionState> emit,
  ) {
    final currentState = state;
    if (currentState is TransactionLoaded) {
      emit(currentState.copyWith(clearSelectedTransaction: true));
    }
  }

  /// Aplicar filtros
  Future<void> _onFilterApplied(
    TransactionFilterApplied event,
    Emitter<TransactionState> emit,
  ) async {
    final currentState = state;
    TransactionFilterParams baseParams;

    if (currentState is TransactionLoaded) {
      baseParams = currentState.currentFilters;
    } else {
      baseParams = TransactionFilterParams(userId: _currentUserId);
    }

    final newParams = TransactionFilterParams(
      userId: baseParams.userId,
      type: event.type,
      categoryId: event.categoryId,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    add(TransactionLoadRequested(params: newParams));
  }

  /// Limpiar filtros
  void _onFilterCleared(
    TransactionFilterCleared event,
    Emitter<TransactionState> emit,
  ) {
    if (_currentUserId != null) {
      add(TransactionLoadRequested(
        params: TransactionFilterParams(userId: _currentUserId),
      ));
    }
  }

  /// Calcula totales de ingresos y gastos
  ({double income, double expense}) _calculateTotals(
    List<TransactionEntity> transactions,
  ) {
    double income = 0;
    double expense = 0;

    for (final transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
      }
    }

    return (income: income, expense: expense);
  }
}
