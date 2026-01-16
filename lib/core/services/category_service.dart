// Core - Category Service
// Servicio para gestionar las categorías desde Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Datos de una categoría
class CategoryData {
  final String id;
  final String name;
  final String type;
  final String iconCode;
  final String colorHex;

  const CategoryData({
    required this.id,
    required this.name,
    required this.type,
    required this.iconCode,
    required this.colorHex,
  });

  factory CategoryData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryData(
      id: doc.id,
      name: data['name'] ?? 'Sin nombre',
      type: data['type'] ?? 'expense',
      iconCode: data['iconCode'] ?? 'other',
      colorHex: data['colorHex'] ?? '#6366F1',
    );
  }

  /// Categoría por defecto cuando no se encuentra
  static const CategoryData defaultCategory = CategoryData(
    id: 'default',
    name: 'General',
    type: 'expense',
    iconCode: 'other',
    colorHex: '#6366F1',
  );
}

/// Servicio de categorías con caché
class CategoryService extends ChangeNotifier {
  final FirebaseFirestore _firestore;
  
  Map<String, CategoryData> _categoriesCache = {};
  bool _isInitialized = false;
  bool _isLoading = false;

  CategoryService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Indica si las categorías están cargadas
  bool get isInitialized => _isInitialized;
  
  /// Indica si está cargando
  bool get isLoading => _isLoading;
  
  /// Todas las categorías
  List<CategoryData> get allCategories => _categoriesCache.values.toList();
  
  /// Categorías de gastos
  List<CategoryData> get expenseCategories => 
      _categoriesCache.values.where((c) => c.type == 'expense').toList();
  
  /// Categorías de ingresos
  List<CategoryData> get incomeCategories => 
      _categoriesCache.values.where((c) => c.type == 'income').toList();

  /// Inicializa el servicio cargando todas las categorías
  Future<void> initialize() async {
    if (_isInitialized || _isLoading) return;
    
    _isLoading = true;
    
    try {
      final snapshot = await _firestore.collection('categories').get();
      
      _categoriesCache = {
        for (final doc in snapshot.docs)
          doc.id: CategoryData.fromFirestore(doc)
      };
      
      _isInitialized = true;
      debugPrint('CategoryService: ${_categoriesCache.length} categorías cargadas');
    } catch (e) {
      debugPrint('Error cargando categorías: $e');
      // Cargar categorías por defecto en caso de error
      _loadDefaultCategories();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtiene una categoría por su ID
  CategoryData getCategory(String categoryId) {
    return _categoriesCache[categoryId] ?? CategoryData.defaultCategory;
  }

  /// Recarga las categorías desde Firestore
  Future<void> refresh() async {
    _isInitialized = false;
    _categoriesCache.clear();
    await initialize();
  }

  /// Carga categorías por defecto (fallback)
  void _loadDefaultCategories() {
    _categoriesCache = {
      // Gastos
      'cat_food': const CategoryData(id: 'cat_food', name: 'Comida', type: 'expense', iconCode: 'food', colorHex: '#F97316'),
      'cat_transport': const CategoryData(id: 'cat_transport', name: 'Transporte', type: 'expense', iconCode: 'transport', colorHex: '#3B82F6'),
      'cat_shopping': const CategoryData(id: 'cat_shopping', name: 'Compras', type: 'expense', iconCode: 'shopping', colorHex: '#EC4899'),
      'cat_entertainment': const CategoryData(id: 'cat_entertainment', name: 'Entretenimiento', type: 'expense', iconCode: 'entertainment', colorHex: '#8B5CF6'),
      'cat_health': const CategoryData(id: 'cat_health', name: 'Salud', type: 'expense', iconCode: 'health', colorHex: '#10B981'),
      'cat_home': const CategoryData(id: 'cat_home', name: 'Hogar', type: 'expense', iconCode: 'home', colorHex: '#F59E0B'),
      'cat_utilities': const CategoryData(id: 'cat_utilities', name: 'Servicios', type: 'expense', iconCode: 'utilities', colorHex: '#6366F1'),
      'cat_other_expense': const CategoryData(id: 'cat_other_expense', name: 'Otros', type: 'expense', iconCode: 'other', colorHex: '#64748B'),
      // Ingresos
      'cat_salary': const CategoryData(id: 'cat_salary', name: 'Salario', type: 'income', iconCode: 'salary', colorHex: '#10B981'),
      'cat_freelance': const CategoryData(id: 'cat_freelance', name: 'Freelance', type: 'income', iconCode: 'freelance', colorHex: '#6366F1'),
      'cat_investment': const CategoryData(id: 'cat_investment', name: 'Inversiones', type: 'income', iconCode: 'investment', colorHex: '#F59E0B'),
      'cat_bonus': const CategoryData(id: 'cat_bonus', name: 'Bonos', type: 'income', iconCode: 'bonus', colorHex: '#EC4899'),
      'cat_other_income': const CategoryData(id: 'cat_other_income', name: 'Otros', type: 'income', iconCode: 'other', colorHex: '#64748B'),
    };
    _isInitialized = true;
  }
}
