import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// -- Core Services --
import 'core/network/api_service.dart';
import 'core/storage/secure_storage_service.dart';
import 'app_theme.dart';
import 'app_router.dart';

//-- Features --
import 'package:plante/features/auth/cubit/auth_cubit.dart';
import 'package:plante/features/auth/services/auth_service.dart';
import 'package:plante/features/garden/services/garden_service.dart';
import 'package:plante/features/garden/services/identification_service.dart';

final ApiService apiService = ApiService();
final SecureStorageService secureStorageService = SecureStorageService();
final AuthService authService = AuthService(apiService, secureStorageService);
final AppRouter appRouter = AppRouter();
final GardenService gardenService = GardenService(apiService);
final IdentificationService identificationService = IdentificationService(
  apiService,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // o que falta fazer:
  // - implementar splash screen
  // - implementar onboarding
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
