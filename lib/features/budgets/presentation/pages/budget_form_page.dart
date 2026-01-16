// Presentation - Budget Form Page
// Formulario para crear/editar presupuestos
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/category_service.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/budget_entity.dart';
import '../bloc/budget_bloc.dart';
import '../bloc/budget_event.dart';
import '../bloc/budget_state.dart';

/// Página de formulario para presupuestos
class BudgetFormPage extends StatefulWidget {
  final BudgetEntity? budgetToEdit;

  const BudgetFormPage({
    super.key,
    this.budgetToEdit,
  });

  @override
  State<BudgetFormPage> createState() => _BudgetFormPageState();
}

class _BudgetFormPageState extends State<BudgetFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _limitController = TextEditingController();

  String? _selectedCategoryId;
  double _alertThreshold = 0.8;
  String _selectedPeriod = 'mensual';

  bool get _isEditing => widget.budgetToEdit != null;

  /// Obtiene las categorías de gastos desde CategoryService
  List<CategoryData> get _categories => sl<CategoryService>().expenseCategories;

  final List<String> _periods = ['semanal', 'mensual', 'anual'];

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _limitController.text = widget.budgetToEdit!.limitAmount.toString();
      _selectedCategoryId = widget.budgetToEdit!.categoryId;
      _alertThreshold = widget.budgetToEdit!.alertThreshold;
      _selectedPeriod = widget.budgetToEdit!.period;
    }
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          _isEditing ? 'Editar Presupuesto' : 'Nuevo Presupuesto',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocListener<BudgetBloc, BudgetState>(
        listener: (context, state) {
          if (state is BudgetOperationSuccess) {
            Navigator.of(context).pop();
          } else if (state is BudgetError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Selector de categoría
              _buildSectionTitle('Categoría'),
              const SizedBox(height: 8),
              _buildCategorySelector(colorScheme),
              const SizedBox(height: 24),

              // Monto límite
              _buildSectionTitle('Monto Límite'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _limitController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  prefixText: '\$ ',
                  hintText: '0.00',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa un monto límite';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Ingresa un monto válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Período
              _buildSectionTitle('Período'),
              const SizedBox(height: 8),
              _buildPeriodSelector(colorScheme),
              const SizedBox(height: 24),

              // Umbral de alerta
              _buildSectionTitle('Umbral de Alerta'),
              const SizedBox(height: 4),
              Text(
                'Te notificaremos cuando gastes el ${(_alertThreshold * 100).toInt()}% del presupuesto',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              _buildThresholdSlider(colorScheme),
              const SizedBox(height: 32),

              // Botón guardar
              FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isEditing ? 'Guardar Cambios' : 'Crear Presupuesto',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildCategorySelector(ColorScheme colorScheme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.map((category) {
        final isSelected = _selectedCategoryId == category.id;
        Color color;
        try {
          color = Color(
            int.parse(category.colorHex.replaceFirst('#', '0xFF')),
          );
        } catch (_) {
          color = const Color(0xFF6366F1);
        }

        return GestureDetector(
          onTap: () => setState(() => _selectedCategoryId = category.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? color.withAlpha(26) : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getIconData(category.iconCode),
                  color: isSelected ? color : colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  category.name,
                  style: TextStyle(
                    color: isSelected ? color : colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPeriodSelector(ColorScheme colorScheme) {
    return Row(
      children: _periods.map((period) {
        final isSelected = _selectedPeriod == period;
        
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedPeriod = period),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                right: period != _periods.last ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSelected 
                    ? const Color(0xFF6366F1).withAlpha(26) 
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  period[0].toUpperCase() + period.substring(1),
                  style: TextStyle(
                    color: isSelected 
                        ? const Color(0xFF6366F1) 
                        : colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildThresholdSlider(ColorScheme colorScheme) {
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: const Color(0xFF6366F1),
            inactiveTrackColor: colorScheme.surfaceContainerHighest,
            thumbColor: const Color(0xFF6366F1),
            overlayColor: const Color(0xFF6366F1).withAlpha(51),
          ),
          child: Slider(
            value: _alertThreshold,
            min: 0.1,
            max: 0.9,
            divisions: 8,
            onChanged: (value) => setState(() => _alertThreshold = value),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '10%',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${(_alertThreshold * 100).toInt()}%',
                style: const TextStyle(
                  color: Color(0xFF6366F1),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '90%',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una categoría'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final limitAmount = double.parse(_limitController.text);

    final budget = BudgetEntity(
      id: widget.budgetToEdit?.id ?? '',
      userId: authState.user.id,
      categoryId: _selectedCategoryId!,
      limitAmount: limitAmount,
      alertThreshold: _alertThreshold,
      period: _selectedPeriod,
      createdAt: widget.budgetToEdit?.createdAt,
    );

    if (_isEditing) {
      context.read<BudgetBloc>().add(BudgetUpdateRequested(budget: budget));
    } else {
      context.read<BudgetBloc>().add(BudgetCreateRequested(budget: budget));
    }
  }

  IconData _getIconData(String code) {
    switch (code.toLowerCase()) {
      case 'food':
        return Icons.restaurant_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'entertainment':
        return Icons.movie_rounded;
      case 'health':
        return Icons.health_and_safety_rounded;
      case 'education':
        return Icons.school_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}
