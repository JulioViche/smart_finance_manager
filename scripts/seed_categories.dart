// Script para sembrar las categorías en Firestore
// Ejecutar una sola vez con: dart run scripts/seed_categories.dart
//
// NOTA: Requiere las credenciales de Firebase configuradas.
// Puede ejecutarse desde la terminal con:
// cd smart_finance_manager
// flutter run -t scripts/seed_categories.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../lib/firebase_options.dart';

Future<void> main() async {
  print('🚀 Iniciando seed de categorías...\n');

  // Inicializar Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  final firestore = FirebaseFirestore.instance;
  final categoriesRef = firestore.collection('categories');

  // Definición de todas las categorías
  final categories = [
    // ========== GASTOS ==========
    {
      'id': 'cat_food',
      'name': 'Comida',
      'type': 'expense',
      'iconCode': 'food',
      'colorHex': '#F97316',
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'id': 'cat_transport',
      'name': 'Transporte',
      'type': 'expense',
      'iconCode': 'transport',
      'colorHex': '#3B82F6',
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'id': 'cat_shopping',
      'name': 'Compras',
      'type': 'expense',
      'iconCode': 'shopping',
      'colorHex': '#EC4899',
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'id': 'cat_entertainment',
      'name': 'Entretenimiento',
      'type': 'expense',
      'iconCode': 'entertainment',
      'colorHex': '#8B5CF6',
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'id': 'cat_health',
      'name': 'Salud',
      'type': 'expense',
      'iconCode': 'health',
      'colorHex': '#10B981',
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'id': 'cat_home',
      'name': 'Hogar',
      'type': 'expense',
      'iconCode': 'home',
      'colorHex': '#F59E0B',
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'id': 'cat_utilities',
      'name': 'Servicios',
      'type': 'expense',
      'iconCode': 'utilities',
      'colorHex': '#6366F1',
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'id': 'cat_other_expense',
      'name': 'Otros',
      'type': 'expense',
      'iconCode': 'other',
      'colorHex': '#64748B',
      'createdAt': FieldValue.serverTimestamp(),
    },
    // ========== INGRESOS ==========
    {
      'id': 'cat_salary',
      'name': 'Salario',
      'type': 'income',
      'iconCode': 'salary',
      'colorHex': '#10B981',
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'id': 'cat_freelance',
      'name': 'Freelance',
      'type': 'income',
      'iconCode': 'freelance',
      'colorHex': '#6366F1',
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'id': 'cat_investment',
      'name': 'Inversiones',
      'type': 'income',
      'iconCode': 'investment',
      'colorHex': '#F59E0B',
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'id': 'cat_bonus',
      'name': 'Bonos',
      'type': 'income',
      'iconCode': 'bonus',
      'colorHex': '#EC4899',
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'id': 'cat_other_income',
      'name': 'Otros',
      'type': 'income',
      'iconCode': 'other',
      'colorHex': '#64748B',
      'createdAt': FieldValue.serverTimestamp(),
    },
  ];

  print('📦 Insertando ${categories.length} categorías...\n');

  int inserted = 0;
  int skipped = 0;

  for (final category in categories) {
    final docId = category['id'] as String;
    final docRef = categoriesRef.doc(docId);
    
    // Verificar si ya existe
    final existing = await docRef.get();
    
    if (existing.exists) {
      print('⏭️  Saltando: ${category['name']} (ya existe)');
      skipped++;
    } else {
      await docRef.set(category);
      print('✅ Insertada: ${category['name']}');
      inserted++;
    }
  }

  print('\n========================================');
  print('📊 Resumen:');
  print('   - Insertadas: $inserted');
  print('   - Saltadas: $skipped');
  print('   - Total: ${categories.length}');
  print('========================================\n');
  print('🏁 Seed completado!');
}
