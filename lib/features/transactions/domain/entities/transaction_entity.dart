// Domain Layer - Transaction Entity
import 'package:equatable/equatable.dart';

/// Representa la ubicación geográfica de una transacción
class TransactionLocation extends Equatable {
  final double latitude;
  final double longitude;

  const TransactionLocation({
    required this.latitude,
    required this.longitude,
  });

  /// Ubicación por defecto (0, 0)
  static const TransactionLocation empty = TransactionLocation(
    latitude: 0,
    longitude: 0,
  );

  @override
  List<Object?> get props => [latitude, longitude];
}

/// Tipo de transacción
enum TransactionType {
  income,
  expense;

  /// Convierte string a TransactionType
  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
      (type) => type.name == value.toLowerCase(),
      orElse: () => TransactionType.expense,
    );
  }
}

/// Entidad de Transacción - representa el modelo de negocio puro
class TransactionEntity extends Equatable {
  final String id;
  final double amount;
  final String categoryId;
  final DateTime createdAt;
  final DateTime date;
  final bool isDeleted;
  final TransactionLocation location;
  final String? receiptImagePath;
  final TransactionType type;
  final DateTime updatedAt;
  final String userId;

  const TransactionEntity({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.createdAt,
    required this.date,
    this.isDeleted = false,
    this.location = TransactionLocation.empty,
    this.receiptImagePath,
    required this.type,
    required this.updatedAt,
    required this.userId,
  });

  /// Crea una copia de la entidad con los valores modificados
  TransactionEntity copyWith({
    String? id,
    double? amount,
    String? categoryId,
    DateTime? createdAt,
    DateTime? date,
    bool? isDeleted,
    TransactionLocation? location,
    String? receiptImagePath,
    TransactionType? type,
    DateTime? updatedAt,
    String? userId,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      date: date ?? this.date,
      isDeleted: isDeleted ?? this.isDeleted,
      location: location ?? this.location,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      type: type ?? this.type,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        amount,
        categoryId,
        createdAt,
        date,
        isDeleted,
        location,
        receiptImagePath,
        type,
        updatedAt,
        userId,
      ];
}
