import 'package:flutter/material.dart';
import 'package:plante/widgets/custom_text_form_field.dart';

class EmailFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final void Function(String)? onFieldSubmitted;

  const EmailFormField({
    super.key,
    required this.controller,
    this.labelText = 'Email',
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextFormField(
      controller: controller,
      labelText: labelText,
      prefixIcon: Icons.alternate_email,
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,

      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Por favor, insira seu email.';
        }

        if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
          return 'Por favor, insira um email válido.';
        }

        if (validator != null) {
          return validator!(value);
        }

        return null;
      },
    );
  }
}
