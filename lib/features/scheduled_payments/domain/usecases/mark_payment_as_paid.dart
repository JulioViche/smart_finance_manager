// Domain - Mark Payment As Paid Use Case
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/scheduled_payment_entity.dart';
import '../repositories/scheduled_payment_repository.dart';

/// Caso de uso para marcar un pago como realizado
/// Esto crea una transacción y actualiza la próxima fecha de vencimiento
class MarkPaymentAsPaid {
  final ScheduledPaymentRepository repository;

  MarkPaymentAsPaid(this.repository);

  Future<Either<Failure, ScheduledPaymentEntity>> call(String id) async {
    return await repository.markAsPaid(id);
  }
}
