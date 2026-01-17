import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'injection_container.dart' as di;
import 'core/services/notification_service.dart';
import 'core/services/notification_storage_service.dart';
import 'core/services/category_service.dart';
import 'core/services/scheduled_payment_notification_manager.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/transactions/presentation/bloc/transaction_bloc.dart';
import 'features/transactions/presentation/pages/transactions_page.dart';
import 'features/budgets/presentation/bloc/budget_bloc.dart';
import 'features/scheduled_payments/presentation/bloc/scheduled_payment_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inicializar datos de localización para formateo de fechas en español
  await initializeDateFormatting('es', null);

  // Inicializar inyección de dependencias
  await di.initializeDependencies();

  // Inicializar servicios
  await di.sl<NotificationStorageService>().initialize();
  await di.sl<CategoryService>().initialize();
  await di.sl<NotificationService>().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Proveedor global del AuthBloc
        BlocProvider(
          create: (_) => di.sl<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        // Proveedor global del TransactionBloc
        BlocProvider(
          create: (_) => di.sl<TransactionBloc>(),
        ),
        // Proveedor global del BudgetBloc
        BlocProvider(
          create: (_) => di.sl<BudgetBloc>(),
        ),
        // Proveedor global del ScheduledPaymentBloc
        BlocProvider(
          create: (_) => di.sl<ScheduledPaymentBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Smart Finance Manager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1), // Índigo
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1), // Índigo
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

/// Widget que decide qué pantalla mostrar según el estado de autenticación
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Cuando el usuario se autentica, sincronizar notificaciones de pagos
        if (state is AuthAuthenticated) {
          _syncPaymentNotifications(state.user.id);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          // Usuario autenticado -> mostrar TransactionsPage
          if (state is AuthAuthenticated) {
            return const TransactionsPage();
          }

          // Usuario no autenticado -> mostrar LoginPage
          if (state is AuthUnauthenticated) {
            return const LoginPage();
          }

          // Error de autenticación -> mostrar LoginPage
          if (state is AuthError) {
            return const LoginPage();
          }

          // Estado inicial o cargando -> mostrar splash
          return Scaffold(
            backgroundColor: const Color(0xFF6366F1),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(51),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Smart Finance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Sincroniza las notificaciones de pagos programados
  void _syncPaymentNotifications(String userId) {
    di.sl<ScheduledPaymentNotificationManager>().syncNotifications(userId);
  }
}
