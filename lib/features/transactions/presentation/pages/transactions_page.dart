// Pages - Transactions Page
// Página principal de transacciones con AppBar y navegación
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/category_service.dart' hide CategoryData;
import '../../../../core/services/notification_storage_service.dart';
import '../../../../injection_container.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../budgets/presentation/pages/budgets_page.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../../../scheduled_payments/presentation/bloc/scheduled_payment_bloc.dart';
import '../../../scheduled_payments/presentation/bloc/scheduled_payment_event.dart';
import '../../../scheduled_payments/presentation/bloc/scheduled_payment_state.dart';
import '../../../scheduled_payments/domain/entities/scheduled_payment_entity.dart';
import '../../../scheduled_payments/presentation/widgets/scheduled_payment_card.dart';
import '../../../scheduled_payments/presentation/pages/scheduled_payment_form_page.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../widgets/organisms/balance_summary_card.dart';
import '../widgets/organisms/transaction_list.dart';
import 'transaction_form_page.dart';

/// Página principal de transacciones
class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTransactions();
    _loadScheduledPayments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadTransactions() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final transactionBloc = context.read<TransactionBloc>();
      transactionBloc.setCurrentUserId(authState.user.id);
      transactionBloc.add(TransactionLoadRequested(
        params: TransactionFilterParams(userId: authState.user.id),
      ));
    }
  }

  void _loadScheduledPayments() {
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
      appBar: _buildAppBar(context, colorScheme),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransactionsBody(context),
          _buildScheduledPaymentsBody(context),
        ],
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ColorScheme colorScheme) {
    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final userName = state is AuthAuthenticated
              ? state.user.displayName
              : 'Usuario';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¡Hola, $userName!',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Text(
                'Mis Finanzas',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        // Botón de notificaciones
        _NotificationButton(),
        // Botón de filtrar
        IconButton(
          onPressed: _showFilterDialog,
          icon: const Icon(Icons.filter_list_rounded),
          tooltip: 'Filtrar',
        ),
        // Avatar del usuario
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final user = state is AuthAuthenticated ? state.user : null;

            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () => _showUserMenu(context, user),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF6366F1).withAlpha(51),
                  backgroundImage: user?.photoUrl != null
                      ? NetworkImage(user!.photoUrl!)
                      : null,
                  child: user?.photoUrl == null
                      ? Text(
                          _getInitials(user?.displayName ?? 'U'),
                          style: const TextStyle(
                            color: Color(0xFF6366F1),
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : null,
                ),
              ),
            );
          },
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF6366F1),
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicatorColor: const Color(0xFF6366F1),
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'Historial', icon: Icon(Icons.receipt_long_rounded)),
          Tab(text: 'Programados', icon: Icon(Icons.schedule_rounded)),
        ],
      ),
    );
  }

  Widget _buildTransactionsBody(BuildContext context) {
    return BlocConsumer<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionOperationSuccess) {
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
        } else if (state is TransactionError) {
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
        if (state is TransactionLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is TransactionLoaded) {
          return Column(
            children: [
              // Balance Card
              BalanceSummaryCard(
                totalIncome: state.totalIncome,
                totalExpense: state.totalExpense,
              ),

              // Lista de transacciones
              Expanded(
                child: TransactionList(
                  transactions: state.transactions,
                  categoryResolver: _resolveCategoryData,
                  onTransactionTap: _onTransactionTap,
                  onTransactionLongPress: _showTransactionOptions,
                  onRefresh: _loadTransactions,
                  emptyStateAction: FilledButton.icon(
                    onPressed: () => _navigateToForm(context),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Agregar transacción'),
                  ),
                ),
              ),
            ],
          );
        }

        if (state is TransactionError) {
          return TransactionList(
            transactions: const [],
            errorMessage: state.message,
            categoryResolver: _resolveCategoryData,
            onRefresh: _loadTransactions,
          );
        }

        // Estado inicial
        return const Center(
          child: Text('Cargando...'),
        );
      },
    );
  }

  Widget _buildScheduledPaymentsBody(BuildContext context) {
    return BlocConsumer<ScheduledPaymentBloc, ScheduledPaymentState>(
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
          return _buildScheduledEmptyState();
        }

        return _buildScheduledPaymentsList(payments);
      },
    );
  }

  Widget _buildScheduledEmptyState() {
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
              onPressed: () => _navigateToScheduledForm(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Crear pago programado'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduledPaymentsList(List<ScheduledPaymentEntity> payments) {
    final overduePayments = payments.where((p) => p.isActive && p.isOverdue).toList();
    final upcomingPayments = payments.where((p) => p.isActive && !p.isOverdue).toList();

    return RefreshIndicator(
      onRefresh: () async => _loadScheduledPayments(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (overduePayments.isNotEmpty) ...[
            _buildScheduledSectionHeader('Vencidos', const Color(0xFFEF4444), Icons.warning_rounded),
            const SizedBox(height: 8),
            ...overduePayments.map((payment) => _buildScheduledPaymentCard(payment)),
            const SizedBox(height: 24),
          ],
          if (upcomingPayments.isNotEmpty) ...[
            _buildScheduledSectionHeader('Próximos pagos', const Color(0xFF6366F1), Icons.schedule_rounded),
            const SizedBox(height: 8),
            ...upcomingPayments.map((payment) => _buildScheduledPaymentCard(payment)),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduledSectionHeader(String title, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }

  Widget _buildScheduledPaymentCard(ScheduledPaymentEntity payment) {
    final category = sl<CategoryService>().getCategory(payment.categoryId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ScheduledPaymentCard(
        payment: payment,
        categoryName: category.name,
        categoryIcon: _getScheduledIconFromCode(category.iconCode),
        categoryColor: Color(int.parse(category.colorHex.replaceFirst('#', '0xFF'))),
        onTap: () => _navigateToScheduledForm(context, payment: payment),
        onMarkPaid: () => _confirmMarkAsPaid(payment),
        onLongPress: () => _showScheduledPaymentOptions(payment),
      ),
    );
  }

  IconData _getScheduledIconFromCode(String iconCode) {
    switch (iconCode.toLowerCase()) {
      case 'food': return Icons.restaurant_rounded;
      case 'transport': return Icons.directions_car_rounded;
      case 'shopping': return Icons.shopping_bag_rounded;
      case 'entertainment': return Icons.movie_rounded;
      case 'health': return Icons.health_and_safety_rounded;
      case 'home': return Icons.home_rounded;
      case 'utilities': return Icons.bolt_rounded;
      default: return Icons.category_rounded;
    }
  }

  void _navigateToScheduledForm(BuildContext context, {ScheduledPaymentEntity? payment}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ScheduledPaymentFormPage(paymentToEdit: payment),
      ),
    );
  }

  void _confirmMarkAsPaid(ScheduledPaymentEntity payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Marcar como pagado'),
        content: Text('¿Confirmas que has realizado el pago de ${payment.name} por \$${payment.amount.toStringAsFixed(2)}?'),
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
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _showScheduledPaymentOptions(ScheduledPaymentEntity payment) {
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
                leading: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981)),
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
                  _navigateToScheduledForm(context, payment: payment);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_rounded, color: Color(0xFFEF4444)),
                title: const Text('Eliminar', style: TextStyle(color: Color(0xFFEF4444))),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteScheduled(payment);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteScheduled(ScheduledPaymentEntity payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar pago programado'),
        content: const Text('¿Estás seguro de que deseas eliminar este pago programado?'),
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
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    // FAB cambia según la pestaña activa
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        final isScheduledTab = _tabController.index == 1;
        
        return FloatingActionButton.extended(
          onPressed: () {
            if (isScheduledTab) {
              _navigateToScheduledForm(context);
            } else {
              _navigateToForm(context);
            }
          },
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: Text(
            isScheduledTab ? 'Nuevo Pago' : 'Nueva',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        );
      },
    );
  }

  void _navigateToForm(BuildContext context, {TransactionEntity? transaction}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TransactionFormPage(
          transactionToEdit: transaction,
        ),
      ),
    );
  }

  void _onTransactionTap(TransactionEntity transaction) {
    _navigateToForm(context, transaction: transaction);
  }

  void _showTransactionOptions(TransactionEntity transaction) {
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
                leading: const Icon(Icons.edit_rounded, color: Color(0xFF6366F1)),
                title: const Text('Editar'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToForm(context, transaction: transaction);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_rounded, color: Color(0xFFEF4444)),
                title: const Text('Eliminar', style: TextStyle(color: Color(0xFFEF4444))),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(transaction);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(TransactionEntity transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar transacción'),
        content: const Text('¿Estás seguro de que deseas eliminar esta transacción?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<TransactionBloc>().add(
                    TransactionDeleteRequested(transactionId: transaction.id),
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

  void _showFilterDialog() {
    // TODO: Implementar diálogo de filtros
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filtros próximamente...')),
    );
  }

  void _showUserMenu(BuildContext context, UserEntity? user) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
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
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFF6366F1).withAlpha(51),
                backgroundImage: user?.photoUrl != null
                    ? NetworkImage(user!.photoUrl!)
                    : null,
                child: user?.photoUrl == null
                    ? Text(
                        _getInitials(user?.displayName ?? 'U'),
                        style: const TextStyle(
                          color: Color(0xFF6366F1),
                          fontWeight: FontWeight.w600,
                          fontSize: 24,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                user?.displayName ?? 'Usuario',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? '',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              // Opción de Presupuestos
              ListTile(
                leading: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Color(0xFF6366F1),
                ),
                title: const Text('Presupuestos'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const BudgetsPage(),
                    ),
                  );
                },
              ),
              const Divider(),
              // Cerrar sesión
              ListTile(
                leading: Icon(
                  Icons.logout_rounded,
                  color: colorScheme.error,
                ),
                title: Text(
                  'Cerrar sesión',
                  style: TextStyle(color: colorScheme.error),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.read<AuthBloc>().add(const AuthSignOutRequested());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }
  /// Resuelve datos de categoría desde su ID
  CategoryData _resolveCategoryData(String categoryId) {
    final category = sl<CategoryService>().getCategory(categoryId);
    return CategoryData(
      name: category.name,
      iconCode: category.iconCode,
      colorHex: category.colorHex,
    );
  }
}

/// Botón de notificaciones con badge
class _NotificationButton extends StatefulWidget {
  @override
  State<_NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<_NotificationButton> {
  late final NotificationStorageService _storageService;

  @override
  void initState() {
    super.initState();
    _storageService = sl<NotificationStorageService>();
    _storageService.addListener(_onNotificationsChanged);
  }

  @override
  void dispose() {
    _storageService.removeListener(_onNotificationsChanged);
    super.dispose();
  }

  void _onNotificationsChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _storageService.unreadCount;
    
    return IconButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const NotificationsPage(),
          ),
        );
      },
      icon: Badge(
        isLabelVisible: unreadCount > 0,
        label: Text(
          unreadCount > 9 ? '9+' : unreadCount.toString(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: const Icon(Icons.notifications_outlined),
      ),
      tooltip: 'Notificaciones',
    );
  }
}
