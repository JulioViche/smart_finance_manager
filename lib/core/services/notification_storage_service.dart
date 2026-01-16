// Core - Notification Storage Service
// Servicio para almacenar y gestionar el historial de notificaciones

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../entities/notification_entity.dart';

/// Servicio de almacenamiento de notificaciones
class NotificationStorageService extends ChangeNotifier {
  static const String _storageKey = 'notification_history';
  static const int _maxNotifications = 50;
  
  List<NotificationEntity> _notifications = [];
  int _unreadCount = 0;

  /// Lista de notificaciones (solo lectura)
  List<NotificationEntity> get notifications => List.unmodifiable(_notifications);
  
  /// Cantidad de notificaciones no leídas
  int get unreadCount => _unreadCount;

  /// Indica si hay notificaciones no leídas
  bool get hasUnread => _unreadCount > 0;

  /// Inicializa el servicio cargando notificaciones guardadas
  Future<void> initialize() async {
    await _loadNotifications();
    _updateUnreadCount();
    debugPrint('NotificationStorageService: ${_notifications.length} notificaciones cargadas');
  }

  /// Agrega una nueva notificación
  Future<void> addNotification({
    required String title,
    required String body,
    NotificationType type = NotificationType.general,
    String? payload,
  }) async {
    final notification = NotificationEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      createdAt: DateTime.now(),
      type: type,
      payload: payload,
      isRead: false,
    );

    _notifications.insert(0, notification);
    
    // Limitar el número de notificaciones almacenadas
    if (_notifications.length > _maxNotifications) {
      _notifications = _notifications.take(_maxNotifications).toList();
    }

    _updateUnreadCount();
    await _saveNotifications();
    notifyListeners();
  }

  /// Marca una notificación como leída
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _updateUnreadCount();
      await _saveNotifications();
      notifyListeners();
    }
  }

  /// Marca todas las notificaciones como leídas
  Future<void> markAllAsRead() async {
    bool changed = false;
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        changed = true;
      }
    }
    if (changed) {
      _updateUnreadCount();
      await _saveNotifications();
      notifyListeners();
    }
  }

  /// Elimina una notificación
  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    _updateUnreadCount();
    await _saveNotifications();
    notifyListeners();
  }

  /// Limpia todas las notificaciones
  Future<void> clearAll() async {
    _notifications.clear();
    _unreadCount = 0;
    await _saveNotifications();
    notifyListeners();
  }

  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        _notifications = jsonList
            .map((item) => NotificationEntity.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error cargando notificaciones: $e');
      _notifications = [];
    }
  }

  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _notifications.map((n) => n.toJson()).toList();
      await prefs.setString(_storageKey, json.encode(jsonList));
    } catch (e) {
      debugPrint('Error guardando notificaciones: $e');
    }
  }
}
