// Domain - Get Scheduled Payments Use Case
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/scheduled_payment_entity.dart';
import '../repositories/scheduled_payment_repository.dart';

/// Caso de uso para obtener pagos programados
class GetScheduledPayments {
  final ScheduledPaymentRepository repository;

  GetScheduledPayments(this.repository);

  Future<Either<Failure, List<ScheduledPaymentEntity>>> call(
    ScheduledPaymentFilterParams params,
  ) async {
    return await repository.getScheduledPayments(params);
  }
}
