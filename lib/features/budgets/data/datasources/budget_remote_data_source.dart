// Data - Budget Remote Data Source
// Fuente de datos remota para presupuestos (Firestore)
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/budget_model.dart';

/// Interfaz de la fuente de datos remota de presupuestos
abstract class BudgetRemoteDataSource {
  /// Obtiene todos los presupuestos del usuario
  Future<List<BudgetModel>> getBudgets(String userId);

  /// Obtiene un presupuesto por ID
  Future<BudgetModel> getBudgetById(String id);

  /// Obtiene el presupuesto de una categoría específica
  Future<BudgetModel?> getBudgetByCategory({
    required String userId,
    required String categoryId,
  });

  /// Crea un nuevo presupuesto
  Future<BudgetModel> createBudget(BudgetModel budget);

  /// Actualiza un presupuesto existente
  Future<BudgetModel> updateBudget(BudgetModel budget);

  /// Elimina un presupuesto
  Future<void> deleteBudget(String id);
}

/// Implementación de la fuente de datos remota usando Firestore
class BudgetRemoteDataSourceImpl implements BudgetRemoteDataSource {
  final FirebaseFirestore firestore;

  BudgetRemoteDataSourceImpl({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _collection =>
      firestore.collection('budgets');

  @override
  Future<List<BudgetModel>> getBudgets(String userId) async {
    final querySnapshot = await _collection
        .where('user_id', isEqualTo: '/users/$userId')
        .get();

    return querySnapshot.docs
        .map((doc) => BudgetModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<BudgetModel> getBudgetById(String id) async {
    final doc = await _collection.doc(id).get();
    
    if (!doc.exists) {
      throw Exception('Presupuesto no encontrado');
    }

    return BudgetModel.fromFirestore(doc);
  }

  @override
  Future<BudgetModel?> getBudgetByCategory({
    required String userId,
    required String categoryId,
  }) async {
    final querySnapshot = await _collection
        .where('user_id', isEqualTo: '/users/$userId')
        .where('category_id', isEqualTo: '/categories/$categoryId')
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return null;
    }

    return BudgetModel.fromFirestore(querySnapshot.docs.first);
  }

  @override
  Future<BudgetModel> createBudget(BudgetModel budget) async {
    final docRef = await _collection.add(budget.toMap());
    final newDoc = await docRef.get();
    
    return BudgetModel.fromFirestore(newDoc);
  }

  @override
  Future<BudgetModel> updateBudget(BudgetModel budget) async {
    await _collection.doc(budget.id).update(budget.toMap());
    
    final updatedDoc = await _collection.doc(budget.id).get();
    return BudgetModel.fromFirestore(updatedDoc);
  }

  @override
  Future<void> deleteBudget(String id) async {
    await _collection.doc(id).delete();
  }
}
