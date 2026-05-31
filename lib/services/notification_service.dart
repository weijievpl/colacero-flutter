import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// ColaCero Notification Service
/// Handles local notifications with proper Android channels
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Channel IDs
  static const _channelTicket = 'ticket_updates';
  static const _channelAppointment = 'appointment_reminders';
  static const _channelSync = 'sync_status';

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        // Navigation handled via deep link payload
        debugPrint('Notification tapped: ${response.payload}');
      },
    );

    // Create notification channels
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelTicket,
          'Turnos',
          description: 'Notificaciones sobre tu turno en la fila',
          importance: Importance.high,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelAppointment,
          'Citas',
          description: 'Recordatorios de citas programadas',
          importance: Importance.high,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelSync,
          'Sincronización',
          description: 'Estado de sincronización de datos',
          importance: Importance.low,
        ),
      );

      // Request permission for Android 13+
      await androidPlugin.requestNotificationsPermission();
    }

    _initialized = true;
  }

  /// Notify user their turn is coming up
  Future<void> notifyTurnApproaching(int number, int position) async {
    if (!_initialized) return;
    await _plugin.show(
      number,
      '¡Tu turno se acerca!',
      'Eres el número $number — posición $position en la fila',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelTicket,
          'Turnos',
          icon: '@mipmap/ic_launcher',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: 'turn_approaching:$number',
    );
  }

  /// Notify user their turn has been called
  Future<void> notifyTurnCalled(int number) async {
    if (!_initialized) return;
    await _plugin.show(
      number + 10000,
      '¡Es tu turno!',
      'Número $number — acércate al mostrador',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelTicket,
          'Turnos',
          icon: '@mipmap/ic_launcher',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          enableVibration: true,
        ),
      ),
      payload: 'turn_called:$number',
    );
  }

  /// Appointment reminder
  Future<void> notifyAppointmentReminder(String name, DateTime time) async {
    if (!_initialized) return;
    final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    await _plugin.show(
      time.millisecondsSinceEpoch ~/ 1000,
      'Recordatorio de cita',
      '$name — hoy a las $timeStr',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelAppointment,
          'Citas',
          icon: '@mipmap/ic_launcher',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: 'appointment:${time.toIso8601String()}',
    );
  }

  /// Sync completed silently
  Future<void> notifySyncComplete(int itemsCount) async {
    if (!_initialized) return;
    await _plugin.show(
      99999,
      'Sincronización completada',
      '$itemsCount cambios sincronizados correctamente',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelSync,
          'Sincronización',
          icon: '@mipmap/ic_launcher',
          importance: Importance.low,
          priority: Priority.low,
          playSound: false,
        ),
      ),
    );
  }

  /// Recovery success
  Future<void> notifyRecoverySuccess(int number) async {
    if (!_initialized) return;
    await _plugin.show(
      number + 20000,
      'Turno recuperado',
      'Tu turno #$number ha sido restaurado',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelTicket,
          'Turnos',
          icon: '@mipmap/ic_launcher',
          importance: Importance.defaultImportance,
        ),
      ),
      payload: 'recovered:$number',
    );
  }

  Future<void> cancelAll() async {
    if (!_initialized) return;
    await _plugin.cancelAll();
  }
}
