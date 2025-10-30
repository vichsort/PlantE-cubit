import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // Para formatar datas

// Importa o Cubit e o Estado que controlam esta tela
import '../cubit/plant_detail_cubit.dart';
import '../cubit/plant_detail_state.dart';

// Importa os modelos de dados que o Estado 'Loaded' nos dará
import '../models/plant_complete_data.dart';
import '../models/plant_details_data.dart';
import '../models/plant_nutritional_data.dart';
import '../models/plant_health_data.dart';

class PlantDetailScreen extends StatelessWidget {
  const PlantDetailScreen({super.key});

  // Nota: Não precisamos mais do 'plantId' aqui, pois o Cubit
  // foi provido pelo AppRouter e já sabe qual ID buscar.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usamos um BlocConsumer para lidar com 'build' (UI principal)
      // e 'listen' (SnackBars) ao mesmo tempo.
      body: BlocConsumer<PlantDetailCubit, PlantDetailState>(
        // --- LISTENER (Para Ações) ---
        // Ouve mudanças de estado para mostrar SnackBars de feedback
        // (não reconstrói a UI, apenas executa ações)
        listener: (context, state) {
          if (state is PlantDetailLoaded) {
            // Se uma mensagem de informação (ex: "Análise solicitada") aparecer
            if (state.infoMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.infoMessage!),
                  backgroundColor: Colors.green, // Feedback positivo
                ),
              );
              // Limpa a mensagem no Cubit para não mostrar de novo
              context.read<PlantDetailCubit>().clearMessages();
            }
            // Se uma mensagem de erro (ex: "Limite atingido") aparecer
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
              context.read<PlantDetailCubit>().clearMessages();
            }
          }
        },

        // --- BUILDER (Para a UI Principal) ---
        // Decide o que mostrar na tela com base no estado atual
        builder: (context, state) {
          // --- Estado de Carregamento Inicial ---
          if (state is PlantDetailInitial || state is PlantDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- Estado de Erro Inicial ---
          if (state is PlantDetailError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 24),
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
          // Se não for nenhum dos acima, deve ser PlantDetailLoaded
          if (state is PlantDetailLoaded) {
            final plant = state.plant;
            // Usamos um Stack para ter conteúdo rolável e botões fixos
            return Stack(
              children: [
                // 1. O Conteúdo Rolável
                _buildScrollableContent(context, plant),

                // 2. Os Botões Fixos no Rodapé
                _buildFixedBottomButtons(context, state),
              ],
            );
          }

          // Fallback (não deve ser alcançado)
          return const Center(child: Text('Estado desconhecido.'));
        },
      ),
    );
  }

  // --- Widgets Auxiliares ---

  /// Constrói o conteúdo principal da tela que pode ser rolado
  Widget _buildScrollableContent(
    BuildContext context,
    PlantCompleteData plant,
  ) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // CustomScrollView permite a AppBar "encolher" com a imagem
    return CustomScrollView(
      slivers: [
        // AppBar com a Imagem
        SliverAppBar(
          expandedHeight: 300.0, // Altura da imagem de fundo
          floating: false, // Não flutua
          pinned: true, // A AppBar fica fixa no topo ao rolar
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              plant.displayName, // Usa o helper (nickname ou nome científico)
              style: const TextStyle(
                shadows: [Shadow(blurRadius: 10, color: Colors.black87)],
              ),
            ),
            background:
                (plant.primaryImageUrl != null &&
                    plant.primaryImageUrl!.isNotEmpty)
                ? Image.network(
                    plant.primaryImageUrl!,
                    fit: BoxFit.cover,
                    // Feedback de loading para a imagem da appbar
                    loadingBuilder: (context, child, progress) =>
                        progress == null
                        ? child
                        : Container(color: Colors.grey[800]),
                    errorBuilder: (context, error, stack) =>
                        _buildImagePlaceholder(), // Placeholder em caso de erro
                  )
                : _buildImagePlaceholder(), // Placeholder se não houver imagem
          ),
        ),

        // O resto das informações como uma lista
        SliverToBoxAdapter(
          child: Padding(
            // Padding na base para não ficar atrás dos botões fixos
            padding: const EdgeInsets.all(16.0).copyWith(bottom: 120.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Card: Informações do Jardim ---
                _buildInfoCard(
                  context: context,
                  title: 'Minhas Informações',
                  children: [
                    _infoRow(
                      context,
                      icon: Icons.label_outline,
                      title: 'Apelido',
                      value: plant.nickname ?? '(Nenhum)',
                    ),
                    _infoRow(
                      context,
                      icon: Icons.science_outlined,
                      title: 'Nome Científico',
                      value: plant.scientificName,
                    ),
                    _infoRow(
                      context,
                      icon: Icons.calendar_today_outlined,
                      title: 'Adicionada em',
                      value: DateFormat('dd/MM/yyyy').format(plant.addedAt),
                    ),
                    _infoRow(
                      context,
                      icon: Icons.water_drop_outlined,
                      title: 'Última Rega',
                      value: plant.lastWatered != null
                          ? DateFormat(
                              'dd/MM/yyyy \'às\' HH:mm',
                            ).format(plant.lastWatered!)
                          : 'Nenhuma',
                    ),
                    _infoRow(
                      context,
                      icon: Icons.notifications_active_outlined,
                      title: 'Lembretes de Rega',
                      value: plant.trackedWatering ? 'Ativados' : 'Desativados',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // --- Card: Notas de Cuidado ---
                _buildInfoCard(
                  context: context,
                  title: 'Minhas Notas de Cuidado',
                  children: [
                    Text(
                      plant.careNotes != null && plant.careNotes!.isNotEmpty
                          ? plant.careNotes!
                          : 'Nenhuma nota de cuidado adicionada.',
                      style: textTheme.bodyMedium?.copyWith(height: 1.5),
                    ),
                  ],
                ),

                // --- Seção de Análise de Detalhes (do Gemini) ---
                if (plant.hasDetails) ...[
                  // Se 'details' não for nulo
                  const SizedBox(height: 16),
                  _buildGeminiDetailsCard(context, plant.details!),
                ],

                // --- Seção de Análise Nutricional (do Gemini) ---
                if (plant.hasNutritional) ...[
                  // Se 'nutritional' não for nulo
                  const SizedBox(height: 16),
                  _buildGeminiNutritionalCard(context, plant.nutritional!),
                ],

                // --- Seção de Análise de Saúde (do Gemini) ---
                if (plant.hasHealthInfo) ...[
                  // Se 'health' não for nulo
                  const SizedBox(height: 16),
                  _buildGeminiHealthCard(context, plant.health!),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Constrói os botões fixos no rodapé da tela
  Widget _buildFixedBottomButtons(
    BuildContext context,
    PlantDetailLoaded state,
  ) {
    final cubit = context.read<PlantDetailCubit>();
    final plant = state.plant;
    final theme = Theme.of(context);

    // O 'Positioned' ancora o contêiner no rodapé do Stack
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        // Padding para espaçamento e para salvar da 'safe area' (ex: barra de gestos do iOS)
        padding: const EdgeInsets.fromLTRB(
          16.0,
          12.0,
          16.0,
          24.0,
        ), // Padding inferior maior
        decoration: BoxDecoration(
          // Cor de fundo baseada no tema
          color: theme.colorScheme.surface,
          // Sombra sutil para destacar
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
          // Bordas arredondadas apenas no topo
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        child: Row(
          children: [
            // --- Botão 1: Inspecionar Saúde ---
            Expanded(
              child: ElevatedButton.icon(
                icon: state.isAnalyzingHealth
                    // Mostra loading no botão
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.medical_services_outlined),
                label: const Text('Saúde'),
                // Desabilita se os dados já existem OU se está carregando
                onPressed: (state.isAnalyzingHealth || plant.hasHealthInfo)
                    ? null
                    : () => cubit.triggerHealthAnalysis(),
              ),
            ),
            const SizedBox(width: 12),
            // --- Botão 2: Mais Detalhes ---
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
                // Desabilita se os dados já existem OU se está carregando
                onPressed: (state.isAnalyzingDetails || plant.hasDetails)
                    ? null
                    : () => cubit.triggerDeepAnalysis(),
                style: ElevatedButton.styleFrom(
                  // Estilo de destaque (opcional)
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Placeholder padrão para a imagem
  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Icon(Icons.eco, size: 100, color: Colors.white24),
      ),
    );
  }

  // --- Widgets Auxiliares de Exibição de Dados ---
  // (Coloque-os no final do arquivo ou separe em 'widgets/')

  /// Um card genérico para seções de informação
  Widget _buildInfoCard({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      // Cor sutil do Material 3 para contêineres
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
            const Divider(height: 24, thickness: 0.5),
            ...children,
          ],
        ),
      ),
    );
  }

  /// Uma linha genérica para pares de ícone-título-valor
  Widget _infoRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text('$title: ', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(width: 8),
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

  /// Card para iterar sobre os Detalhes do Gemini
  Widget _buildGeminiDetailsCard(
    BuildContext context,
    PlantDetailsData details,
  ) {
    return _buildInfoCard(
      context: context,
      title: "Detalhes (Análise Profunda)",
      children: [
        _infoRow(
          context,
          icon: Icons.eco_outlined,
          title: 'Nomes Populares',
          value: details.popularName.join(', '),
        ),
        _infoRow(
          context,
          icon: Icons.info_outline,
          title: 'Descrição',
          value: details.description,
        ),
        _infoRow(
          context,
          icon: Icons.water_drop_outlined,
          title: 'Rega',
          value: details.water,
        ),
        _infoRow(
          context,
          icon: Icons.sunny,
          title: 'Luz Solar',
          value: details.sunlight,
        ),
        _infoRow(
          context,
          icon: Icons.grass,
          title: 'Solo',
          value: details.soil,
        ),
        _infoRow(
          context,
          icon: Icons.calendar_month_outlined,
          title: 'Estação',
          value: details.season,
        ),
        _infoRow(
          context,
          icon: Icons.family_restroom_outlined,
          title: 'Família',
          value: details.taxonomy.familia ?? 'N/A',
        ),
        _infoRow(
          context,
          icon: Icons.fastfood_outlined,
          title: 'Comestível',
          value: details.isEdible ? 'Sim' : 'Não',
        ),
      ],
    );
  }

  /// Card para iterar sobre os Dados Nutricionais do Gemini
  Widget _buildGeminiNutritionalCard(
    BuildContext context,
    PlantNutritionalData nutritional,
  ) {
    return _buildInfoCard(
      context: context,
      title: "Nutricional (Análise Profunda)",
      children: [
        _infoRow(
          context,
          icon: Icons.local_cafe_outlined,
          title: 'Chá',
          value: nutritional.tea.join('\n'),
        ),
        _infoRow(
          context,
          icon: Icons.restaurant_menu_outlined,
          title: 'Receita (${nutritional.food.name})',
          value: nutritional.food.ingredients.join(', '),
        ),
        _infoRow(
          context,
          icon: Icons.healing_outlined,
          title: 'Uso Medicinal',
          value:
              "${nutritional.heal.howToUse}. Benefícios: ${nutritional.heal.benefits.join(', ')}",
        ),
        _infoRow(
          context,
          icon: Icons.spa_outlined,
          title: 'Tempero',
          value: nutritional.seasoning,
        ),
      ],
    );
  }

  /// Card para iterar sobre os Dados de Saúde do Gemini
  Widget _buildGeminiHealthCard(BuildContext context, PlantHealthData health) {
    return _buildInfoCard(
      context: context,
      title: "Plano de Saúde (Análise)",
      children: [
        _infoRow(
          context,
          icon: Icons.coronavirus_outlined,
          title: 'Doença',
          value: health.diseaseName,
        ),
        _infoRow(
          context,
          icon: Icons.warning_amber_rounded,
          title: 'Sintomas',
          value: health.symptoms.join(', '),
        ),
        _infoRow(
          context,
          icon: Icons.medical_services_outlined,
          title: 'Plano de Tratamento',
          value: health.treatmentPlan.join('\n'),
        ),
        _infoRow(
          context,
          icon: Icons.timer_outlined,
          title: 'Recuperação',
          value: health.recoveryTime,
        ),
      ],
    );
  }
}
