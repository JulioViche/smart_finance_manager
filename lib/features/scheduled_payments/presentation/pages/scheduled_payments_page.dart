// Presentation - Scheduled Payments Page
// Página principal de pagos programados
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/category_service.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/scheduled_payment_bloc.dart';
import '../bloc/scheduled_payment_event.dart';
import '../bloc/scheduled_payment_state.dart';
import '../../domain/entities/scheduled_payment_entity.dart';
import '../widgets/scheduled_payment_card.dart';
import 'scheduled_payment_form_page.dart';

/// Página principal de pagos programados
class ScheduledPaymentsPage extends StatefulWidget {
  const ScheduledPaymentsPage({super.key});

  @override
  State<ScheduledPaymentsPage> createState() => _ScheduledPaymentsPageState();
}

class _ScheduledPaymentsPageState extends State<ScheduledPaymentsPage> {
  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  void _loadPayments() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ScheduledPaymentBloc>().setCurrentUserId(authState.user.id);
      context.read<ScheduledPaymentBloc>().add(
            ScheduledPaymentLoadRequested(userId: authState.user.id),
          );
    }
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
        title: const Text(
          'Pagos Programados',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<ScheduledPaymentBloc, ScheduledPaymentState>(
        listener: (context, state) {
          if (state is ScheduledPaymentOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          } else if (state is ScheduledPaymentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFFEF4444),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ScheduledPaymentLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          List<ScheduledPaymentEntity> payments = [];
          if (state is ScheduledPaymentLoaded) {
            payments = state.payments;
          } else if (state is ScheduledPaymentOperationSuccess) {
            payments = state.payments;
          }

          if (payments.isEmpty) {
            return _buildEmptyState(context);
          }

          return _buildPaymentsList(context, payments);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(context),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Nuevo',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              'Sin pagos programados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega tus pagos recurrentes para recibir recordatorios',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _navigateToForm(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Crear pago programado'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentsList(
    BuildContext context,
    List<ScheduledPaymentEntity> payments,
  ) {
    // Separar pagos vencidos, próximos e inactivos
    final overduePayments = payments.where((p) => p.isActive && p.isOverdue).toList();
    final upcomingPayments = payments.where((p) => p.isActive && !p.isOverdue).toList();

    return RefreshIndicator(
      onRefresh: () async => _loadPayments(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sección de vencidos
          if (overduePayments.isNotEmpty) ...[
            _buildSectionHeader(
              context,
              'Vencidos',
              const Color(0xFFEF4444),
              Icons.warning_rounded,
            ),
            const SizedBox(height: 8),
            ...overduePayments.map((payment) => _buildPaymentCard(payment)),
            const SizedBox(height: 24),
          ],

          // Sección de próximos
          if (upcomingPayments.isNotEmpty) ...[
            _buildSectionHeader(
              context,
              'Próximos pagos',
              const Color(0xFF6366F1),
              Icons.schedule_rounded,
            ),
            const SizedBox(height: 8),
            ...upcomingPayments.map((payment) => _buildPaymentCard(payment)),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    Color color,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentCard(ScheduledPaymentEntity payment) {
    final category = sl<CategoryService>().getCategory(payment.categoryId);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ScheduledPaymentCard(
        payment: payment,
        categoryName: category.name,
        categoryIcon: _getIconFromCode(category.iconCode),
        categoryColor: Color(int.parse(category.colorHex.replaceFirst('#', '0xFF'))),
        onTap: () => _navigateToForm(context, payment: payment),
        onMarkPaid: () => _confirmMarkAsPaid(payment),
        onLongPress: () => _showPaymentOptions(payment),
      ),
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

  void _navigateToForm(BuildContext context, {ScheduledPaymentEntity? payment}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ScheduledPaymentFormPage(
          paymentToEdit: payment,
        ),
      ),
    );
  }

  void _confirmMarkAsPaid(ScheduledPaymentEntity payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Marcar como pagado'),
        content: Text(
          '¿Confirmas que has realizado el pago de ${payment.name} por \$${payment.amount.toStringAsFixed(2)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ScheduledPaymentBloc>().add(
                    ScheduledPaymentMarkAsPaidRequested(paymentId: payment.id),
                  );
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _showPaymentOptions(ScheduledPaymentEntity payment) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withAlpha(76),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF10B981)),
                title: const Text('Marcar como pagado'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmMarkAsPaid(payment);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_rounded, color: Color(0xFF6366F1)),
                title: const Text('Editar'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToForm(context, payment: payment);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_rounded, color: Color(0xFFEF4444)),
                title: const Text('Eliminar',
                    style: TextStyle(color: Color(0xFFEF4444))),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(payment);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(ScheduledPaymentEntity payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar pago programado'),
        content: const Text(
            '¿Estás seguro de que deseas eliminar este pago programado?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ScheduledPaymentBloc>().add(
                    ScheduledPaymentDeleteRequested(paymentId: payment.id),
                  );
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
