// Domain - Scheduled Payment Entity
// Entidad para representar un pago programado
import 'package:equatable/equatable.dart';

/// Frecuencia del pago programado
enum PaymentFrequency {
  once,      // Pago único
  weekly,    // Semanal
  biweekly,  // Quincenal
  monthly,   // Mensual
  yearly;    // Anual

  /// Convierte string a PaymentFrequency
  static PaymentFrequency fromString(String value) {
    return PaymentFrequency.values.firstWhere(
      (freq) => freq.name == value.toLowerCase(),
      orElse: () => PaymentFrequency.monthly,
    );
  }
  
  /// Obtiene el label en español
  String get label {
    switch (this) {
      case PaymentFrequency.once:
        return 'Único';
      case PaymentFrequency.weekly:
        return 'Semanal';
      case PaymentFrequency.biweekly:
        return 'Quincenal';
      case PaymentFrequency.monthly:
        return 'Mensual';
      case PaymentFrequency.yearly:
        return 'Anual';
    }
  }
}

/// Entidad que representa un pago programado
class ScheduledPaymentEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final double amount;
  final String categoryId;
  final DateTime dueDate;
  final PaymentFrequency frequency;
  final List<int> reminderDays; // Días antes para notificar [1, 3, 7]
  final bool isActive;
  final bool isDeleted;
  final bool notificationEnabled;
  final String? notes;
  final String? lastTransactionId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ScheduledPaymentEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.amount,
    required this.categoryId,
    required this.dueDate,
    required this.frequency,
    this.reminderDays = const [1, 3, 7],
    this.isActive = true,
    this.isDeleted = false,
    this.notificationEnabled = true,
    this.notes,
    this.lastTransactionId,
    this.createdAt,
    this.updatedAt,
  });

  /// Verifica si el pago está vencido
  bool get isOverdue => dueDate.isBefore(DateTime.now());

  /// Días restantes hasta el vencimiento
  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;

  /// Calcula la siguiente fecha de vencimiento según la frecuencia
  DateTime get nextDueDate {
    switch (frequency) {
      case PaymentFrequency.once:
        return dueDate;
      case PaymentFrequency.weekly:
        return dueDate.add(const Duration(days: 7));
      case PaymentFrequency.biweekly:
        return dueDate.add(const Duration(days: 14));
      case PaymentFrequency.monthly:
        return DateTime(dueDate.year, dueDate.month + 1, dueDate.day);
      case PaymentFrequency.yearly:
        return DateTime(dueDate.year + 1, dueDate.month, dueDate.day);
    }
  }

  /// Copia con modificaciones
  ScheduledPaymentEntity copyWith({
    String? id,
    String? userId,
    String? name,
    double? amount,
    String? categoryId,
    DateTime? dueDate,
    PaymentFrequency? frequency,
    List<int>? reminderDays,
    bool? isActive,
    bool? isDeleted,
    bool? notificationEnabled,
    String? notes,
    String? lastTransactionId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScheduledPaymentEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      dueDate: dueDate ?? this.dueDate,
      frequency: frequency ?? this.frequency,
      reminderDays: reminderDays ?? this.reminderDays,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      notes: notes ?? this.notes,
      lastTransactionId: lastTransactionId ?? this.lastTransactionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        amount,
        categoryId,
        dueDate,
        frequency,
        reminderDays,
        isActive,
        isDeleted,
        notificationEnabled,
        notes,
        lastTransactionId,
        createdAt,
        updatedAt,
      ];
}
