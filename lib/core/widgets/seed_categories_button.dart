// Widget de administración para sembrar categorías
// Añadir temporalmente al menú de usuario para ejecutar el seed
//
// Uso: Agregar este botón en el menú de usuario de TransactionsPage
// y eliminarlo después de ejecutar el seed.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Botón para sembrar categorías en Firestore
/// Usar solo una vez para inicializar la base de datos
class SeedCategoriesButton extends StatefulWidget {
  const SeedCategoriesButton({super.key});

  @override
  State<SeedCategoriesButton> createState() => _SeedCategoriesButtonState();
}

class _SeedCategoriesButtonState extends State<SeedCategoriesButton> {
  bool _isSeeding = false;
  String _status = '';

  Future<void> _seedCategories() async {
    setState(() {
      _isSeeding = true;
      _status = 'Iniciando...';
    });

    final categories = [
      // Gastos
      {'id': 'cat_food', 'name': 'Comida', 'type': 'expense', 'iconCode': 'food', 'colorHex': '#F97316'},
      {'id': 'cat_transport', 'name': 'Transporte', 'type': 'expense', 'iconCode': 'transport', 'colorHex': '#3B82F6'},
      {'id': 'cat_shopping', 'name': 'Compras', 'type': 'expense', 'iconCode': 'shopping', 'colorHex': '#EC4899'},
      {'id': 'cat_entertainment', 'name': 'Entretenimiento', 'type': 'expense', 'iconCode': 'entertainment', 'colorHex': '#8B5CF6'},
      {'id': 'cat_health', 'name': 'Salud', 'type': 'expense', 'iconCode': 'health', 'colorHex': '#10B981'},
      {'id': 'cat_home', 'name': 'Hogar', 'type': 'expense', 'iconCode': 'home', 'colorHex': '#F59E0B'},
      {'id': 'cat_utilities', 'name': 'Servicios', 'type': 'expense', 'iconCode': 'utilities', 'colorHex': '#6366F1'},
      {'id': 'cat_other_expense', 'name': 'Otros', 'type': 'expense', 'iconCode': 'other', 'colorHex': '#64748B'},
      // Ingresos
      {'id': 'cat_salary', 'name': 'Salario', 'type': 'income', 'iconCode': 'salary', 'colorHex': '#10B981'},
      {'id': 'cat_freelance', 'name': 'Freelance', 'type': 'income', 'iconCode': 'freelance', 'colorHex': '#6366F1'},
      {'id': 'cat_investment', 'name': 'Inversiones', 'type': 'income', 'iconCode': 'investment', 'colorHex': '#F59E0B'},
      {'id': 'cat_bonus', 'name': 'Bonos', 'type': 'income', 'iconCode': 'bonus', 'colorHex': '#EC4899'},
      {'id': 'cat_other_income', 'name': 'Otros', 'type': 'income', 'iconCode': 'other', 'colorHex': '#64748B'},
    ];

    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      for (final category in categories) {
        final docRef = firestore.collection('categories').doc(category['id']);
        batch.set(docRef, {
          ...category,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      await batch.commit();

      setState(() {
        _status = '✅ ${categories.length} categorías insertadas!';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${categories.length} categorías insertadas correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSeeding = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _isSeeding
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.category_rounded, color: Colors.orange),
      title: const Text('Sembrar Categorías'),
      subtitle: _status.isNotEmpty ? Text(_status) : const Text('Inicializar BD'),
      onTap: _isSeeding ? null : _seedCategories,
    );
  }
}
