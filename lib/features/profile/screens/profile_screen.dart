import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// -- Features --
import 'package:plante/features/profile/cubit/profile_cubit.dart';
import 'package:plante/features/profile/cubit/profile_state.dart';
import 'package:plante/features/auth/cubit/auth_cubit.dart';
import 'package:plante/features/auth/cubit/auth_state.dart';
import 'package:plante/features/profile/models/user_profile_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controladores para os campos de edição
  final _bioController = TextEditingController();
  final _countryController = TextEditingController();
  final _stateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // Tenta carregar os dados iniciais do AuthCubit
    _updateControllersFromAuth(context.read<AuthCubit>().state);
  }

  // Atualiza os controladores de texto com os dados do perfil
  void _updateControllersFromProfile(UserProfile profile) {
    _bioController.text = profile.bio ?? '';
    _countryController.text = profile.country ?? '';
    _stateController.text = profile.state ?? '';
  }

  // Ouve o AuthCubit para preencher os campos na primeira vez
  void _updateControllersFromAuth(AuthState authState) {
    if (authState is Authenticated) {
      _updateControllersFromProfile(authState.user);
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  // Função chamada pelo botão "Salvar Alterações"
  void _saveProfileChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      final updates = {
        'bio': _bioController.text,
        'country': _countryController.text,
        'state': _stateController.text,
      };
      context.read<ProfileCubit>().updateProfile(updates);
    }
  }

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
        // BlocListener para *dados* do AuthCubit
        // Se os dados mudarem (ex: após o ProfileCubit forçar um reload),
        // atualizamos os controladores de texto.
        child: BlocListener<AuthCubit, AuthState>(
          listener: (context, authState) {
            _updateControllersFromAuth(authState);
          },
          // BlocBuilder principal para os dados do AuthCubit
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              if (authState is! Authenticated) {
                return const Center(child: CircularProgressIndicator());
              }

              final UserProfile profile = authState.user;

              final bool isActionLoading =
                  context.watch<ProfileCubit>().state is ProfileUpdating;

              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          backgroundImage:
                              (profile.profilePictureUrl != null &&
                                  profile.profilePictureUrl!.isNotEmpty)
                              ? NetworkImage(profile.profilePictureUrl!)
                              : null,
                          child:
                              (profile.profilePictureUrl == null ||
                                  profile.profilePictureUrl!.isEmpty)
                              ? Icon(
                                  Icons.person_outline,
                                  size: 50,
                                  color: colorScheme.onSurfaceVariant,
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),

                        Text(
                          profile.email,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),

                        Text(
                          'Status: ${profile.subscriptionStatus == 'premium' ? 'Premium' : 'Gratuito'}', // <<< DADO REAL
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: profile.subscriptionStatus == 'premium'
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                            fontWeight: profile.subscriptionStatus == 'premium'
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Streak de Rega: ${profile.wateringStreak} dias',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.secondary,
                          ),
                        ),

                        const Divider(height: 40),

                        TextFormField(
                          controller: _bioController,
                          decoration: const InputDecoration(
                            labelText: 'Minha Bio',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _countryController,
                          decoration: const InputDecoration(
                            labelText: 'País',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _stateController,
                          decoration: const InputDecoration(
                            labelText: 'Estado',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('Salvar Alterações'),
                          onPressed: isActionLoading
                              ? null
                              : _saveProfileChanges,
                        ),

                        const Divider(height: 40),

                        ElevatedButton.icon(
                          icon: const Icon(Icons.star_rounded),
                          label: const Text('Tornar Premium (TESTE)'),
                          onPressed:
                              (isActionLoading ||
                                  profile.subscriptionStatus == 'premium')
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
                          onPressed:
                              (isActionLoading ||
                                  profile.subscriptionStatus == 'free')
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

                        if (isActionLoading)
                          const Padding(
                            padding: EdgeInsets.only(top: 16.0),
                            child: Center(child: CircularProgressIndicator()),
                          ),

                        const Divider(height: 60),

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
                          onPressed: isActionLoading
                              ? null
                              : () {
                                  showDialog(
                                    context: context,
                                    builder: (dialogContext) => AlertDialog(
                                      title: const Text('Sair da Conta'),
                                      content: const Text(
                                        'Tem certeza que deseja sair?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(dialogContext).pop(),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(dialogContext).pop();
                                            context.read<AuthCubit>().logout();
                                          },
                                          child: Text(
                                            'Sair',
                                            style: TextStyle(
                                              color: colorScheme.error,
                                            ),
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
              );
            },
          ),
        ),
      ),
    );
  }
}
