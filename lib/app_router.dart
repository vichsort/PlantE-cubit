import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// --- Importe suas Telas (Screens) ---
// (Crie arquivos vazios para elas por enquanto, se ainda não existirem)
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/garden/screens/garden_screen.dart';
import 'features/plant_detail/screens/plant_detail_screen.dart';

// --- Importe Cubits e Serviços necessários para prover nas rotas ---
// (Importe quando precisar passar dependências ou criar Cubits específicos da rota)
// import 'features/plant_detail/cubit/plant_detail_cubit.dart';
// import 'core/network/api_service.dart'; // Exemplo
// import 'features/garden/services/garden_service.dart'; // Exemplo

class AppRouter {
  // --- (Opcional) Instanciar serviços aqui se não usar Injeção de Dependência ---
  // final ApiService apiService = ApiService();
  // final GardenService gardenService = GardenService(apiService); // Exemplo

  /// Gera rotas com base no nome da rota solicitada ([settings.name]).
  Route? onGenerateRoute(RouteSettings settings) {
    print("Navegando para: ${settings.name} com args: ${settings.arguments}"); // Para debug

    switch (settings.name) {
      case '/':
      // A rota raiz '/' pode redirecionar ou ser uma tela específica.
      // A lógica no main.dart (ou um SplashScreen) decidirá se vai para '/login' ou '/garden'.
      // Por segurança, podemos direcionar para login se a rota raiz for chamada diretamente.
      // Ou retornar null e deixar o 'home' do MaterialApp decidir (se definido).
        return MaterialPageRoute(builder: (_) => const LoginScreen()); // Ou GardenScreen, ou SplashScreen

      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

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