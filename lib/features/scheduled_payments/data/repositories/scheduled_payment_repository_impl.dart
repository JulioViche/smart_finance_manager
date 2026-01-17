// Data - Scheduled Payment Repository Implementation
// Implementación del repositorio de pagos programados
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/scheduled_payment_entity.dart';
import '../../domain/repositories/scheduled_payment_repository.dart';
import '../datasources/scheduled_payment_remote_data_source.dart';
import '../models/scheduled_payment_model.dart';

/// Implementación del repositorio de pagos programados
class ScheduledPaymentRepositoryImpl implements ScheduledPaymentRepository {
  final ScheduledPaymentRemoteDataSource remoteDataSource;

  ScheduledPaymentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ScheduledPaymentEntity>>> getScheduledPayments(
    ScheduledPaymentFilterParams params,
  ) async {
    try {
      final payments = await remoteDataSource.getScheduledPayments(params.userId);
      return Right(payments.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(message: 'Error al obtener pagos programados: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ScheduledPaymentEntity>>> getUpcomingPayments({
    required String userId,
    required int daysAhead,
  }) async {
    try {
      final payments = await remoteDataSource.getUpcomingPayments(
        userId: userId,
        daysAhead: daysAhead,
      );
      return Right(payments.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(message: 'Error al obtener pagos próximos: $e'));
    }
  }

  @override
  Future<Either<Failure, ScheduledPaymentEntity>> getScheduledPaymentById(
    String id,
  ) async {
    try {
      final payment = await remoteDataSource.getScheduledPaymentById(id);
      return Right(payment.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: 'Error al obtener pago programado: $e'));
    }
  }

  @override
  Future<Either<Failure, ScheduledPaymentEntity>> createScheduledPayment(
    ScheduledPaymentEntity payment,
  ) async {
    try {
      final model = ScheduledPaymentModel.fromEntity(payment);
      final created = await remoteDataSource.createScheduledPayment(model);
      return Right(created.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: 'Error al crear pago programado: $e'));
    }
  }

  @override
  Future<Either<Failure, ScheduledPaymentEntity>> updateScheduledPayment(
    ScheduledPaymentEntity payment,
  ) async {
    try {
      final model = ScheduledPaymentModel.fromEntity(payment);
      final updated = await remoteDataSource.updateScheduledPayment(model);
      return Right(updated.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: 'Error al actualizar pago programado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteScheduledPayment(String id) async {
    try {
      await remoteDataSource.deleteScheduledPayment(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Error al eliminar pago programado: $e'));
    }
  }

  @override
  Future<Either<Failure, ScheduledPaymentEntity>> markAsPaid(String id) async {
    try {
      // Actualizar la fecha de vencimiento al siguiente período
      final updated = await remoteDataSource.updateDueDateAfterPayment(id);
      return Right(updated.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: 'Error al marcar pago como realizado: $e'));
    }
  }
}
