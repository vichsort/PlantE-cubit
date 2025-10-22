import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core Services & Router & Theme
import 'core/network/api_service.dart';
import 'core/storage/secure_storage_service.dart';
import 'app_theme.dart';
import 'app_router.dart';

// Auth Feature Dependencies
import 'features/auth/cubit/auth_cubit.dart';
import 'features/auth/services/auth_service.dart';

final ApiService apiService = ApiService();
final SecureStorageService secureStorageService = SecureStorageService();
final AuthService authService = AuthService(apiService, secureStorageService);
final AppRouter appRouter = AppRouter(); // Instancia o router

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(authService)..checkAuthStatus(),
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
    );
  }
}