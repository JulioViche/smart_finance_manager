// Domain - Delete Scheduled Payment Use Case
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/scheduled_payment_repository.dart';

/// Caso de uso para eliminar un pago programado
class DeleteScheduledPayment {
  final ScheduledPaymentRepository repository;

  DeleteScheduledPayment(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteScheduledPayment(id);
  }
}
