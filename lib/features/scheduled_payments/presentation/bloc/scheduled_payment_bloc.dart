// Presentation - Scheduled Payment BLoC
// BLoC para gestionar el estado de pagos programados
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/scheduled_payment_repository.dart';
import '../../domain/usecases/create_scheduled_payment.dart';
import '../../domain/usecases/delete_scheduled_payment.dart';
import '../../domain/usecases/get_scheduled_payments.dart';
import '../../domain/usecases/update_scheduled_payment.dart';
import '../../domain/usecases/mark_payment_as_paid.dart';
import 'scheduled_payment_event.dart';
import 'scheduled_payment_state.dart';

/// BLoC para gestionar pagos programados
class ScheduledPaymentBloc
    extends Bloc<ScheduledPaymentEvent, ScheduledPaymentState> {
  final CreateScheduledPayment createScheduledPayment;
  final GetScheduledPayments getScheduledPayments;
  final UpdateScheduledPayment updateScheduledPayment;
  final DeleteScheduledPayment deleteScheduledPayment;
  final MarkPaymentAsPaid markPaymentAsPaid;

  String? _currentUserId;

  ScheduledPaymentBloc({
    required this.createScheduledPayment,
    required this.getScheduledPayments,
    required this.updateScheduledPayment,
    required this.deleteScheduledPayment,
    required this.markPaymentAsPaid,
  }) : super(const ScheduledPaymentInitial()) {
    on<ScheduledPaymentLoadRequested>(_onLoadRequested);
    on<ScheduledPaymentCreateRequested>(_onCreateRequested);
    on<ScheduledPaymentUpdateRequested>(_onUpdateRequested);
    on<ScheduledPaymentDeleteRequested>(_onDeleteRequested);
    on<ScheduledPaymentMarkAsPaidRequested>(_onMarkAsPaidRequested);
  }

  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }

  Future<void> _onLoadRequested(
    ScheduledPaymentLoadRequested event,
    Emitter<ScheduledPaymentState> emit,
  ) async {
    emit(const ScheduledPaymentLoading());
    _currentUserId = event.userId;

    final result = await getScheduledPayments(
      ScheduledPaymentFilterParams(userId: event.userId),
    );

    result.fold(
      (failure) => emit(ScheduledPaymentError(message: failure.message)),
      (payments) => emit(ScheduledPaymentLoaded(
        payments: payments,
        userId: event.userId,
      )),
    );
  }

  Future<void> _onCreateRequested(
    ScheduledPaymentCreateRequested event,
    Emitter<ScheduledPaymentState> emit,
  ) async {
    emit(const ScheduledPaymentLoading());

    final result = await createScheduledPayment(event.payment);

    await result.fold(
      (failure) async =>
          emit(ScheduledPaymentError(message: failure.message)),
      (created) async {
        if (_currentUserId != null) {
          final reloadResult = await getScheduledPayments(
            ScheduledPaymentFilterParams(userId: _currentUserId!),
          );

          reloadResult.fold(
            (failure) =>
                emit(ScheduledPaymentError(message: failure.message)),
            (payments) => emit(ScheduledPaymentOperationSuccess(
              message: 'Pago programado creado exitosamente',
              payments: payments,
              userId: _currentUserId!,
            )),
          );
        }
      },
    );
  }

  Future<void> _onUpdateRequested(
    ScheduledPaymentUpdateRequested event,
    Emitter<ScheduledPaymentState> emit,
  ) async {
    emit(const ScheduledPaymentLoading());

    final result = await updateScheduledPayment(event.payment);

    await result.fold(
      (failure) async =>
          emit(ScheduledPaymentError(message: failure.message)),
      (updated) async {
        if (_currentUserId != null) {
          final reloadResult = await getScheduledPayments(
            ScheduledPaymentFilterParams(userId: _currentUserId!),
          );

          reloadResult.fold(
            (failure) =>
                emit(ScheduledPaymentError(message: failure.message)),
            (payments) => emit(ScheduledPaymentOperationSuccess(
              message: 'Pago programado actualizado',
              payments: payments,
              userId: _currentUserId!,
            )),
          );
        }
      },
    );
  }

  Future<void> _onDeleteRequested(
    ScheduledPaymentDeleteRequested event,
    Emitter<ScheduledPaymentState> emit,
  ) async {
    emit(const ScheduledPaymentLoading());

    final result = await deleteScheduledPayment(event.paymentId);

    await result.fold(
      (failure) async =>
          emit(ScheduledPaymentError(message: failure.message)),
      (_) async {
        if (_currentUserId != null) {
          final reloadResult = await getScheduledPayments(
            ScheduledPaymentFilterParams(userId: _currentUserId!),
          );

          reloadResult.fold(
            (failure) =>
                emit(ScheduledPaymentError(message: failure.message)),
            (payments) => emit(ScheduledPaymentOperationSuccess(
              message: 'Pago programado eliminado',
              payments: payments,
              userId: _currentUserId!,
            )),
          );
        }
      },
    );
  }

  Future<void> _onMarkAsPaidRequested(
    ScheduledPaymentMarkAsPaidRequested event,
    Emitter<ScheduledPaymentState> emit,
  ) async {
    emit(const ScheduledPaymentLoading());

    final result = await markPaymentAsPaid(event.paymentId);

    await result.fold(
      (failure) async =>
          emit(ScheduledPaymentError(message: failure.message)),
      (updated) async {
        if (_currentUserId != null) {
          final reloadResult = await getScheduledPayments(
            ScheduledPaymentFilterParams(userId: _currentUserId!),
          );

          reloadResult.fold(
            (failure) =>
                emit(ScheduledPaymentError(message: failure.message)),
            (payments) => emit(ScheduledPaymentOperationSuccess(
              message: 'Pago marcado como realizado',
              payments: payments,
              userId: _currentUserId!,
            )),
          );
        }
      },
    );
  }
}
