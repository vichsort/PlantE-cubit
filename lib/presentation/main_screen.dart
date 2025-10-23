// lib/presentation/main_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Importe BlocProvider e context.read

// Importe as telas
import '../features/garden/screens/garden_screen.dart';
import '../features/profile/screens/profile_screen.dart';

// Importe o Cubit e os Serviços necessários para criar o GardenCubit
import '../features/garden/cubit/garden_cubit.dart';
import '../features/garden/services/garden_service.dart';
import '../features/garden/services/identification_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late final PageController _pageController;

  // Lista das telas que serão exibidas no PageView
  // É definida aqui para poder usar o 'context' do 'build' inicial
  // ou pode ser movida para dentro do 'build' se preferir.
  // Importante: A ordem DEVE corresponder à ordem da NavigationBar.
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);

    // Inicializa a lista de telas aqui, usando context.read
    // Nota: Usar context.read no initState é geralmente seguro para
    // ler providers que já existem acima (como os RepositoryProviders no main.dart)
    _screens = [
      // --- Envolve GardenScreen com BlocProvider ---
      BlocProvider<GardenCubit>(
        create: (context) => GardenCubit(
          // Lê os serviços que foram providos globalmente no main.dart
          context.read<GardenService>(),
          context.read<IdentificationService>(),
        ),
        // Não chamamos loadGarden aqui, deixamos o initState da GardenScreen
        // ou um gatilho inicial no build da GardenScreen fazer isso.
        child: const GardenScreen(), // O filho é a própria tela
      ),
      // ------------------------------------------
      const ProfileScreen(), // ProfileScreen (não precisa de Cubit específico aqui, por enquanto)
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabTapped,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            selectedIcon: Icon(Icons.eco),
            icon: Icon(Icons.eco_outlined),
            label: 'Meu Jardim',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person),
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}