import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:plante/features/auth/services/auth_service.dart';

class NotificationUtil {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final AuthService _authService;
  final GlobalKey<NavigatorState> _navigatorKey;

  NotificationUtil({
    required AuthService authService,
    required GlobalKey<NavigatorState> navigatorKey,
  }) : _authService = authService,
       _navigatorKey = navigatorKey;

  Future<void> initialize() async {
    // Pedir permissão ao usuário
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('NotificationUtil: Permissão concedida pelo usuário.');

      // Configurar os listeners (o que fazer ao receber/tocar)
      _setupListeners();

      // Pegar o token e enviar ao backend
      await _getAndSendToken();

      // Lidar com token refresh
      _fcm.onTokenRefresh.listen(_sendTokenToBackend);

      // Checar se o app foi aberto por uma notificação (estado Terminado)
      await handleInitialMessage();
    } else {
      print('NotificationUtil: Permissão negada pelo usuário.');
    }
  }

  // Configura os listeners para mensagens em primeiro e segundo plano
  void _setupListeners() {
    // em primeiro plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('FCM: Mensagem recebida em PRIMEIRO PLANO!');
      final notification = message.notification;

      // Tenta pegar o contexto atual do navegador
      final context = _navigatorKey.currentContext;

      if (notification != null && context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  notification.title ?? 'Nova Notificação',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (notification.body != null)
                  Text(
                    notification.body!,
                    style: const TextStyle(color: Colors.white),
                  ),
              ],
            ),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            action: SnackBarAction(
              label: 'Ver',
              textColor: Colors.white,
              onPressed: () {
                _handleNotificationNavigation(message.data);
              },
            ),
          ),
        );
      }
    });

    // segundo plano
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('FCM: App aberto pela notificação (Background): ${message.data}');
      _handleNotificationNavigation(message.data);
    });
  }

  // Pega o token FCM atual e o envia para o backend Flask
  Future<void> _getAndSendToken() async {
    try {
      String? token = await _fcm.getToken();
      if (token != null) {
        print('FCM: Token do dispositivo: ${token.substring(0, 10)}...');
        await _sendTokenToBackend(token);
      } else {
        print('FCM: Falha ao obter token (retornou null).');
      }
    } catch (e) {
      print('FCM: Falha ao obter token: $e');
    }
  }

  // Função auxiliar para enviar o token
  Future<void> _sendTokenToBackend(String token) async {
    try {
      await _authService.sendFcmToken(token);
    } catch (e) {
      print("FCM: Falha ao enviar token ao backend: $e");
    }
  }

  // Verifica se o app foi aberto do estado TERMINADO por uma notificação
  Future<void> handleInitialMessage() async {
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();

    if (initialMessage != null) {
      print(
        'FCM: App aberto pela notificação (Terminado): ${initialMessage.data}',
      );
      // Adiciona um pequeno delay para garantir que a UI de navegação (MainScreen)
      // esteja 100% pronta antes de tentar navegar.
      await Future.delayed(const Duration(milliseconds: 1000));
      _handleNotificationNavigation(initialMessage.data);
    }
  }

  // Lógica central de navegação baseada no payload 'data' da notificação
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    // Aqui lemos o payload 'data' que o nosso worker Celery enviou:
    // data={
    //   "navigation_type": "plant_detail",
    //   "plant_id": "uuid-da-planta"
    // }

    final String? type = data['navigation_type'];
    final String? plantId = data['plant_id'];

    if (type == 'plant_detail' && plantId != null) {
      print("FCM Navigating: Indo para /plant-detail com ID: $plantId");

      _navigatorKey.currentState?.pushNamed(
        '/plant-detail',
        arguments: plantId, // Passa o ID da planta para a rota
      );
    }
    // --- Adicionar outros tipos de navegação aqui no futuro ---
    // else if (type == 'profile_achievement') {
    //   _navigatorKey.currentState?.pushNamed('/profile', arguments: ...);
    // }
    // ----------------------------------------------------
    else {
      print(
        "FCM Navigating: Payload de navegação desconhecido ou incompleto: $data",
      );
      // Fallback: Apenas vai para a tela principal (se não estivermos lá)
      _navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/main',
        (route) => false,
      );
    }
  }
}
