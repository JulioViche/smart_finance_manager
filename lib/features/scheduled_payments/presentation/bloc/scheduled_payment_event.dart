// Presentation - Scheduled Payment Events
// Eventos para el BLoC de pagos programados
import 'package:equatable/equatable.dart';
import '../../domain/entities/scheduled_payment_entity.dart';

/// Evento base de pagos programados
abstract class ScheduledPaymentEvent extends Equatable {
  const ScheduledPaymentEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar pagos programados
class ScheduledPaymentLoadRequested extends ScheduledPaymentEvent {
  final String userId;

  const ScheduledPaymentLoadRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Evento para crear un pago programado
class ScheduledPaymentCreateRequested extends ScheduledPaymentEvent {
  final ScheduledPaymentEntity payment;

  const ScheduledPaymentCreateRequested({required this.payment});

  @override
  List<Object?> get props => [payment];
}

/// Evento para actualizar un pago programado
class ScheduledPaymentUpdateRequested extends ScheduledPaymentEvent {
  final ScheduledPaymentEntity payment;

  const ScheduledPaymentUpdateRequested({required this.payment});

  @override
  List<Object?> get props => [payment];
}

/// Evento para eliminar un pago programado
class ScheduledPaymentDeleteRequested extends ScheduledPaymentEvent {
  final String paymentId;

  const ScheduledPaymentDeleteRequested({required this.paymentId});

  @override
  List<Object?> get props => [paymentId];
}

/// Evento para marcar un pago como realizado
class ScheduledPaymentMarkAsPaidRequested extends ScheduledPaymentEvent {
  final String paymentId;

  const ScheduledPaymentMarkAsPaidRequested({required this.paymentId});

  @override
  List<Object?> get props => [paymentId];
}
