import 'package:flutter/material.dart';

// -- Screens --
import 'package:plante/features/auth/screens/login_screen.dart';
import 'package:plante/features/auth/screens/register_screen.dart';
import 'package:plante/features/garden/screens/garden_screen.dart';
import 'package:plante/presentation/main_screen.dart';
import 'package:plante/features/plant_detail/screens/plant_detail_screen.dart';
import 'package:plante/presentation/splash_screen.dart';

class AppRouter {
  Route? onGenerateRoute(RouteSettings settings) {
    print(
      "Navegando para: ${settings.name} com args: ${settings.arguments}",
    ); // Para debug

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case '/main':
        return MaterialPageRoute(builder: (_) => const MainScreen());

      case '/garden':
        return MaterialPageRoute(builder: (_) => const GardenScreen());

      case '/plant-detail':
        // Rota para a tela de detalhes de uma planta específica.
        // Esperamos receber o 'userPlantId' (String UUID) como argumento.
        final arguments = settings.arguments;
        if (arguments is String) {
          return MaterialPageRoute(builder: (_) => PlantDetailScreen());
        } else {
          print(
            "Erro de Roteamento: Argumento inválido para /plant-detail. Esperado: String, Recebido: ${arguments.runtimeType}",
          );
          return _errorRoute(message: 'ID da planta inválido ou ausente.');
        }

      default:
        // Rota não encontrada
        print("Erro de Roteamento: Rota desconhecida: ${settings.name}");
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute({
    String message = 'Página não encontrada!',
  }) {
    return MaterialPageRoute(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(title: const Text('Erro de Navegação')),
          body: Center(child: Text(message)),
        );
      },
    );
  }
}
