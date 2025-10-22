
import 'package:flutter/material.dart';

import 'package:plante/features/garden/screens/garden_screen.dart';
import 'package:plante/features/profile/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Índice da aba atualmente selecionada (0 = Jardim, 1 = Perfil)
  int _currentIndex = 0;

  // Controlador para o PageView, permite animar a transição entre telas
  late final PageController _pageController;

  // Lista das telas que serão exibidas no PageView
  final List<Widget> _screens = [
    const GardenScreen(), // Tela Meu Jardim (Índice 0)
    const ProfileScreen(), // Tela Perfil (Índice 1)
  ];

  @override
  void initState() {
    super.initState();
    // Inicializa o PageController com a página inicial correspondente ao _currentIndex
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    // Libera os recursos do PageController quando a tela é destruída
    _pageController.dispose();
    super.dispose();
  }

  // Função chamada quando uma aba da NavigationBar é selecionada
  void _onTabTapped(int index) {
    // Anima a transição para a página correspondente no PageView
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300), // Duração da animação
      curve: Curves.easeInOut, // Curva da animação
    );
    // Não precisamos do setState aqui, pois o onPageChanged do PageView fará isso
  }

  // Função chamada quando o usuário desliza entre as páginas do PageView
  void _onPageChanged(int index) {
    // Atualiza o índice da aba selecionada na NavigationBar
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // O corpo da tela é o PageView que permite deslizar entre as telas filhas
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged, // Atualiza o índice ao deslizar
        children: _screens, // As telas a serem exibidas
      ),

      // A barra de navegação inferior (Material 3)
      bottomNavigationBar: NavigationBar(
        // Define qual aba está selecionada (controla o destaque visual)
        selectedIndex: _currentIndex,
        // Função chamada quando o usuário toca em um destino (aba)
        onDestinationSelected: _onTabTapped,
        // Define os destinos (abas) da barra de navegação
        destinations: const <NavigationDestination>[
          NavigationDestination(
            selectedIcon: Icon(Icons.eco), // Ícone quando selecionado
            icon: Icon(Icons.eco_outlined), // Ícone padrão
            label: 'Meu Jardim', // Texto da aba
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