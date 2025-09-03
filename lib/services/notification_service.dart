import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Inicializa timezone
    tz.initializeTimeZones();

    // Configura as configurações iniciais
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Ação quando a notificação é clicada
        debugPrint('Notificação clicada: ${response.payload}');
      },
    );

    // Solicita permissão para notificações
    await _requestPermissions();
  }

  Future<bool> _requestPermissions() async {
    // Verifica se já tem permissão
    var status = await Permission.notification.status;

    // Se não estiver concedida, solicita
    if (status.isDenied) {
      await Permission.notification.request();
      status = await Permission.notification.status;
    }

    return status.isGranted;
  }

  // Agenda uma notificação para quando um produto estiver próximo do vencimento
  Future<void> scheduleProductExpirationNotification({
    required int id,
    required String title,
    required String body,
    required DateTime expirationDate,
    int daysBefore = 1, // Notificar 1 dia antes por padrão
  }) async {
    try {
      // Calcula quando a notificação deve ser exibida
      final notificationTime = expirationDate.subtract(
        Duration(days: daysBefore),
      );

      // Se a data já passou, não agenda
      if (notificationTime.isBefore(DateTime.now())) {
        debugPrint('Não foi possível agendar notificação: data já passou');
        return;
      }

      // Cria o ID único para a notificação
      final notificationId = id * 10 + daysBefore;

      // Cria o canal de notificação (obrigatório para Android 8.0+)
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'product_expiration_channel',
        'Avisos de Validade',
        description: 'Notificações sobre produtos próximos do vencimento',
        importance: Importance.high,
      );

      // Cria o canal de notificação
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);

      // Agenda a notificação
      await _notificationsPlugin.zonedSchedule(
        notificationId,
        title,
        body,
        tz.TZDateTime.from(notificationTime, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: channel.importance,
            priority: Priority.high,
            showWhen: true,
            enableVibration: true,
            playSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'product_expiration|$id|$daysBefore',
      );

      debugPrint('Notificação agendada para ${notificationTime.toString()}');
    } catch (e) {
      debugPrint('Erro ao agendar notificação: $e');
    }
  }

  // Cancela uma notificação agendada
  Future<void> cancelNotification(int id, {int daysBefore = 1}) async {
    final notificationId = id * 10 + daysBefore;
    await _notificationsPlugin.cancel(notificationId);
  }

  // Cancela todas as notificações
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  // Verifica se há notificações pendentes
  Future<bool> hasPendingNotifications() async {
    final pendingNotifications = await _notificationsPlugin
        .pendingNotificationRequests();
    return pendingNotifications.isNotEmpty;
  }
}
