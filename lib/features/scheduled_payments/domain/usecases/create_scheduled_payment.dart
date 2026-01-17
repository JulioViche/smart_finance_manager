// Domain - Create Scheduled Payment Use Case
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/scheduled_payment_entity.dart';
import '../repositories/scheduled_payment_repository.dart';

/// Caso de uso para crear un pago programado
class CreateScheduledPayment {
  final ScheduledPaymentRepository repository;

  CreateScheduledPayment(this.repository);

  Future<Either<Failure, ScheduledPaymentEntity>> call(
    ScheduledPaymentEntity payment,
  ) async {
    return await repository.createScheduledPayment(payment);
  }
}
