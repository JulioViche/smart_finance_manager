// Domain - Scheduled Payment Repository Interface
// Contrato para el repositorio de pagos programados
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/scheduled_payment_entity.dart';

/// Parámetros de filtro para pagos programados
class ScheduledPaymentFilterParams {
  final String userId;
  final bool? activeOnly;
  final int? daysAhead; // Para buscar pagos próximos

  const ScheduledPaymentFilterParams({
    required this.userId,
    this.activeOnly = true,
    this.daysAhead,
  });
}

/// Interfaz del repositorio de pagos programados
abstract class ScheduledPaymentRepository {
  /// Obtiene todos los pagos programados del usuario
  Future<Either<Failure, List<ScheduledPaymentEntity>>> getScheduledPayments(
    ScheduledPaymentFilterParams params,
  );

  /// Obtiene pagos que vencen en los próximos N días
  Future<Either<Failure, List<ScheduledPaymentEntity>>> getUpcomingPayments({
    required String userId,
    required int daysAhead,
  });

  /// Obtiene un pago programado por ID
  Future<Either<Failure, ScheduledPaymentEntity>> getScheduledPaymentById(String id);

  /// Crea un nuevo pago programado
  Future<Either<Failure, ScheduledPaymentEntity>> createScheduledPayment(
    ScheduledPaymentEntity payment,
  );

  /// Actualiza un pago programado existente
  Future<Either<Failure, ScheduledPaymentEntity>> updateScheduledPayment(
    ScheduledPaymentEntity payment,
  );

  /// Elimina un pago programado (soft delete)
  Future<Either<Failure, void>> deleteScheduledPayment(String id);

  /// Marca un pago como realizado (crea transacción y actualiza próxima fecha)
  Future<Either<Failure, ScheduledPaymentEntity>> markAsPaid(String id);
}
