import 'package:flutter/material.dart';

class GardenScreen extends StatelessWidget {
  const GardenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Jardim'),
        // TODO: Adicionar botão de Perfil/Configurações aqui se a aba Perfil for removida
      ),
      body: const Center(
        child: Text('Conteúdo da Tela Meu Jardim'),
      ),
      // TODO: Adicionar FloatingActionButton para identificar
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Chamar cubit de identificação
        },
        child: const Icon(Icons.add_a_photo_outlined), // Ícone de câmera+
      ),
    );
  }
}