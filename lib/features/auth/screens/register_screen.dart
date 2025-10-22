import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      context.read<AuthCubit>().register(email, password);
    }
  }

  void _navigateToLogin() {
    if (Navigator.of(context).canPop()) {
       Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colorScheme.error,
              ),
            );
          } else if (state is Unauthenticated && ModalRoute.of(context)?.isCurrent == true) {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Conta criada com sucesso! Faça o login.'),
                backgroundColor: colorScheme.primary,
              ),
            );
             _navigateToLogin();
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Icon(
                      Icons.person_add_alt_1_rounded,
                      size: 60,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Crie sua conta Plante',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- Campo de Email ---
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                       decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.alternate_email, color: colorScheme.onSurfaceVariant),
                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                         focusedBorder: OutlineInputBorder(
                           borderRadius: BorderRadius.circular(12.0),
                           borderSide: BorderSide(color: colorScheme.primary, width: 2),
                         ),
                         filled: true,
                         fillColor: colorScheme.surfaceContainerHighest,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Email obrigatório.';
                        if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'Email inválido.';
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),

                    // --- Campo de Senha ---
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                       decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: Icon(Icons.lock_outline, color: colorScheme.onSurfaceVariant),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                        focusedBorder: OutlineInputBorder(
                           borderRadius: BorderRadius.circular(12.0),
                           borderSide: BorderSide(color: colorScheme.primary, width: 2),
                         ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                             color: colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Senha obrigatória.';
                        if (value.length < 6) return 'Senha deve ter no mínimo 6 caracteres.'; // Exemplo
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),

                     // --- Campo Confirmar Senha --- (NOVO)
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                       decoration: InputDecoration(
                        labelText: 'Confirmar Senha',
                        prefixIcon: Icon(Icons.lock_reset_outlined, color: colorScheme.onSurfaceVariant),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                        focusedBorder: OutlineInputBorder(
                           borderRadius: BorderRadius.circular(12.0),
                           borderSide: BorderSide(color: colorScheme.primary, width: 2),
                         ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                             color: colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Confirmação obrigatória.';
                        if (value != _passwordController.text) return 'As senhas não coincidem.';
                        return null;
                      },
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _register(),
                    ),
                    const SizedBox(height: 24),

                    BlocBuilder<AuthCubit, AuthState>(
                      buildWhen: (previous, current) =>
                          current is AuthLoading || previous is AuthLoading,
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;
                        return ElevatedButton(
                          onPressed: isLoading ? null : _register,
                           style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 24, width: 24,
                                  child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                )
                              : const Text(
                                  'CRIAR CONTA',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Já tem uma conta?',
                           style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                        TextButton(
                          onPressed: _navigateToLogin,
                          child: Text(
                            'Faça Login',
                             style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}