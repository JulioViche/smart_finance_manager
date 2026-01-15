// Molecules - Transaction Form
// Formulario para crear/editar transacciones
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../domain/entities/transaction_entity.dart';

/// Formulario para crear o editar transacciones
class TransactionForm extends StatefulWidget {
  final TransactionEntity? initialTransaction;
  final List<CategoryItem> categories;
  final String currentUserId;
  final void Function(TransactionFormData data) onSubmit;
  final VoidCallback? onCancel;

  const TransactionForm({
    super.key,
    this.initialTransaction,
    required this.categories,
    required this.currentUserId,
    required this.onSubmit,
    this.onCancel,
  });

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  
  late TransactionType _selectedType;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    if (widget.initialTransaction != null) {
      _amountController.text = widget.initialTransaction!.amount.toString();
      _selectedType = widget.initialTransaction!.type;
      _selectedCategoryId = widget.initialTransaction!.categoryId;
      _selectedDate = widget.initialTransaction!.date;
      _selectedTime = TimeOfDay.fromDateTime(widget.initialTransaction!.date);
    } else {
      _selectedType = TransactionType.expense;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  /// Categorías filtradas por tipo
  List<CategoryItem> get _filteredCategories {
    return widget.categories
        .where((c) => c.type == _selectedType.name)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Selector de tipo
            _buildTypeSelector(colorScheme),
            const SizedBox(height: 24),

            // Campo de monto
            _buildAmountField(colorScheme),
            const SizedBox(height: 20),

            // Selector de categoría
            _buildCategoryDropdown(colorScheme),
            const SizedBox(height: 20),

            // Selector de fecha
            _buildDatePicker(colorScheme),
            const SizedBox(height: 20),

            // Selector de hora
            _buildTimePicker(colorScheme),
            const SizedBox(height: 32),

            // Botones de acción
            _buildActionButtons(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(128),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _TypeButton(
              label: 'Gasto',
              icon: Icons.trending_down_rounded,
              isSelected: _selectedType == TransactionType.expense,
              color: const Color(0xFFEF4444),
              onTap: () {
                setState(() {
                  _selectedType = TransactionType.expense;
                  _selectedCategoryId = null;
                });
              },
            ),
          ),
          Expanded(
            child: _TypeButton(
              label: 'Ingreso',
              icon: Icons.trending_up_rounded,
              isSelected: _selectedType == TransactionType.income,
              color: const Color(0xFF10B981),
              onTap: () {
                setState(() {
                  _selectedType = TransactionType.income;
                  _selectedCategoryId = null;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountField(ColorScheme colorScheme) {
    return TextFormField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: _selectedType == TransactionType.income
            ? const Color(0xFF10B981)
            : const Color(0xFFEF4444),
      ),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: '0.00',
        hintStyle: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurfaceVariant.withAlpha(102),
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Text(
            '\$',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withAlpha(128),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ingresa un monto';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'Monto inválido';
        }
        return null;
      },
    );
  }

  Widget _buildCategoryDropdown(ColorScheme colorScheme) {
    return DropdownButtonFormField<String>(
      value: _selectedCategoryId,
      decoration: InputDecoration(
        labelText: 'Categoría',
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withAlpha(128),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(
          Icons.category_rounded,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      items: _filteredCategories.map((category) {
        return DropdownMenuItem(
          value: category.id,
          child: Text(category.name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategoryId = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Selecciona una categoría';
        }
        return null;
      },
    );
  }

  Widget _buildDatePicker(ColorScheme colorScheme) {
    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withAlpha(128),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fecha',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(_selectedDate),
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(ColorScheme colorScheme) {
    return InkWell(
      onTap: () => _selectTime(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withAlpha(128),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hora',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(_selectedTime),
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(ColorScheme colorScheme) {
    return Row(
      children: [
        if (widget.onCancel != null) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: widget.onCancel,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 16),
        ],
        Expanded(
          flex: widget.onCancel != null ? 2 : 1,
          child: FilledButton(
            onPressed: _handleSubmit,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: _selectedType == TransactionType.income
                  ? const Color(0xFF10B981)
                  : const Color(0xFF6366F1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.initialTransaction != null
                      ? Icons.save_rounded
                      : Icons.add_rounded,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.initialTransaction != null ? 'Guardar' : 'Agregar',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${date.day} de ${months[date.month - 1]}, ${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      widget.onSubmit(TransactionFormData(
        id: widget.initialTransaction?.id,
        amount: double.parse(_amountController.text),
        categoryId: _selectedCategoryId!,
        type: _selectedType,
        date: dateTime,
        userId: widget.currentUserId,
      ));
    }
  }
}

/// Botón de selección de tipo
class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Datos del formulario de transacción
class TransactionFormData {
  final String? id;
  final double amount;
  final String categoryId;
  final TransactionType type;
  final DateTime date;
  final String userId;

  TransactionFormData({
    this.id,
    required this.amount,
    required this.categoryId,
    required this.type,
    required this.date,
    required this.userId,
  });
}

/// Ítem de categoría para el dropdown
class CategoryItem {
  final String id;
  final String name;
  final String type;
  final String iconCode;
  final String colorHex;

  CategoryItem({
    required this.id,
    required this.name,
    required this.type,
    required this.iconCode,
    required this.colorHex,
  });
}
