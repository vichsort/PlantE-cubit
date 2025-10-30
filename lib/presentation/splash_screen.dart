import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plante/features/auth/cubit/auth_cubit.dart';
import 'package:plante/features/auth/cubit/auth_state.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (state is Authenticated) {
            Navigator.of(context).pushReplacementNamed('/main');
          } else if (state is Unauthenticated || state is AuthFailure) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        });
      },
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
