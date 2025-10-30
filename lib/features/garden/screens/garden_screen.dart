import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// -- Cubits --
import '../cubit/garden_cubit.dart';
import '../cubit/garden_state.dart';

// -- Widgets --
import 'package:plante/features/garden/widgets/plant_card.dart';
import 'package:plante/features/garden/widgets/garden_fab.dart';
import 'package:plante/widgets/custom_search_bar.dart';

// -- Models --
import 'package:plante/features/garden/models/plant_summary.dart';

class GardenScreen extends StatefulWidget {
  const GardenScreen({super.key});

  @override
  State<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends State<GardenScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    final currentState = context.read<GardenCubit>().state;
    // Carrega o jardim se estiver no estado inicial
    if (currentState is GardenInitial) {
      context.read<GardenCubit>().loadGarden();
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Atualiza a UI (para o botão 'limpar' da search bar)
    setState(() {});
    // Chama a função de busca no Cubit
    context.read<GardenCubit>().searchPlants(_searchController.text);
  }

  // Opções dropdown de planta
  void _showPlantOptions(BuildContext context, PlantSummary plant) {
    // Pega o Cubit *antes* de construir o BottomSheet
    final gardenCubit = context.read<GardenCubit>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (sheetContext) {
        return Wrap(
          children: <Widget>[
            // Lembretes
            ListTile(
              leading: Icon(
                plant.isTrackedForWatering
                    ? Icons.notifications_off_outlined
                    : Icons.notifications_active_outlined,
              ),
              title: Text(
                plant.isTrackedForWatering
                    ? 'Desativar Lembretes'
                    : 'Ativar Lembretes',
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                if (plant.isTrackedForWatering) {
                  gardenCubit.untrackWatering(plant.id);
                } else {
                  gardenCubit.trackWatering(plant.id);
                }
              },
            ),

            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Editar Apelido'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                // TODO: Implementar Dialog/Navegação para editar apelido
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Funcionalidade Editar Apelido ainda não implementada.',
                    ),
                  ),
                );
              },
            ),

            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Remover do Jardim',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                // TODO: Mostrar um Dialog de confirmação ("Tem certeza?")
                gardenCubit.deletePlant(plant.id);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Jardim'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Barra de pesquisa
          CustomSearchBar(controller: _searchController, onChanged: (value) {}),

          // Conteudo
          Expanded(
            child: BlocBuilder<GardenCubit, GardenState>(
              builder: (context, state) {
                if (state is GardenLoading || state is GardenInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is GardenError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: colorScheme.error,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Ops! Não foi possível carregar seu jardim.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: const Text('Tentar Novamente'),
                            onPressed: () =>
                                context.read<GardenCubit>().loadGarden(),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is GardenEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.grass,
                            size: 64,
                            color: colorScheme.secondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Seu jardim está um pouco vazio...',
                            style: theme.textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Clique no botão + para identificar sua primeira planta!',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is GardenLoaded) {
                  if (state.filteredPlants.isEmpty &&
                      state.searchTerm.isNotEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          'Nenhuma planta encontrada para "${state.searchTerm}".',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    );
                  }

                  // Mostra a lista/grade
                  return GridView.builder(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      top: 8.0,
                      bottom: 80.0,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio: 0.70,
                        ),
                    itemCount: state.filteredPlants.length,
                    itemBuilder: (context, index) {
                      final plant = state.filteredPlants[index];
                      return PlantCard(
                        plant: plant,
                        onTap: () {
                          Navigator.of(
                            context,
                          ).pushNamed('/plant-detail', arguments: plant.id);
                        },
                        onMoreOptionsTap: () {
                          _showPlantOptions(context, plant);
                        },
                      );
                    },
                  );
                }
                return const Center(child: Text('Estado desconhecido.'));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: const GardenFab(),
    );
  }
}
