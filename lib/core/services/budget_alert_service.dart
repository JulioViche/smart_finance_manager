// Core - Budget Alert Service
// Servicio para verificar presupuestos y disparar alertas

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'notification_service.dart';
import 'category_service.dart';
import '../../features/transactions/domain/entities/transaction_entity.dart';

/// Servicio para verificar presupuestos y enviar alertas
class BudgetAlertService {
  final FirebaseFirestore _firestore;
  final NotificationService _notificationService;
  final CategoryService _categoryService;

  BudgetAlertService({
    required FirebaseFirestore firestore,
    required NotificationService notificationService,
    required CategoryService categoryService,
  })  : _firestore = firestore,
        _notificationService = notificationService,
        _categoryService = categoryService;

  /// Verifica si una transacción dispara alguna alerta de presupuesto
  Future<void> checkBudgetAlerts({
    required TransactionEntity transaction,
    required String userId,
  }) async {
    // Solo verificar gastos
    if (transaction.type != TransactionType.expense) return;

    try {
      // Obtener el presupuesto para esta categoría
      final budgetQuery = await _firestore
          .collection('budgets')
          .where('user_id', isEqualTo: userId)
          .where('category_id', isEqualTo: transaction.categoryId)
          .where('is_active', isEqualTo: true)
          .limit(1)
          .get();

      if (budgetQuery.docs.isEmpty) return;

      final budgetDoc = budgetQuery.docs.first;
      final budgetData = budgetDoc.data();
      
      final limitAmount = (budgetData['limit_amount'] as num?)?.toDouble() ?? 0;
      final alertThreshold = (budgetData['alert_threshold'] as num?)?.toDouble() ?? 0.8;

      if (limitAmount <= 0) return;

      // Calcular gasto total del mes para esta categoría
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      final transactionsQuery = await _firestore
          .collection('transactions')
          .where('user_id', isEqualTo: userId)
          .where('category_id', isEqualTo: transaction.categoryId)
          .where('type', isEqualTo: 'expense')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .get();

      double totalSpent = 0;
      for (final doc in transactionsQuery.docs) {
        final amount = (doc.data()['amount'] as num?)?.toDouble() ?? 0;
        totalSpent += amount;
      }

      final percentage = totalSpent / limitAmount;
      final category = _categoryService.getCategory(transaction.categoryId);

      debugPrint('BudgetAlert: $totalSpent / $limitAmount = ${(percentage * 100).toInt()}%');

      // Verificar si excedió el presupuesto
      if (percentage >= 1.0) {
        await _notificationService.showBudgetExceededAlert(
          categoryName: category.name,
          spentAmount: totalSpent,
          limitAmount: limitAmount,
        );
        debugPrint('🚨 Notificación: Presupuesto excedido para ${category.name}');
      }
      // Verificar si superó el umbral de alerta
      else if (percentage >= alertThreshold) {
        await _notificationService.showHighSpendingAlert(
          categoryName: category.name,
          spentAmount: totalSpent,
          limitAmount: limitAmount,
          percentage: percentage,
        );
        debugPrint('⚠️ Notificación: Gasto elevado para ${category.name}');
      }
    } catch (e) {
      debugPrint('Error verificando alertas de presupuesto: $e');
    }
  }
}
