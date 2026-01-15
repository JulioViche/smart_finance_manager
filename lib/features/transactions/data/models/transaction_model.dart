// Data Layer - Transaction Model
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/transaction_entity.dart';

/// Modelo de ubicación para Firestore
class TransactionLocationModel extends TransactionLocation {
  const TransactionLocationModel({
    required super.latitude,
    required super.longitude,
  });

  /// Crear desde GeoPoint de Firestore
  factory TransactionLocationModel.fromGeoPoint(GeoPoint? geoPoint) {
    if (geoPoint == null) {
      return const TransactionLocationModel(latitude: 0, longitude: 0);
    }
    return TransactionLocationModel(
      latitude: geoPoint.latitude,
      longitude: geoPoint.longitude,
    );
  }

  /// Convertir a GeoPoint para Firestore
  GeoPoint toGeoPoint() {
    return GeoPoint(latitude, longitude);
  }

  /// Crear desde entidad
  factory TransactionLocationModel.fromEntity(TransactionLocation entity) {
    return TransactionLocationModel(
      latitude: entity.latitude,
      longitude: entity.longitude,
    );
  }
}

/// Modelo de Transacción para Firestore
class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.amount,
    required super.categoryId,
    required super.createdAt,
    required super.date,
    super.isDeleted,
    required TransactionLocationModel location,
    super.receiptImagePath,
    required super.type,
    required super.updatedAt,
    required super.userId,
  }) : super(location: location);

  /// Crear desde DocumentSnapshot de Firestore
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      categoryId: data['category_id'] as String? ?? '',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isDeleted: data['is_deleted'] as bool? ?? false,
      location: TransactionLocationModel.fromGeoPoint(
        data['location'] as GeoPoint?,
      ),
      receiptImagePath: data['receipt_image_path'] as String?,
      type: TransactionType.fromString(data['type'] as String? ?? 'expense'),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: data['user_id'] as String? ?? '',
    );
  }

  /// Convertir a Map para guardar en Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'amount': amount,
      'category_id': categoryId,
      'created_at': Timestamp.fromDate(createdAt),
      'date': Timestamp.fromDate(date),
      'is_deleted': isDeleted,
      'location': (location as TransactionLocationModel).toGeoPoint(),
      'receipt_image_path': receiptImagePath ?? 'none',
      'type': type.name,
      'updated_at': Timestamp.fromDate(updatedAt),
      'user_id': userId,
    };
  }

  /// Crear desde entidad
  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      amount: entity.amount,
      categoryId: entity.categoryId,
      createdAt: entity.createdAt,
      date: entity.date,
      isDeleted: entity.isDeleted,
      location: TransactionLocationModel.fromEntity(entity.location),
      receiptImagePath: entity.receiptImagePath,
      type: entity.type,
      updatedAt: entity.updatedAt,
      userId: entity.userId,
    );
  }

  /// Crear modelo para update (actualiza updatedAt automáticamente)
  factory TransactionModel.forUpdate(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      amount: entity.amount,
      categoryId: entity.categoryId,
      createdAt: entity.createdAt,
      date: entity.date,
      isDeleted: entity.isDeleted,
      location: TransactionLocationModel.fromEntity(entity.location),
      receiptImagePath: entity.receiptImagePath,
      type: entity.type,
      updatedAt: DateTime.now(),
      userId: entity.userId,
    );
  }
}
