import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:plante/features/garden/cubit/garden_cubit.dart';

class GardenFab extends StatelessWidget {
  const GardenFab({super.key});

  void _showImageSourceActionSheet(BuildContext context) {
    final gardenCubit = context.read<GardenCubit>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 16.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Identificar Nova Planta',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Tirar Foto'),
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    gardenCubit.identifyNewPlant(ImageSource.camera);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Escolher da Galeria'),
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    gardenCubit.identifyNewPlant(ImageSource.gallery);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Retorna o FloatingActionButton padrão do Material Design
    return FloatingActionButton(
      onPressed: () => _showImageSourceActionSheet(
        context,
      ), // Chama a função que mostra as opções
      tooltip: 'Identificar Planta', // Texto de ajuda ao pressionar e segurar
      child: const Icon(Icons.add_a_photo_outlined), // Ícone de câmera com '+'
    );
  }
}
