import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// -- Core --
import 'package:plante/core/network/api_service.dart';
import 'package:plante/core/storage/secure_storage_service.dart';
import 'core/utils/location_utils.dart';
import 'package:plante/app_theme.dart';
import 'package:plante/app_router.dart';

//-- Features --
import 'package:plante/features/auth/cubit/auth_cubit.dart';
import 'package:plante/features/auth/services/auth_service.dart';
import 'package:plante/features/garden/services/garden_service.dart';
import 'package:plante/features/garden/services/identification_service.dart';
import 'package:plante/features/profile/services/profile_service.dart';

final ApiService apiService = ApiService();
final SecureStorageService secureStorageService = SecureStorageService();
final AuthService authService = AuthService(apiService, secureStorageService);
final AppRouter appRouter = AppRouter();
final GardenService gardenService = GardenService(apiService);
final ProfileService profileService = ProfileService(apiService);
final LocationService locationService = LocationService();
// 2. Passe a instância única para o IdentificationService
final IdentificationService identificationService = IdentificationService(
  apiService,
  locationService, // <-- Passe a instância
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // o que falta fazer:
  // - implementar splash screen
  // - logoff -> desconectar e tela de login
  // - tela específica pra planta (detalhes, edição, remoção)
  // - tela do perfil

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: apiService),
        RepositoryProvider.value(value: secureStorageService),
        RepositoryProvider.value(value: authService),
        RepositoryProvider.value(value: gardenService),
        RepositoryProvider.value(value: identificationService),
        RepositoryProvider.value(value: profileService),
        RepositoryProvider.value(value: locationService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) {
              final authService = context.read<AuthService>();
              return AuthCubit(authService)..checkAuthStatus();
            },
            lazy: false,
          ),
        ],
        child: MaterialApp(
          title: 'Plante App',
          themeMode: ThemeMode.system,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          onGenerateRoute: appRouter.onGenerateRoute,
        ),
      ),
    );
  }
}
