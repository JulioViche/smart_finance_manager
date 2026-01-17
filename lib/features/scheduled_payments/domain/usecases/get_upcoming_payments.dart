// Domain - Get Upcoming Payments Use Case
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/scheduled_payment_entity.dart';
import '../repositories/scheduled_payment_repository.dart';

/// Parámetros para obtener pagos próximos
class UpcomingPaymentsParams {
  final String userId;
  final int daysAhead;

  const UpcomingPaymentsParams({
    required this.userId,
    this.daysAhead = 7,
  });
}

/// Caso de uso para obtener pagos próximos a vencer
class GetUpcomingPayments {
  final ScheduledPaymentRepository repository;

  GetUpcomingPayments(this.repository);

  Future<Either<Failure, List<ScheduledPaymentEntity>>> call(
    UpcomingPaymentsParams params,
  ) async {
    return await repository.getUpcomingPayments(
      userId: params.userId,
      daysAhead: params.daysAhead,
    );
  }
}
