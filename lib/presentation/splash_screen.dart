import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/cubit/auth_cubit.dart';
import '../features/auth/cubit/auth_state.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // Navega APÓS o primeiro frame ser construído para evitar erros
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (state is Authenticated) {
            // Se autenticado, substitui a SplashScreen pela MainScreen
            Navigator.of(context).pushReplacementNamed('/main'); // Ou '/garden', qual preferir
          } else if (state is Unauthenticated || state is AuthFailure) {
            // Se não autenticado ou falha, substitui pela LoginScreen
            Navigator.of(context).pushReplacementNamed('/login');
          }
          // Não faz nada se for AuthInitial ou AuthLoading, apenas espera
        });
      },
      // Enquanto espera, mostra uma tela de loading simples
      child: const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Carregando...'),
            ],
          ),
        ),
      ),
    );
  }
}