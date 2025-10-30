import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plante/features/profile/cubit/profile_cubit.dart';
import 'package:plante/features/profile/cubit/profile_state.dart';
import 'package:plante/features/auth/cubit/auth_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil e Configurações')),
      body: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colorScheme.primary,
              ),
            );
          } else if (state is ProfileUpdateFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colorScheme.error,
              ),
            );
          }
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.person_pin_circle_outlined,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Meu Perfil',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // TODO: Usar BlocBuilder<ProfileCubit, ProfileState> aqui
                // para exibir 'state.profile.email' e 'state.profile.subscriptionStatus'
                const Text(
                  '(Status: Desconhecido - Carregar dados)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // --- Botões de Teste Premium/Free ---
                BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, state) {
                    final isLoading = state is ProfileLoading;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.star_rounded),
                          label: const Text('Tornar Premium (TESTE)'),
                          onPressed: isLoading
                              ? null
                              : () => context
                                    .read<ProfileCubit>()
                                    .upgradeToPremium(),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.star_outline_rounded),
                          label: const Text('Reverter para Free (TESTE)'),
                          onPressed: isLoading
                              ? null
                              : () =>
                                    context.read<ProfileCubit>().revertToFree(),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            backgroundColor:
                                colorScheme.surfaceContainerHighest,
                            foregroundColor: colorScheme.onSurfaceVariant,
                          ),
                        ),

                        if (isLoading) // Mostra um indicador de loading
                          const Padding(
                            padding: EdgeInsets.only(top: 16.0),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                      ],
                    );
                  },
                ),

                const Divider(height: 60),

                // --- Botão Sair ---
                ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Sair da Conta'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.errorContainer,
                    foregroundColor: colorScheme.onErrorContainer,
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Sair da Conta'),
                        content: const Text('Tem certeza que deseja sair?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              context.read<AuthCubit>().logout();
                            },
                            child: Text(
                              'Sair',
                              style: TextStyle(color: colorScheme.error),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
