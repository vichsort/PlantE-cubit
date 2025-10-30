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
import 'package:plante/features/auth/cubit/auth_state.dart';
import 'package:plante/features/profile/services/profile_service.dart';

final ApiService apiService = ApiService();
final SecureStorageService secureStorageService = SecureStorageService();
final AuthService authService = AuthService(apiService, secureStorageService);
final AppRouter appRouter = AppRouter();
final GardenService gardenService = GardenService(apiService);
final LocationService locationService = LocationService();
final ProfileService profileService = ProfileService(apiService);
final IdentificationService identificationService = IdentificationService(
  apiService,
  locationService,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  // Chave do navigator, nos permite controlar a navegação globalmente
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: apiService),
        RepositoryProvider.value(value: secureStorageService),
        RepositoryProvider.value(value: authService),
        RepositoryProvider.value(value: gardenService),
        RepositoryProvider.value(value: identificationService),
        RepositoryProvider.value(value: locationService),
        RepositoryProvider.value(value: profileService),
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

          navigatorKey: _navigatorKey,

          // Cuidador do navigator para escutar mudanças no AuthCubit
          builder: (context, child) {
            // 'child' aqui é o widget Navigator que o MaterialApp cria
            return BlocListener<AuthCubit, AuthState>(
              listener: (context, state) {
                // Pega o NavigatorState através da nossa chave global
                final navigator = _navigatorKey.currentState;
                if (navigator == null) return;

                // Lógica de Redirecionamento Global
                if (state is Unauthenticated) {
                  // Se o estado for 'Unauthenticated' (por logout ou falha inicial)
                  // Navega para /login e REMOVE todas as outras telas da pilha.
                  print(
                    "VIGIA GLOBAL: Estado Unauthenticated! Navegando para /login.",
                  );
                  navigator.pushNamedAndRemoveUntil('/login', (route) => false);
                } else if (state is Authenticated) {
                  // Se o estado for 'Authenticated' (após login ou na verificação inicial)
                  // Navega para /main (MainScreen) e REMOVE a tela de login/splash da pilha.
                  print(
                    "VIGIA GLOBAL: Estado Authenticated! Navegando para /main.",
                  );
                  navigator.pushNamedAndRemoveUntil('/main', (route) => false);
                }
              },
              child: child!, // Retorna o 'child' (o Navigator)
            );
          },

          initialRoute: '/',
          onGenerateRoute: appRouter.onGenerateRoute,
        ),
      ),
    );
  }
}
