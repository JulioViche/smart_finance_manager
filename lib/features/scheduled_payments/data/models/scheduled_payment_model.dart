// Data - Scheduled Payment Model
// Modelo de datos para pagos programados con serialización Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/scheduled_payment_entity.dart';

/// Modelo de pago programado para Firestore
class ScheduledPaymentModel extends ScheduledPaymentEntity {
  const ScheduledPaymentModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.amount,
    required super.categoryId,
    required super.dueDate,
    required super.frequency,
    super.reminderDays,
    super.isActive,
    super.isDeleted,
    super.notificationEnabled,
    super.notes,
    super.lastTransactionId,
    super.createdAt,
    super.updatedAt,
  });

  /// Crea un ScheduledPaymentModel desde un documento de Firestore
  factory ScheduledPaymentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Parsear reminder_days
    List<int> reminderDays = [1, 3, 7];
    if (data['reminder_days'] != null) {
      reminderDays = (data['reminder_days'] as List)
          .map((e) => (e as num).toInt())
          .toList();
    }

    return ScheduledPaymentModel(
      id: doc.id,
      userId: _extractId(data['user_id'] ?? ''),
      name: data['name'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      categoryId: _extractId(data['category_id'] ?? ''),
      dueDate: (data['due_date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      frequency: PaymentFrequency.fromString(data['frequency'] as String? ?? 'monthly'),
      reminderDays: reminderDays,
      isActive: data['is_active'] as bool? ?? true,
      isDeleted: data['is_deleted'] as bool? ?? false,
      notificationEnabled: data['notification_enabled'] as bool? ?? true,
      notes: data['notes'] as String?,
      lastTransactionId: data['last_transaction_id'] as String?,
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

  /// Crea un ScheduledPaymentModel desde una entidad
  factory ScheduledPaymentModel.fromEntity(ScheduledPaymentEntity entity) {
    return ScheduledPaymentModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      amount: entity.amount,
      categoryId: entity.categoryId,
      dueDate: entity.dueDate,
      frequency: entity.frequency,
      reminderDays: entity.reminderDays,
      isActive: entity.isActive,
      isDeleted: entity.isDeleted,
      notificationEnabled: entity.notificationEnabled,
      notes: entity.notes,
      lastTransactionId: entity.lastTransactionId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convierte a mapa para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'user_id': '/users/$userId',
      'name': name,
      'amount': amount,
      'category_id': '/categories/$categoryId',
      'due_date': Timestamp.fromDate(dueDate),
      'frequency': frequency.name,
      'reminder_days': reminderDays,
      'is_active': isActive,
      'is_deleted': isDeleted,
      'notification_enabled': notificationEnabled,
      'notes': notes,
      'last_transaction_id': lastTransactionId,
      'created_at': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  /// Convierte a entidad de dominio
  ScheduledPaymentEntity toEntity() {
    return ScheduledPaymentEntity(
      id: id,
      userId: userId,
      name: name,
      amount: amount,
      categoryId: categoryId,
      dueDate: dueDate,
      frequency: frequency,
      reminderDays: reminderDays,
      isActive: isActive,
      isDeleted: isDeleted,
      notificationEnabled: notificationEnabled,
      notes: notes,
      lastTransactionId: lastTransactionId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
