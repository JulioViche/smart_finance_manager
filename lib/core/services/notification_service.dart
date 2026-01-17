// Core - Notification Service
// Servicio para gestionar notificaciones locales y push
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../entities/notification_entity.dart';
import 'notification_storage_service.dart';

/// Servicio de notificaciones
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  NotificationStorageService? _storageService;

  bool _isInitialized = false;
  
  /// Configura el servicio de almacenamiento
  void setStorageService(NotificationStorageService storageService) {
    _storageService = storageService;
  }

  /// Canal de notificaciones para Android
  static const AndroidNotificationChannel _budgetChannel =
      AndroidNotificationChannel(
        'budget_alerts',
        'Alertas de Presupuesto',
        description: 'Notificaciones de gastos elevados y presupuestos',
        importance: Importance.high,
      );

  /// Inicializa el servicio de notificaciones
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Configuración para Android
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // Configuración para iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Crear canal de notificaciones en Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_budgetChannel);

    // Crear canal de recordatorios de pago en Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_paymentChannel);

    // Solicitar permisos
    await _requestPermissions();

    // Configurar Firebase Messaging
    await _setupFirebaseMessaging();

    _isInitialized = true;
    debugPrint('NotificationService inicializado');
  }

  /// Solicita permisos de notificación
  Future<void> _requestPermissions() async {
    // Permisos para notificaciones locales en Android 13+
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    // Permisos para Firebase Messaging
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Configura Firebase Cloud Messaging
  Future<void> _setupFirebaseMessaging() async {
    try {
      // Obtener token FCM
      final token = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $token');
    } catch (e) {
      // SERVICE_NOT_AVAILABLE puede ocurrir cuando:
      // - Google Play Services no está disponible
      // - No hay conexión a internet
      // - El emulador no tiene Google Play Services
      debugPrint('Error al obtener FCM token: $e');
      debugPrint('Las notificaciones push no estarán disponibles');
    }

    // Manejar mensajes en foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Manejar tap en notificación cuando app está en background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  /// Maneja mensajes en primer plano
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Mensaje FCM recibido en foreground: ${message.messageId}');

    if (message.notification != null) {
      showLocalNotification(
        title: message.notification!.title ?? 'Notificación',
        body: message.notification!.body ?? '',
      );
    }
  }

  /// Maneja tap en notificación cuando app está en background
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Notificación FCM abierta: ${message.messageId}');
    // TODO: Navegar a pantalla específica según el mensaje
  }

  /// Callback cuando se toca una notificación
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notificación tocada: ${response.payload}');
    // TODO: Navegar a pantalla específica según el payload
  }

  /// Muestra una notificación local
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0,
    NotificationType type = NotificationType.general,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'budget_alerts',
      'Alertas de Presupuesto',
      channelDescription: 'Notificaciones de gastos elevados y presupuestos',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(id, title, body, details, payload: payload);
    
    // Guardar en el historial
    await _storageService?.addNotification(
      title: title,
      body: body,
      type: type,
      payload: payload,
    );
  }

  /// Muestra notificación de gasto elevado
  Future<void> showHighSpendingAlert({
    required String categoryName,
    required double spentAmount,
    required double limitAmount,
    required double percentage,
  }) async {
    final percentageInt = (percentage * 100).toInt();

    await showLocalNotification(
      id: categoryName.hashCode,
      title: '⚠️ Alerta de Gasto Elevado',
      body:
          'Has gastado \$${spentAmount.toStringAsFixed(2)} de '
          '\$${limitAmount.toStringAsFixed(2)} ($percentageInt%) en $categoryName',
      payload: 'budget_alert:$categoryName',
      type: NotificationType.budgetAlert,
    );
  }

  /// Muestra notificación de presupuesto excedido
  Future<void> showBudgetExceededAlert({
    required String categoryName,
    required double spentAmount,
    required double limitAmount,
  }) async {
    final excess = spentAmount - limitAmount;

    await showLocalNotification(
      id: categoryName.hashCode + 1000,
      title: '🚨 Presupuesto Excedido',
      body:
          'Has excedido tu presupuesto de $categoryName por '
          '\$${excess.toStringAsFixed(2)}',
      payload: 'budget_exceeded:$categoryName',
      type: NotificationType.budgetExceeded,
    );
  }

  /// Obtiene el token FCM actual
  Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }

  /// Canal de notificaciones para recordatorios de pago
  static const AndroidNotificationChannel _paymentChannel =
      AndroidNotificationChannel(
        'payment_reminders',
        'Recordatorios de Pago',
        description: 'Notificaciones de pagos próximos y vencidos',
        importance: Importance.high,
      );

  /// Muestra notificación de pago próximo
  Future<void> showUpcomingPaymentAlert({
    required String paymentId,
    required String paymentName,
    required double amount,
    required int daysUntilDue,
  }) async {
    String daysText;
    if (daysUntilDue == 0) {
      daysText = 'vence hoy';
    } else if (daysUntilDue == 1) {
      daysText = 'vence mañana';
    } else {
      daysText = 'vence en $daysUntilDue días';
    }

    await showLocalNotification(
      id: paymentId.hashCode + 2000,
      title: '📅 Pago Próximo',
      body: '$paymentName (\$${amount.toStringAsFixed(2)}) $daysText',
      payload: 'upcoming_payment:$paymentId',
      type: NotificationType.upcomingPayment,
    );
  }

  /// Muestra notificación de pago vencido
  Future<void> showOverduePaymentAlert({
    required String paymentId,
    required String paymentName,
    required double amount,
    required int daysOverdue,
  }) async {
    await showLocalNotification(
      id: paymentId.hashCode + 3000,
      title: '⚠️ Pago Vencido',
      body: '$paymentName (\$${amount.toStringAsFixed(2)}) está vencido hace $daysOverdue días',
      payload: 'overdue_payment:$paymentId',
      type: NotificationType.overduePayment,
    );
  }

  /// Cancela una notificación programada
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Cancela todas las notificaciones de un pago específico
  Future<void> cancelPaymentNotifications(String paymentId) async {
    // Cancelar notificaciones de pago próximo y vencido
    await _localNotifications.cancel(paymentId.hashCode + 2000);
    await _localNotifications.cancel(paymentId.hashCode + 3000);
  }
}
