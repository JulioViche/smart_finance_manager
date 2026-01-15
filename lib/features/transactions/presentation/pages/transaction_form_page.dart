// Pages - Transaction Form Page
// Página para crear/editar transacciones
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/location_service.dart';
import '../../../../injection_container.dart' as di;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/transaction_entity.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../widgets/molecules/transaction_form.dart';

/// Página para crear o editar transacciones
class TransactionFormPage extends StatefulWidget {
  final TransactionEntity? transactionToEdit;

  const TransactionFormPage({
    super.key,
    this.transactionToEdit,
  });

  @override
  State<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
  final LocationService _locationService = di.sl<LocationService>();
  bool _isSubmitting = false;

  bool get isEditing => widget.transactionToEdit != null;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
        ),
        title: Text(
          isEditing ? 'Editar Transacción' : 'Nueva Transacción',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) {
            return const Center(
              child: Text('Debes iniciar sesión'),
            );
          }

          if (_isSubmitting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Guardando transacción...'),
                  SizedBox(height: 8),
                  Text(
                    'Obteniendo ubicación...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return TransactionForm(
            initialTransaction: widget.transactionToEdit,
            currentUserId: authState.user.id,
            categories: _getCategories(),
            onSubmit: (data) => _handleSubmit(context, data),
            onCancel: () => Navigator.pop(context),
          );
        },
      ),
    );
  }

  Future<void> _handleSubmit(BuildContext context, TransactionFormData data) async {
    setState(() {
      _isSubmitting = true;
    });

    // Obtener ubicación actual
    TransactionLocation? location;
    if (!isEditing) {
      final locationResult = await _locationService.getCurrentLocation();
      if (!locationResult.isDefault) {
        location = TransactionLocation(
          latitude: locationResult.latitude,
          longitude: locationResult.longitude,
        );
      }
    } else {
      // Mantener la ubicación original si estamos editando
      location = widget.transactionToEdit?.location ?? TransactionLocation.empty;
    }

    if (!mounted) return;

    final bloc = context.read<TransactionBloc>();

    final transaction = TransactionEntity(
      id: data.id ?? '',
      amount: data.amount,
      categoryId: data.categoryId,
      createdAt: isEditing ? widget.transactionToEdit!.createdAt : DateTime.now(),
      date: data.date,
      isDeleted: false,
      location: location ?? TransactionLocation.empty,
      type: data.type,
      updatedAt: DateTime.now(),
      userId: data.userId,
    );

    if (isEditing) {
      bloc.add(TransactionUpdateRequested(transaction: transaction));
    } else {
      bloc.add(TransactionCreateRequested(transaction: transaction));
    }

    Navigator.pop(context);
  }

  /// Obtiene las categorías disponibles
  /// TODO: Conectar con servicio real de categorías
  List<CategoryItem> _getCategories() {
    return [
      // Gastos
      CategoryItem(
        id: 'cat_food',
        name: 'Comida',
        type: 'expense',
        iconCode: 'food',
        colorHex: '#F97316',
      ),
      CategoryItem(
        id: 'cat_transport',
        name: 'Transporte',
        type: 'expense',
        iconCode: 'transport',
        colorHex: '#3B82F6',
      ),
      CategoryItem(
        id: 'cat_shopping',
        name: 'Compras',
        type: 'expense',
        iconCode: 'shopping',
        colorHex: '#EC4899',
      ),
      CategoryItem(
        id: 'cat_entertainment',
        name: 'Entretenimiento',
        type: 'expense',
        iconCode: 'entertainment',
        colorHex: '#8B5CF6',
      ),
      CategoryItem(
        id: 'cat_health',
        name: 'Salud',
        type: 'expense',
        iconCode: 'health',
        colorHex: '#10B981',
      ),
      CategoryItem(
        id: 'cat_home',
        name: 'Hogar',
        type: 'expense',
        iconCode: 'home',
        colorHex: '#F59E0B',
      ),
      CategoryItem(
        id: 'cat_utilities',
        name: 'Servicios',
        type: 'expense',
        iconCode: 'utilities',
        colorHex: '#6366F1',
      ),
      CategoryItem(
        id: 'cat_other_expense',
        name: 'Otros',
        type: 'expense',
        iconCode: 'other',
        colorHex: '#64748B',
      ),
      // Ingresos
      CategoryItem(
        id: 'cat_salary',
        name: 'Salario',
        type: 'income',
        iconCode: 'salary',
        colorHex: '#10B981',
      ),
      CategoryItem(
        id: 'cat_freelance',
        name: 'Freelance',
        type: 'income',
        iconCode: 'freelance',
        colorHex: '#6366F1',
      ),
      CategoryItem(
        id: 'cat_investment',
        name: 'Inversiones',
        type: 'income',
        iconCode: 'investment',
        colorHex: '#F59E0B',
      ),
      CategoryItem(
        id: 'cat_bonus',
        name: 'Bonos',
        type: 'income',
        iconCode: 'bonus',
        colorHex: '#EC4899',
      ),
      CategoryItem(
        id: 'cat_other_income',
        name: 'Otros',
        type: 'income',
        iconCode: 'other',
        colorHex: '#64748B',
      ),
    ];
  }
}
