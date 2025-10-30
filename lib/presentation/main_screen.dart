import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// -- Screens --
import 'package:plante/features/garden/screens/garden_screen.dart';
import 'package:plante/features/profile/screens/profile_screen.dart';

// -- Cubits --
import 'package:plante/features/garden/cubit/garden_cubit.dart';
import 'package:plante/features/garden/services/garden_service.dart';
import 'package:plante/features/garden/services/identification_service.dart';
import 'package:plante/features/profile/cubit/profile_cubit.dart';
import 'package:plante/features/profile/services/profile_service.dart';
import 'package:plante/features/auth/cubit/auth_cubit.dart';

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

    _screens = [
      BlocProvider<GardenCubit>(
        create: (context) => GardenCubit(
          context.read<GardenService>(),
          context.read<IdentificationService>(),
          context.read<AuthCubit>(),
        ),
        child: const GardenScreen(),
      ),
      BlocProvider<ProfileCubit>(
        create: (context) => ProfileCubit(context.read<ProfileService>()),
        // TODO: Chamar cubit.loadProfile() aqui no futuro
        child: const ProfileScreen(),
      ),
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
