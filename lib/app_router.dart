import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// -- Core --
import 'package:plante/core/utils/location_utils.dart';

// -- Cubits e services --
import 'package:plante/features/plant_detail/cubit/plant_detail_cubit.dart';
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
            builder: (context) => BlocProvider<PlantDetailCubit>(
              create: (context) => PlantDetailCubit(
                userPlantId: plantId,
                gardenService: context.read<GardenService>(),
                identificationService: context.read<IdentificationService>(),
                locationService: context.read<LocationService>(),
              )..fetchDetails(),
              child: const PlantDetailScreen(),
            ),
          );
        } else {
          // Argumento inválido
          return _errorRoute(message: 'ID da planta inválido ou ausente.');
        }

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
