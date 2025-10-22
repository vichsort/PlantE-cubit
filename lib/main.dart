// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core Services & Router & Theme
import 'core/network/api_service.dart';
import 'core/storage/secure_storage_service.dart';
import 'app_router.dart';
import 'app_theme.dart';

// Auth Feature Dependencies
import 'features/auth/cubit/auth_cubit.dart';
import 'features/auth/cubit/auth_state.dart';
import 'features/auth/services/auth_service.dart';

// (Opcional) Simple Service Locator - Alternativa a GetIt para começar
// Se for usar GetIt, substitua essa parte pela configuração do GetIt
final ApiService apiService = ApiService();
final SecureStorageService secureStorageService = SecureStorageService();
final AuthService authService = AuthService(apiService, secureStorageService);

void main() async {
  // 1. Garante que os bindings do Flutter estejam inicializados
  // Necessário se você usa 'await' antes de 'runApp' (ex: para carregar algo)
  WidgetsFlutterBinding.ensureInitialized();

  // (Opcional) Poderia inicializar outros serviços aqui se necessário

  // 2. Executa o aplicativo
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Instancia o router
  final AppRouter _appRouter = AppRouter();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 3. Provê o AuthCubit globalmente usando MultiBlocProvider
    //    Isso o torna disponível em toda a árvore de widgets abaixo.
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(authService)..checkAuthStatus(),
          // Chama checkAuthStatus() logo ao criar o Cubit para verificar
          // se já existe um token salvo e definir o estado inicial.
          lazy: false, // Garante que checkAuthStatus seja chamado na inicialização
        ),
        // (Adicione outros Cubits globais aqui se necessário no futuro)
      ],
      child: MaterialApp(
        title: 'Plante App',
        theme: AppTheme.lightTheme, // Aplica o tema definido
        debugShowCheckedModeBanner: false, // Remove o banner de debug

        // --- Gerenciamento de Rota Inicial Baseado no AuthState ---
        // Usamos um BlocBuilder aqui para decidir a tela inicial
        // OU podemos fazer isso dentro do onGenerateRoute no AppRouter
        // OU usar um SplashScreen que ouve o AuthState.
        // Esta é uma abordagem simples para começar:
        home: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              // Se autenticado, vai direto para a tela principal (ex: GardenScreen)
              // Precisamos garantir que a rota '/' ou '/garden' esteja definida no router
              // Uma abordagem mais robusta usaria Navigator.pushReplacementNamed aqui
              // ou deixaria o AppRouter lidar com isso baseado no estado inicial.
              // Por simplicidade inicial, podemos apenas mostrar a tela:
              // return GardenScreen(); // <<-- Precisa importar GardenScreen
              // Ou, melhor ainda, deixar o router decidir:
               WidgetsBinding.instance.addPostFrameCallback((_) {
                 Navigator.of(context).pushReplacementNamed('/garden');
               });
               return const Scaffold(body: Center(child: CircularProgressIndicator())); // Tela temporária
            } else if (state is Unauthenticated || state is AuthFailure) {
              // Se não autenticado ou falha, vai para a tela de Login
               WidgetsBinding.instance.addPostFrameCallback((_) {
                 Navigator.of(context).pushReplacementNamed('/login');
               });
               return const Scaffold(body: Center(child: CircularProgressIndicator())); // Tela temporária
            } else {
              // Estado AuthInitial ou AuthLoading, mostra um loading inicial
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
          },
        ),
        // Usa o onGenerateRoute do nosso AppRouter para todas as outras navegações
        onGenerateRoute: _appRouter.onGenerateRoute,
      ),
    );
  }
}