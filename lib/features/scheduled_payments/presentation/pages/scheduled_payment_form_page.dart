// Presentation - Scheduled Payment Form Page
// Formulario para crear/editar pagos programados
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/category_service.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/scheduled_payment_entity.dart';
import '../bloc/scheduled_payment_bloc.dart';
import '../bloc/scheduled_payment_event.dart';
import '../bloc/scheduled_payment_state.dart';

/// Página de formulario para pagos programados
class ScheduledPaymentFormPage extends StatefulWidget {
  final ScheduledPaymentEntity? paymentToEdit;

  const ScheduledPaymentFormPage({
    super.key,
    this.paymentToEdit,
  });

  @override
  State<ScheduledPaymentFormPage> createState() => _ScheduledPaymentFormPageState();
}

class _ScheduledPaymentFormPageState extends State<ScheduledPaymentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedCategoryId;
  DateTime _selectedDueDate = DateTime.now().add(const Duration(days: 7));
  PaymentFrequency _selectedFrequency = PaymentFrequency.monthly;
  List<int> _selectedReminderDays = [1, 3, 7];
  bool _notificationEnabled = true;

  bool get _isEditing => widget.paymentToEdit != null;

  /// Obtiene las categorías de gastos desde CategoryService
  List<CategoryData> get _categories => sl<CategoryService>().expenseCategories;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final payment = widget.paymentToEdit!;
      _nameController.text = payment.name;
      _amountController.text = payment.amount.toString();
      _notesController.text = payment.notes ?? '';
      _selectedCategoryId = payment.categoryId;
      _selectedDueDate = payment.dueDate;
      _selectedFrequency = payment.frequency;
      _selectedReminderDays = List.from(payment.reminderDays);
      _notificationEnabled = payment.notificationEnabled;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
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
          _isEditing ? 'Editar Pago' : 'Nuevo Pago Programado',
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
      body: BlocListener<ScheduledPaymentBloc, ScheduledPaymentState>(
        listener: (context, state) {
          if (state is ScheduledPaymentOperationSuccess) {
            Navigator.of(context).pop();
          } else if (state is ScheduledPaymentError) {
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
              // Nombre del pago
              _buildSectionTitle('Nombre del pago'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Ej: Arriendo, Netflix, Gimnasio...',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Monto
              _buildSectionTitle('Monto'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
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
                    return 'Ingresa un monto';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Ingresa un monto válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Categoría
              _buildSectionTitle('Categoría'),
              const SizedBox(height: 8),
              _buildCategorySelector(colorScheme),
              const SizedBox(height: 24),

              // Fecha de vencimiento
              _buildSectionTitle('Fecha de vencimiento'),
              const SizedBox(height: 8),
              _buildDateSelector(colorScheme),
              const SizedBox(height: 24),

              // Frecuencia
              _buildSectionTitle('Frecuencia'),
              const SizedBox(height: 8),
              _buildFrequencySelector(colorScheme),
              const SizedBox(height: 24),

              // Recordatorios
              _buildSectionTitle('Recordatorios'),
              const SizedBox(height: 4),
              Text(
                'Te notificaremos los días seleccionados antes del vencimiento',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              _buildReminderDaysSelector(colorScheme),
              const SizedBox(height: 16),
              _buildNotificationToggle(colorScheme),
              const SizedBox(height: 24),

              // Notas
              _buildSectionTitle('Notas (opcional)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Agrega notas adicionales...',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
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
                  _isEditing ? 'Guardar Cambios' : 'Crear Pago Programado',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
              color: isSelected
                  ? color.withAlpha(26)
                  : colorScheme.surfaceContainerHighest,
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
                  _getIconFromCode(category.iconCode),
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

  IconData _getIconFromCode(String iconCode) {
    switch (iconCode.toLowerCase()) {
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
      case 'home':
        return Icons.home_rounded;
      case 'utilities':
        return Icons.bolt_rounded;
      case 'salary':
        return Icons.account_balance_wallet_rounded;
      case 'freelance':
        return Icons.laptop_mac_rounded;
      case 'investment':
        return Icons.trending_up_rounded;
      case 'bonus':
        return Icons.card_giftcard_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Widget _buildDateSelector(ColorScheme colorScheme) {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _formatDate(_selectedDueDate),
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencySelector(ColorScheme colorScheme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: PaymentFrequency.values.map((frequency) {
        final isSelected = _selectedFrequency == frequency;

        return GestureDetector(
          onTap: () => setState(() => _selectedFrequency = frequency),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF6366F1).withAlpha(26)
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF6366F1)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Text(
              frequency.label,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF6366F1)
                    : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReminderDaysSelector(ColorScheme colorScheme) {
    final availableDays = [1, 3, 5, 7, 14, 30];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableDays.map((days) {
        final isSelected = _selectedReminderDays.contains(days);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedReminderDays.remove(days);
              } else {
                _selectedReminderDays.add(days);
                _selectedReminderDays.sort();
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF10B981).withAlpha(26)
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF10B981)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Text(
              days == 1 ? '1 día' : '$days días',
              style: TextStyle(
                fontSize: 13,
                color: isSelected
                    ? const Color(0xFF10B981)
                    : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotificationToggle(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_rounded, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Activar notificaciones',
              style: TextStyle(fontSize: 15),
            ),
          ),
          Switch(
            value: _notificationEnabled,
            onChanged: (value) => setState(() => _notificationEnabled = value),
            activeColor: const Color(0xFF6366F1),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _selectedDueDate = picked);
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
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

    final amount = double.parse(_amountController.text);

    final payment = ScheduledPaymentEntity(
      id: widget.paymentToEdit?.id ?? '',
      userId: authState.user.id,
      name: _nameController.text.trim(),
      amount: amount,
      categoryId: _selectedCategoryId!,
      dueDate: _selectedDueDate,
      frequency: _selectedFrequency,
      reminderDays: _selectedReminderDays,
      notificationEnabled: _notificationEnabled,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: widget.paymentToEdit?.createdAt,
    );

    if (_isEditing) {
      context
          .read<ScheduledPaymentBloc>()
          .add(ScheduledPaymentUpdateRequested(payment: payment));
    } else {
      context
          .read<ScheduledPaymentBloc>()
          .add(ScheduledPaymentCreateRequested(payment: payment));
    }
  }
}
