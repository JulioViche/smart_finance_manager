// Presentation Layer - Transaction States
import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';

/// Clase base para todos los estados de transacciones
abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class TransactionInitial extends TransactionState {
  const TransactionInitial();
}

/// Estado de carga
class TransactionLoading extends TransactionState {
  const TransactionLoading();
}

/// Estado con lista de transacciones cargada
class TransactionLoaded extends TransactionState {
  final List<TransactionEntity> transactions;
  final TransactionEntity? selectedTransaction;
  final TransactionFilterParams currentFilters;
  final double totalIncome;
  final double totalExpense;

  const TransactionLoaded({
    required this.transactions,
    this.selectedTransaction,
    this.currentFilters = const TransactionFilterParams(),
    this.totalIncome = 0,
    this.totalExpense = 0,
  });

  /// Balance neto (ingresos - gastos)
  double get balance => totalIncome - totalExpense;

  /// Crea copia con valores modificados
  TransactionLoaded copyWith({
    List<TransactionEntity>? transactions,
    TransactionEntity? selectedTransaction,
    TransactionFilterParams? currentFilters,
    double? totalIncome,
    double? totalExpense,
    bool clearSelectedTransaction = false,
  }) {
    return TransactionLoaded(
      transactions: transactions ?? this.transactions,
      selectedTransaction: clearSelectedTransaction 
          ? null 
          : (selectedTransaction ?? this.selectedTransaction),
      currentFilters: currentFilters ?? this.currentFilters,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
    );
  }

  @override
  List<Object?> get props => [
        transactions,
        selectedTransaction,
        currentFilters,
        totalIncome,
        totalExpense,
      ];
}

/// Estado de transacción creada/actualizada exitosamente
class TransactionOperationSuccess extends TransactionState {
  final String message;
  final TransactionEntity? transaction;

  const TransactionOperationSuccess({
    required this.message,
    this.transaction,
  });

  @override
  List<Object?> get props => [message, transaction];
}

/// Estado de error
class TransactionError extends TransactionState {
  final String message;

  const TransactionError({required this.message});

  @override
  List<Object?> get props => [message];
}
