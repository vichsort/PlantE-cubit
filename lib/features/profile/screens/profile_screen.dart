import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:plante/features/auth/cubit/auth_cubit.dart';

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
             ElevatedButton(
               onPressed: () {
                 // Chama a função de logout do AuthCubit
                //  context.read<AuthCubit>().logout();
                 // A lógica no main.dart (ou onde o AuthCubit é ouvido)
                 // deve redirecionar para a tela de login.
               },
               child: const Text('Sair'),
             )
          ],
        ),
      ),
    );
  }
}