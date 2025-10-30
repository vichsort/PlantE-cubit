import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// -- Cubits e services --
import 'package:plante/features/plant_detail/cubit/plant_detail_cubit.dart';
import 'package:plante/core/utils/location_utils.dart';
import 'package:plante/features/garden/services/garden_service.dart';
import 'package:plante/features/garden/services/identification_service.dart';

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
        final arguments = settings.arguments;
        if (arguments is String) {
          final plantId = arguments;
          return MaterialPageRoute(
            // O 'builder' nos dá um 'context' que tem acesso
            // aos serviços globais providos no main.dart
            builder: (context) => BlocProvider<PlantDetailCubit>(
              create: (context) => PlantDetailCubit(
                userPlantId: plantId, // 1. Passa o ID da planta
                // 2. Lê os serviços globais do contexto
                gardenService: context.read<GardenService>(),
                identificationService: context.read<IdentificationService>(),
                locationService: context.read<LocationService>(),
              )..fetchDetails(), // 3. Chama a busca inicial de dados
              child: const PlantDetailScreen(), // 4. Constrói a tela
            ),
          );
        } else {
          // Argumento inválido
          print(
            "Erro de Roteamento: Argumento inválido para /plant-detail. Esperado: String, Recebido: ${arguments.runtimeType}",
          );
          return _errorRoute(message: 'ID da planta inválido ou ausente.');
        }
      // -------------------------------

      default:
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
