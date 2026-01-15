// Presentation Layer - Transaction Events
import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';

/// Clase base para todos los eventos de transacciones
abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar lista de transacciones
class TransactionLoadRequested extends TransactionEvent {
  final TransactionFilterParams params;

  const TransactionLoadRequested({required this.params});

  @override
  List<Object?> get props => [params];
}

/// Crear nueva transacción
class TransactionCreateRequested extends TransactionEvent {
  final TransactionEntity transaction;

  const TransactionCreateRequested({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}

/// Actualizar transacción existente
class TransactionUpdateRequested extends TransactionEvent {
  final TransactionEntity transaction;

  const TransactionUpdateRequested({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}

/// Eliminar transacción
class TransactionDeleteRequested extends TransactionEvent {
  final String transactionId;

  const TransactionDeleteRequested({required this.transactionId});

  @override
  List<Object?> get props => [transactionId];
}

/// Seleccionar transacción para ver detalles
class TransactionSelected extends TransactionEvent {
  final String transactionId;

  const TransactionSelected({required this.transactionId});

  @override
  List<Object?> get props => [transactionId];
}

/// Limpiar transacción seleccionada
class TransactionSelectionCleared extends TransactionEvent {
  const TransactionSelectionCleared();
}

/// Aplicar filtros a la lista
class TransactionFilterApplied extends TransactionEvent {
  final TransactionType? type;
  final String? categoryId;
  final DateTime? startDate;
  final DateTime? endDate;

  const TransactionFilterApplied({
    this.type,
    this.categoryId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [type, categoryId, startDate, endDate];
}

/// Limpiar filtros
class TransactionFilterCleared extends TransactionEvent {
  const TransactionFilterCleared();
}
