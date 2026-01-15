// Data - Budget Model
// Modelo de datos para presupuestos con serialización Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/budget_entity.dart';

/// Modelo de presupuesto para Firestore
class BudgetModel extends BudgetEntity {
  const BudgetModel({
    required super.id,
    required super.userId,
    required super.categoryId,
    required super.limitAmount,
    required super.alertThreshold,
    required super.period,
    super.createdAt,
    super.updatedAt,
  });

  /// Crea un BudgetModel desde un documento de Firestore
  factory BudgetModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return BudgetModel(
      id: doc.id,
      userId: _extractId(data['user_id'] ?? ''),
      categoryId: _extractId(data['category_id'] ?? ''),
      limitAmount: (data['limit_amount'] as num?)?.toDouble() ?? 0.0,
      alertThreshold: (data['alert_threshold'] as num?)?.toDouble() ?? 0.3,
      period: data['period'] as String? ?? 'mensual',
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate(),
    );
  }

  /// Extrae el ID de una referencia tipo "/collection/id"
  static String _extractId(String reference) {
    if (reference.contains('/')) {
      return reference.split('/').last;
    }
    return reference;
  }

  /// Crea un BudgetModel desde una entidad
  factory BudgetModel.fromEntity(BudgetEntity entity) {
    return BudgetModel(
      id: entity.id,
      userId: entity.userId,
      categoryId: entity.categoryId,
      limitAmount: entity.limitAmount,
      alertThreshold: entity.alertThreshold,
      period: entity.period,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convierte a mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'user_id': '/users/$userId',
      'category_id': '/categories/$categoryId',
      'limit_amount': limitAmount,
      'alert_threshold': alertThreshold,
      'period': period,
      'created_at': createdAt != null 
          ? Timestamp.fromDate(createdAt!) 
          : FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  /// Convierte a entidad de dominio
  BudgetEntity toEntity() {
    return BudgetEntity(
      id: id,
      userId: userId,
      categoryId: categoryId,
      limitAmount: limitAmount,
      alertThreshold: alertThreshold,
      period: period,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
