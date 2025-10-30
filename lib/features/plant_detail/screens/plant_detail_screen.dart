import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubit/plant_detail_cubit.dart';
import '../cubit/plant_detail_state.dart';
import '../models/plant_full_data.dart';

class PlantDetailScreen extends StatelessWidget {
  // O ID da planta é passado via construtor (pelo AppRouter)
  // O Cubit será provido pelo AppRouter, então não precisamos do ID aqui
  // const PlantDetailScreen({super.key, required this.plantId});
  // final String plantId;

  // Versão simples (sem o Cubit provido pelo Router)
  const PlantDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usamos um BlocBuilder para construir a UI baseada no estado
      body: BlocBuilder<PlantDetailCubit, PlantDetailState>(
        builder: (context, state) {
          // --- Estado de Carregamento ---
          if (state is PlantDetailInitial || state is PlantDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- Estado de Erro ---
          if (state is PlantDetailError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<PlantDetailCubit>().fetchDetails(),
                      child: const Text('Tentar Novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          // --- Estado Carregado (Sucesso) ---
          if (state is PlantDetailLoaded) {
            final plant = state.plant;
            // Usa um Stack para os botões fixos no rodapé
            return Stack(
              children: [
                // Conteúdo principal com rolagem
                _buildContent(context, plant),
                // Botões fixos no rodapé
                _buildFixedBottomButtons(context, state),
              ],
            );
          }

          // Fallback (não deve acontecer)
          return const Center(child: Text('Estado desconhecido.'));
        },
      ),
    );
  }

  // Constrói o conteúdo principal da tela
  Widget _buildContent(BuildContext context, PlantFullData plant) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return CustomScrollView(
      // Permite AppBar "flutuante" e rolagem
      slivers: [
        SliverAppBar(
          expandedHeight: 250.0, // Altura da imagem
          floating: false,
          pinned: true, // AppBar fica visível ao rolar
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              plant.displayName,
              style: const TextStyle(
                shadows: [Shadow(blurRadius: 10, color: Colors.black54)],
              ),
            ),
            background: (plant.primaryImageUrl != null)
                ? Image.network(
                    plant.primaryImageUrl!,
                    fit: BoxFit.cover,
                    // TODO: Adicionar loading/error builder
                  )
                : Container(
                    color: Colors.grey,
                    child: const Icon(
                      Icons.eco,
                      size: 100,
                      color: Colors.white24,
                    ),
                  ),
          ),
        ),
        // Conteúdo de informações abaixo da imagem
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0)
                // Adiciona padding na base para não ficar atrás dos botões
                .copyWith(bottom: 120.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoCard(
                  // Widget auxiliar para mostrar infos
                  title: 'Informações Básicas',
                  children: [
                    _InfoRow(
                      icon: Icons.label_outline,
                      title: 'Apelido',
                      value: plant.nickname ?? '(Nenhum)',
                    ),
                    _InfoRow(
                      icon: Icons.science_outlined,
                      title: 'Nome Científico',
                      value: plant.scientificName,
                    ),
                    _InfoRow(
                      icon: Icons.calendar_today_outlined,
                      title: 'Adicionada em',
                      value: DateFormat('dd/MM/yyyy').format(plant.addedAt),
                    ),
                    _InfoRow(
                      icon: Icons.water_drop_outlined,
                      title: 'Última Rega',
                      value: plant.lastWatered != null
                          ? DateFormat(
                              'dd/MM/yyyy \'às\' HH:mm',
                            ).format(plant.lastWatered!)
                          : 'Nenhuma',
                    ),
                    _InfoRow(
                      icon: Icons.notifications_active_outlined,
                      title: 'Lembretes de Rega',
                      value: plant.trackedWatering ? 'Ativados' : 'Desativados',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _InfoCard(
                  title: 'Notas de Cuidado',
                  children: [
                    Text(
                      plant.careNotes != null && plant.careNotes!.isNotEmpty
                          ? plant.careNotes!
                          : 'Nenhuma nota de cuidado adicionada.',
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _InfoCard(
                  title: 'Análises Premium (Gemini)',
                  children: [
                    _InfoRow(
                      icon: Icons.book_outlined,
                      title: 'Detalhes da Planta',
                      value: plant.hasDetails ? 'Disponível' : 'Não analisado',
                    ),
                    _InfoRow(
                      icon: Icons.local_dining_outlined,
                      title: 'Dados Nutricionais',
                      value: plant.hasNutritional
                          ? 'Disponível'
                          : 'Não analisado',
                    ),
                    _InfoRow(
                      icon: Icons.health_and_safety_outlined,
                      title: 'Plano de Saúde',
                      value: plant.hasHealthInfo
                          ? 'Disponível'
                          : 'Não analisado',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Constrói os botões fixos no rodapé
  Widget _buildFixedBottomButtons(
    BuildContext context,
    PlantDetailLoaded state,
  ) {
    final cubit = context.read<PlantDetailCubit>();
    final plant = state.plant;
    final theme = Theme.of(context);

    return Positioned(
      // Fixa no rodapé
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16.0).copyWith(top: 8.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface, // Cor de fundo (claro ou escuro)
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
        ),
        child: Row(
          children: [
            // Botão 1: Inspecionar Saúde
            Expanded(
              child: ElevatedButton.icon(
                icon: state.isAnalyzingHealth
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.medical_services_outlined),
                label: const Text('Saúde'),
                // Desabilita se já tem ou se está analisando
                onPressed: state.isAnalyzingHealth || plant.hasHealthInfo
                    ? null
                    : () => cubit.triggerHealthAnalysis(),
              ),
            ),
            const SizedBox(width: 12),
            // Botão 2: Mais Detalhes
            Expanded(
              child: ElevatedButton.icon(
                icon: state.isAnalyzingDetails
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_stories_outlined),
                label: const Text('Detalhes'),
                // Desabilita se já tem ou se está analisando
                onPressed: state.isAnalyzingDetails || plant.hasDetails
                    ? null
                    : () => cubit.triggerDeepAnalysis(),
                style: ElevatedButton.styleFrom(
                  // Diferencia o botão principal (opcional)
                  // backgroundColor: theme.colorScheme.primary,
                  // foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Widgets Auxiliares para a UI ---

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20, thickness: 0.5),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text('$title: ', style: Theme.of(context).textTheme.labelLarge),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
