// Domain - Update Scheduled Payment Use Case
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/scheduled_payment_entity.dart';
import '../repositories/scheduled_payment_repository.dart';

/// Caso de uso para actualizar un pago programado
class UpdateScheduledPayment {
  final ScheduledPaymentRepository repository;

  UpdateScheduledPayment(this.repository);

  Future<Either<Failure, ScheduledPaymentEntity>> call(
    ScheduledPaymentEntity payment,
  ) async {
    return await repository.updateScheduledPayment(payment);
  }
}
