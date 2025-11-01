import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:plante/features/auth/services/auth_service.dart'; // Para enviar o token

class NotificationUtil {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  // ignore: unused_field
  final AuthService _authService;
  final GlobalKey<NavigatorState> _navigatorKey;

  NotificationUtil({
    required AuthService authService,
    required GlobalKey<NavigatorState> navigatorKey,
  }) : _authService = authService,
       _navigatorKey = navigatorKey;

  /// Inicializa todo o sistema de notificações.
  /// Chame isso *após* o usuário estar autenticado.
  Future<void> initialize() async {
    // 1. Pedir permissão ao usuário (iOS e Android 13+)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('NotificationUtil: Permissão concedida pelo usuário.');

      // 2. Configurar os listeners (o que fazer ao receber/tocar)
      _setupListeners();

      // 3. Pegar o token e enviar ao backend
      await _getAndSendToken();

      // 4. Lidar com token refresh
      _fcm.onTokenRefresh.listen((newToken) {
        _sendTokenToBackend(newToken); // Envia o novo token automaticamente
      });

      // 5. Checar se o app foi aberto por uma notificação (estado Terminado)
      await handleInitialMessage();
    } else {
      print('NotificationUtil: Permissão negada pelo usuário.');
    }
  }

  /// Configura os listeners para mensagens em primeiro e segundo plano
  void _setupListeners() {
    // A. App em PRIMEIRO PLANO (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('FCM: Mensagem recebida em PRIMEIRO PLANO!');
      if (message.notification != null) {
        print(
          'Mensagem: ${message.notification!.title} - ${message.notification!.body}',
        );
        // TODO: Mostrar um SnackBar ou Dialog customizado
        // (Ex: usando um StreamController para o 'main.dart' ouvir e mostrar)
      }
    });

    // B. App em SEGUNDO PLANO (Background) e usuário TOCA na notificação
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('FCM: App aberto pela notificação (Background): ${message.data}');
      _handleNotificationNavigation(message.data);
    });
  }

  /// Pega o token FCM atual e o envia para o backend Flask
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

  /// Função auxiliar para enviar o token (reutilizável)
  Future<void> _sendTokenToBackend(String token) async {
    try {
      // TODO: Este método precisa ser criado no AuthService
      // await _authService.sendFcmToken(token);
      print("FCM: (Simulação) Token enviado ao backend com sucesso.");
    } catch (e) {
      print("FCM: Falha ao enviar token ao backend: $e");
      // (Não re-lança o erro, pois não é crítico para o app parar)
    }
  }

  /// Verifica se o app foi aberto do estado TERMINADO por uma notificação
  Future<void> handleInitialMessage() async {
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();

    if (initialMessage != null) {
      print(
        'FCM: App aberto pela notificação (Terminado): ${initialMessage.data}',
      );
      // Adiciona um pequeno delay para garantir que a UI de navegação esteja pronta
      await Future.delayed(const Duration(milliseconds: 500));
      _handleNotificationNavigation(initialMessage.data);
    }
  }

  /// Lógica central de navegação baseada no payload 'data' da notificação
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    // O backend DEVE enviar um payload 'data' assim:
    // "data": {
    //   "navigation_type": "plant_detail",
    //   "plant_id": "uuid-da-planta-aqui"
    // }

    final String? type = data['navigation_type'];
    final String? plantId =
        data['plant_id']; // Nosso backend precisa enviar isso

    if (type == 'plant_detail' && plantId != null) {
      print("FCM Navigating: Indo para /plant-detail com ID: $plantId");
      // Usa a GlobalKey do Navigator para navegar de qualquer lugar!
      _navigatorKey.currentState?.pushNamed(
        '/plant-detail',
        arguments: plantId,
      );
    } else {
      print("FCM Navigating: Payload de navegação desconhecido ou incompleto.");
      // Fallback: Apenas vai para a tela principal
      _navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/main',
        (route) => false,
      );
    }
  }
}
