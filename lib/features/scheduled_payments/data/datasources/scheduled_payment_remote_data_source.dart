// Data - Scheduled Payment Remote Data Source
// Fuente de datos remota para pagos programados (Firestore)
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/scheduled_payment_entity.dart';
import '../models/scheduled_payment_model.dart';

/// Interfaz de la fuente de datos remota de pagos programados
abstract class ScheduledPaymentRemoteDataSource {
  /// Obtiene todos los pagos programados del usuario
  Future<List<ScheduledPaymentModel>> getScheduledPayments(String userId);

  /// Obtiene pagos próximos a vencer
  Future<List<ScheduledPaymentModel>> getUpcomingPayments({
    required String userId,
    required int daysAhead,
  });

  /// Obtiene un pago programado por ID
  Future<ScheduledPaymentModel> getScheduledPaymentById(String id);

  /// Crea un nuevo pago programado
  Future<ScheduledPaymentModel> createScheduledPayment(ScheduledPaymentModel payment);

  /// Actualiza un pago programado existente
  Future<ScheduledPaymentModel> updateScheduledPayment(ScheduledPaymentModel payment);

  /// Elimina un pago programado (soft delete)
  Future<void> deleteScheduledPayment(String id);

  /// Actualiza la fecha de vencimiento después de pagar
  Future<ScheduledPaymentModel> updateDueDateAfterPayment(String id);
}

/// Implementación de la fuente de datos remota usando Firestore
class ScheduledPaymentRemoteDataSourceImpl implements ScheduledPaymentRemoteDataSource {
  final FirebaseFirestore firestore;

  ScheduledPaymentRemoteDataSourceImpl({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _collection =>
      firestore.collection('scheduled_payments');

  @override
  Future<List<ScheduledPaymentModel>> getScheduledPayments(String userId) async {
    final querySnapshot = await _collection
        .where('user_id', isEqualTo: '/users/$userId')
        .where('is_deleted', isEqualTo: false)
        .orderBy('due_date')
        .get();

    return querySnapshot.docs
        .map((doc) => ScheduledPaymentModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<List<ScheduledPaymentModel>> getUpcomingPayments({
    required String userId,
    required int daysAhead,
  }) async {
    final now = DateTime.now();
    final endDate = now.add(Duration(days: daysAhead));

    final querySnapshot = await _collection
        .where('user_id', isEqualTo: '/users/$userId')
        .where('is_deleted', isEqualTo: false)
        .where('is_active', isEqualTo: true)
        .where('due_date', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
        .where('due_date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('due_date')
        .get();

    return querySnapshot.docs
        .map((doc) => ScheduledPaymentModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<ScheduledPaymentModel> getScheduledPaymentById(String id) async {
    final doc = await _collection.doc(id).get();

    if (!doc.exists) {
      throw Exception('Pago programado no encontrado');
    }

    return ScheduledPaymentModel.fromFirestore(doc);
  }

  @override
  Future<ScheduledPaymentModel> createScheduledPayment(
    ScheduledPaymentModel payment,
  ) async {
    final docRef = await _collection.add(payment.toFirestore());
    final newDoc = await docRef.get();

    return ScheduledPaymentModel.fromFirestore(newDoc);
  }

  @override
  Future<ScheduledPaymentModel> updateScheduledPayment(
    ScheduledPaymentModel payment,
  ) async {
    await _collection.doc(payment.id).update(payment.toFirestore());

    final updatedDoc = await _collection.doc(payment.id).get();
    return ScheduledPaymentModel.fromFirestore(updatedDoc);
  }

  @override
  Future<void> deleteScheduledPayment(String id) async {
    // Soft delete
    await _collection.doc(id).update({
      'is_deleted': true,
      'is_active': false,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<ScheduledPaymentModel> updateDueDateAfterPayment(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) {
      throw Exception('Pago programado no encontrado');
    }

    final payment = ScheduledPaymentModel.fromFirestore(doc);
    final nextDueDate = payment.nextDueDate;

    // Si es un pago único, desactivarlo
    final isActive = payment.frequency != PaymentFrequency.once;

    await _collection.doc(id).update({
      'due_date': Timestamp.fromDate(nextDueDate),
      'is_active': isActive,
      'updated_at': FieldValue.serverTimestamp(),
    });

    final updatedDoc = await _collection.doc(id).get();
    return ScheduledPaymentModel.fromFirestore(updatedDoc);
  }
}
