// Presentation - Scheduled Payment States
// Estados para el BLoC de pagos programados
import 'package:equatable/equatable.dart';
import '../../domain/entities/scheduled_payment_entity.dart';

/// Estado base de pagos programados
abstract class ScheduledPaymentState extends Equatable {
  const ScheduledPaymentState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ScheduledPaymentInitial extends ScheduledPaymentState {
  const ScheduledPaymentInitial();
}

/// Estado de carga
class ScheduledPaymentLoading extends ScheduledPaymentState {
  const ScheduledPaymentLoading();
}

/// Estado con lista de pagos cargados
class ScheduledPaymentLoaded extends ScheduledPaymentState {
  final List<ScheduledPaymentEntity> payments;
  final String userId;

  const ScheduledPaymentLoaded({
    required this.payments,
    required this.userId,
  });

  /// Pagos activos ordenados por fecha de vencimiento
  List<ScheduledPaymentEntity> get activePayments =>
      payments.where((p) => p.isActive && !p.isOverdue).toList();

  /// Pagos vencidos
  List<ScheduledPaymentEntity> get overduePayments =>
      payments.where((p) => p.isActive && p.isOverdue).toList();

  /// Pagos inactivos (únicos ya pagados)
  List<ScheduledPaymentEntity> get inactivePayments =>
      payments.where((p) => !p.isActive).toList();

  @override
  List<Object?> get props => [payments, userId];
}

/// Estado de error
class ScheduledPaymentError extends ScheduledPaymentState {
  final String message;

  const ScheduledPaymentError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Estado de operación exitosa
class ScheduledPaymentOperationSuccess extends ScheduledPaymentState {
  final String message;
  final List<ScheduledPaymentEntity> payments;
  final String userId;

  const ScheduledPaymentOperationSuccess({
    required this.message,
    required this.payments,
    required this.userId,
  });

  @override
  List<Object?> get props => [message, payments, userId];
}
