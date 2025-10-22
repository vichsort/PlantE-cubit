import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// telas --
import 'presentation/splash_screen.dart';
import 'presentation/main_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/garden/screens/garden_screen.dart';
import 'features/plant_detail/screens/plant_detail_screen.dart';

class AppRouter {
  Route? onGenerateRoute(RouteSettings settings) {
    print("Navegando para: ${settings.name} com args: ${settings.arguments}"); // Para debug

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case '/main':
        return MaterialPageRoute(builder: (_) => const MainScreen());

      case '/garden': // Nossa tela principal (Home)
        // Aqui não precisamos passar argumentos, mas se o GardenCubit
        // não for global, precisaríamos provê-lo.
        return MaterialPageRoute(builder: (_) => const GardenScreen());

      case '/plant-detail':
        // Rota para a tela de detalhes de uma planta específica.
        // Esperamos receber o 'userPlantId' (String UUID) como argumento.
        final arguments = settings.arguments;
        if (arguments is String) {
          final plantId = arguments;
          return MaterialPageRoute(
            builder: (_) =>
            // --- Exemplo de como prover um Cubit específico da tela ---
            // BlocProvider(
            //   // Cria uma NOVA instância do Cubit para ESTA tela/rota
            //   create: (context) => PlantDetailCubit(
            //     userPlantId: plantId,
            //     // Passe o serviço necessário (pode vir do context.read se for global)
            //     // gardenService: context.read<GardenService>()
            //   )..fetchDetails(), // Chama fetchDetails() logo ao criar
               PlantDetailScreen(plantid: plantId), // Passa o ID para a tela
            // ),
          );
        } else {
          // Argumento inválido ou faltando para esta rota
          print("Erro de Roteamento: Argumento inválido para /plant-detail. Esperado: String, Recebido: ${arguments.runtimeType}");
          return _errorRoute(message: 'ID da planta inválido ou ausente.');
        }

      // Adicione outras rotas aqui (ex: '/settings')

      default:
        // Rota não encontrada
        print("Erro de Roteamento: Rota desconhecida: ${settings.name}");
        return _errorRoute();
    }
  }

  /// Rota de fallback para erros ou rotas não encontradas.
  static Route<dynamic> _errorRoute({String message = 'Página não encontrada!'}) {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erro de Navegação')),
        body: Center(child: Text(message)),
      );
    });
  }
}