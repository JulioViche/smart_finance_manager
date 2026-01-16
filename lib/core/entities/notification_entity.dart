// Core - Notification Entity
// Entidad para representar una notificación local guardada

import 'package:equatable/equatable.dart';

/// Tipos de notificación
enum NotificationType {
  budgetAlert,
  budgetExceeded,
  general,
}

/// Entidad de notificación
class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final NotificationType type;
  final String? payload;
  final bool isRead;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.type = NotificationType.general,
    this.payload,
    this.isRead = false,
  });

  NotificationEntity copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? createdAt,
    NotificationType? type,
    String? payload,
    bool? isRead,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'createdAt': createdAt.toIso8601String(),
      'type': type.name,
      'payload': payload,
      'isRead': isRead,
    };
  }

  factory NotificationEntity.fromJson(Map<String, dynamic> json) {
    return NotificationEntity(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.general,
      ),
      payload: json['payload'] as String?,
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id, title, body, createdAt, type, payload, isRead];
}
