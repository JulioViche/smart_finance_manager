// Core - Scheduled Payment Notification Manager
// Servicio para sincronizar pagos programados con notificaciones
import 'package:flutter/foundation.dart';
import '../../features/scheduled_payments/domain/entities/scheduled_payment_entity.dart';
import '../../features/scheduled_payments/domain/usecases/get_upcoming_payments.dart';
import 'notification_service.dart';

/// Manager para gestionar notificaciones de pagos programados
class ScheduledPaymentNotificationManager {
  final GetUpcomingPayments getUpcomingPayments;
  final NotificationService notificationService;

  ScheduledPaymentNotificationManager({
    required this.getUpcomingPayments,
    required this.notificationService,
  });

  /// Sincroniza las notificaciones de pagos próximos
  /// Debe llamarse al iniciar la app y cuando se modifiquen pagos
  Future<void> syncNotifications(String userId) async {
    debugPrint('ScheduledPaymentNotificationManager: Sincronizando notificaciones...');

    // Obtener pagos de los próximos 30 días
    final result = await getUpcomingPayments(
      UpcomingPaymentsParams(userId: userId, daysAhead: 30),
    );

    result.fold(
      (failure) {
        debugPrint('Error al obtener pagos próximos: ${failure.message}');
      },
      (payments) async {
        debugPrint('Pagos próximos encontrados: ${payments.length}');
        
        for (final payment in payments) {
          await _processPaymentNotifications(payment);
        }
      },
    );
  }

  /// Procesa las notificaciones de un pago específico
  Future<void> _processPaymentNotifications(ScheduledPaymentEntity payment) async {
    if (!payment.notificationEnabled || !payment.isActive) {
      return;
    }

    final daysUntilDue = payment.daysUntilDue;

    // Si el pago está vencido, mostrar notificación de vencido
    if (payment.isOverdue) {
      await notificationService.showOverduePaymentAlert(
        paymentId: payment.id,
        paymentName: payment.name,
        amount: payment.amount,
        daysOverdue: -daysUntilDue,
      );
      return;
    }

    // Verificar si hoy es un día de recordatorio
    if (payment.reminderDays.contains(daysUntilDue)) {
      await notificationService.showUpcomingPaymentAlert(
        paymentId: payment.id,
        paymentName: payment.name,
        amount: payment.amount,
        daysUntilDue: daysUntilDue,
      );
    }

    // Si vence hoy, siempre notificar
    if (daysUntilDue == 0) {
      await notificationService.showUpcomingPaymentAlert(
        paymentId: payment.id,
        paymentName: payment.name,
        amount: payment.amount,
        daysUntilDue: 0,
      );
    }
  }

  /// Cancela las notificaciones de un pago específico
  Future<void> cancelPaymentNotifications(String paymentId) async {
    await notificationService.cancelPaymentNotifications(paymentId);
  }

  /// Notifica inmediatamente sobre un pago recién creado o modificado
  Future<void> notifyPaymentCreatedOrUpdated(ScheduledPaymentEntity payment) async {
    if (!payment.notificationEnabled || !payment.isActive) {
      return;
    }

    final daysUntilDue = payment.daysUntilDue;

    // Si está dentro de los días de recordatorio, notificar
    if (daysUntilDue <= 7 && daysUntilDue >= 0) {
      await notificationService.showUpcomingPaymentAlert(
        paymentId: payment.id,
        paymentName: payment.name,
        amount: payment.amount,
        daysUntilDue: daysUntilDue,
      );
    }
  }
}
