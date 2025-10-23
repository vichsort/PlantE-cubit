import 'package:flutter/material.dart';
import 'package:plante/widgets/custom_text_form_field.dart';

class ConfirmPasswordFormField extends StatefulWidget {
  final TextEditingController controller;

  final TextEditingController passwordController;
  final String labelText;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final void Function(String)? onFieldSubmitted;

  const ConfirmPasswordFormField({
    super.key,
    required this.controller,
    required this.passwordController,
    this.labelText = 'Confirmar Senha',
    this.validator,
    this.textInputAction = TextInputAction.done,
    this.onFieldSubmitted,
  });

  @override
  State<ConfirmPasswordFormField> createState() => _ConfirmPasswordFormFieldState();
}

class _ConfirmPasswordFormFieldState extends State<ConfirmPasswordFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CustomTextFormField(
      controller: widget.controller,
      labelText: widget.labelText,
      prefixIcon: Icons.lock_reset_outlined,
      obscureText: _obscureText,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,

      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, confirme sua senha.';
        }

        if (value != widget.passwordController.text) {
          return 'As senhas não coincidem.';
        }

        if (widget.validator != null) {
          return widget.validator!(value);
        }

        return null;
      },

      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: colorScheme.onSurfaceVariant,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
    );
  }
}