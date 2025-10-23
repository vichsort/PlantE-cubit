import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;

  const CustomSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText = 'Buscar em Meu Jardim...',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: colorScheme.onSurfaceVariant.withAlpha(700),
          ),

          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 8.0),
            child: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
          ),
          prefixIconConstraints: const BoxConstraints(
            minHeight: 40,
            minWidth: 40,
          ),

          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: colorScheme.onSurfaceVariant),
                  onPressed: () {
                    controller.clear();
                    // Chama onChanged explicitamente se não usar listener na tela pai
                    // onChanged('');
                  },
                  tooltip: 'Limpar busca',
                )
              : null,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24.0),
            borderSide: BorderSide(
              color: colorScheme.primary.withAlpha(500),
              width: 1.5,
            ),
          ),

          filled: true,
          fillColor: colorScheme.surfaceContainerHighest,

          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
        ),
        style: theme.textTheme.bodyLarge,

        textInputAction: TextInputAction.search,
        onSubmitted: (_) {
          FocusScope.of(context).unfocus();
        },
      ),
    );
  }
}
