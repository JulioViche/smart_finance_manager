// Domain - Budget Entity
// Entidad de presupuesto para la capa de dominio
import 'package:equatable/equatable.dart';

/// Entidad que representa un presupuesto
class BudgetEntity extends Equatable {
  final String id;
  final String userId;
  final String categoryId;
  final double limitAmount;
  final double alertThreshold; // 0.0 - 1.0 (ej: 0.3 = 30%)
  final String period; // 'mensual', 'semanal', 'anual'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BudgetEntity({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.limitAmount,
    required this.alertThreshold,
    required this.period,
    this.createdAt,
    this.updatedAt,
  });

  /// Copia con modificaciones
  BudgetEntity copyWith({
    String? id,
    String? userId,
    String? categoryId,
    double? limitAmount,
    double? alertThreshold,
    String? period,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BudgetEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      limitAmount: limitAmount ?? this.limitAmount,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      period: period ?? this.period,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        categoryId,
        limitAmount,
        alertThreshold,
        period,
        createdAt,
        updatedAt,
      ];
}
