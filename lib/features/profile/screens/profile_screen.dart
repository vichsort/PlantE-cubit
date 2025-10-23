import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plante/features/auth/cubit/auth_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil e Configurações'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             const Text('Informações do Usuário Aqui'),
             const SizedBox(height: 20),
             ElevatedButton.icon( // Usa ElevatedButton.icon para um visual melhor
                icon: const Icon(Icons.logout),
                label: const Text('Sair da Conta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error, // Cor vermelha para ação destrutiva
                  foregroundColor: Theme.of(context).colorScheme.onError, // Texto branco
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                   shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                   ),
                ),
                onPressed: () {
                  // --- AÇÃO DE LOGOUT ---
                  // Chama a função de logout do AuthCubit que está provido globalmente
                  context.read<AuthCubit>().logout();
                  // ---------------------

                  // A lógica no main.dart (ou SplashScreen) que ouve o AuthCubit
                  // detectará a mudança para o estado 'Unauthenticated' e
                  // automaticamente navegará para a tela de login ('/login').
                  // Não precisamos chamar Navigator aqui.
                },
              ),
          ],
        ),
      ),
    );
  }
}