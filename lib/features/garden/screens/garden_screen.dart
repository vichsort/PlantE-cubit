import 'package:flutter/material.dart';
import '../widgets/garden_fab.dart';

class GardenScreen extends StatelessWidget {
  const GardenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Jardim'),
      ),
      body:
          const Center(child: Text('Lista de Plantas Aqui')),

      floatingActionButton: const GardenFab(),
    );
  }
}