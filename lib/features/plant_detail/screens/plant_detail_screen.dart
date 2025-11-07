// lib/features/plant_detail/screens/plant_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

// -- Cubits --
import 'package:plante/features/plant_detail/cubit/plant_detail_cubit.dart';
import 'package:plante/features/plant_detail/cubit/plant_detail_state.dart';

// -- Models --
import 'package:plante/features/plant_detail/models/plant_complete_data.dart';
import 'package:plante/features/plant_detail/models/plant_details_data.dart';
import 'package:plante/features/plant_detail/models/plant_nutritional_data.dart';
import 'package:plante/features/plant_detail/models/plant_health_data.dart';

class PlantDetailScreen extends StatefulWidget {
  const PlantDetailScreen({super.key});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<PlantDetailCubit, PlantDetailState>(
        listener: (context, state) {
          if (state is PlantDetailLoaded) {
            if (state.infoMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.infoMessage!),
                  backgroundColor: Colors.green,
                ),
              );
              context.read<PlantDetailCubit>().clearMessages();
            }
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
        builder: (context, state) {
          if (state is PlantDetailInitial || state is PlantDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

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

          if (state is PlantDetailLoaded) {
            final plant = state.plant;
            return _buildScrollableContent(context, plant, state);
          }

          return const Center(child: Text('Estado desconhecido.'));
        },
      ),
    );
  }

  Widget _buildScrollableContent(
    BuildContext context,
    PlantCompleteData plant,
    PlantDetailLoaded state,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300.0,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background:
                (plant.primaryImageUrl != null &&
                    plant.primaryImageUrl!.isNotEmpty)
                ? Image.network(
                    plant.primaryImageUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) =>
                        progress == null
                        ? child
                        : Container(color: Colors.grey[800]),
                    errorBuilder: (context, error, stack) =>
                        _buildImagePlaceholder(),
                  )
                : _buildImagePlaceholder(),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            color: theme.colorScheme.surface,
            padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        plant.nickname ?? plant.scientificName,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      color: colorScheme.primary,
                      onPressed: () => _showEditNicknameDialog(context, plant),
                    ),
                  ],
                ),
                if (plant.nickname != null)
                  Text(
                    plant.scientificName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 24.0,
            ),
            color: theme.colorScheme.surfaceContainerHighest,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _QuickActionButton(
                  icon: Icons.water_drop_outlined,
                  label: "Regar",
                  onTap: () {
                    _showAddLogDialog(
                      context: context,
                      plant: plant,
                      logType: CareLogType.water,
                    );
                  },
                  subtitle: plant.lastWatered != null
                      ? 'Última: ${DateFormat('dd/MM').format(plant.lastWatered!)}'
                      : 'Nenhuma rega',
                ),
                _QuickActionButton(
                  icon: Icons.eco_outlined,
                  label: "Adubar",
                  onTap: () {
                    _showAddLogDialog(
                      context: context,
                      plant: plant,
                      logType: CareLogType.fertilizer,
                    );
                  },
                  subtitle: "Próximo: 15/12", // TODO: Virá dos lembretes
                ),
                _QuickActionButton(
                  icon: plant.trackedWatering
                      ? Icons.notifications_active_outlined
                      : Icons.notifications_off_outlined,
                  label: "Lembretes",
                  onTap: () {
                    context.read<PlantDetailCubit>().toggleWateringTracking();
                  },
                  subtitle: plant.trackedWatering ? 'Ativos' : 'Inativos',
                  highlight: plant.trackedWatering,
                ),
              ],
            ),
          ),
        ),
        SliverPersistentHeader(
          delegate: _SliverTabBarDelegate(
            TabBar(
              controller: _tabController,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              indicatorColor: colorScheme.primary,
              tabs: const [
                Tab(text: 'Guia'),
                Tab(text: 'Saúde'),
                Tab(text: 'Meu Diário'),
              ],
            ),
          ),
          pinned: true,
        ),
        SliverFillRemaining(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildGuideTab(context, plant, state),
              _buildHealthTab(context, plant, state),
              _buildDiaryTab(context, plant),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showEditNicknameDialog(
    BuildContext context,
    PlantCompleteData plant,
  ) async {
    final cubit = context.read<PlantDetailCubit>();
    final TextEditingController nicknameController = TextEditingController(
      text: plant.nickname,
    );

    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Editar Apelido'),
          content: TextField(
            controller: nicknameController,
            decoration: const InputDecoration(
              labelText: 'Apelido da Planta',
              hintText: 'Ex: Minha Tomateira',
            ),
            maxLength: 30,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            FilledButton(
              child: const Text('Salvar'),
              onPressed: () {
                final newNickname = nicknameController.text.trim();
                cubit.updateNickname(newNickname);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditCareNotesDialog(
    BuildContext context,
    PlantCompleteData plant,
  ) async {
    final cubit = context.read<PlantDetailCubit>();
    final TextEditingController notesController = TextEditingController(
      text: plant.careNotes,
    );

    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Editar Notas de Cuidado'),
          content: TextField(
            controller: notesController,
            decoration: const InputDecoration(
              labelText: 'Notas',
              hintText: 'Ex: Adubar a cada 2 meses...',
            ),
            maxLines: 5,
            maxLength: 255,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            FilledButton(
              child: const Text('Salvar'),
              onPressed: () {
                final newNotes = notesController.text.trim();
                cubit.updateCareNotes(newNotes);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddLogDialog({
    required BuildContext context,
    required PlantCompleteData plant,
    required CareLogType logType,
  }) async {
    final cubit = context.read<PlantDetailCubit>();
    final String title = logType == CareLogType.water
        ? 'Registrar Rega'
        : 'Registrar Adubação';
    final String message =
        'Você ${logType == CareLogType.water ? 'regou' : 'adubou'} "${plant.displayName}" agora?';

    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            FilledButton(
              child: const Text('Sim, registrar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();

                if (logType == CareLogType.water) {
                  cubit.updateLastWatered(DateTime.now());
                } else {
                  print("CHAMANDO CUBIT: addFertilizerLog (NÃO IMPLEMENTADO)");
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Log de adubação ainda não implementado.'),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildGuideTab(
    BuildContext context,
    PlantCompleteData plant,
    PlantDetailLoaded state,
  ) {
    if (plant.hasDetails) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildGeminiDetailsCard(context, plant.details!),
            if (plant.hasNutritional) ...[
              const SizedBox(height: 16),
              _buildGeminiNutritionalCard(context, plant.nutritional!),
            ],
          ],
        ),
      );
    }
    return _buildPremiumUnlockCard(
      context: context,
      title: 'Desbloquear Análise Profunda',
      description:
          'Obtenha detalhes sobre rega, luz, solo, usos medicinais, receitas e muito mais, fornecidos pelo Gemini AI.',
      isLoading: state.isAnalyzingDetails,
      onTap: () => context.read<PlantDetailCubit>().triggerDeepAnalysis(),
    );
  }

  Widget _buildHealthTab(
    BuildContext context,
    PlantCompleteData plant,
    PlantDetailLoaded state,
  ) {
    if (plant.hasHealthInfo) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _buildGeminiHealthCard(context, plant.health!),
      );
    }
    return _buildPremiumUnlockCard(
      context: context,
      title: 'Fazer Análise de Saúde',
      description:
          'Tire uma nova foto da sua planta para que nossa IA (Plant.id + Gemini) verifique sinais de doenças e gere um plano de tratamento.',
      isLoading: state.isAnalyzingHealth,
      onTap: () => context.read<PlantDetailCubit>().triggerHealthAnalysis(),
    );
  }

  Widget _buildDiaryTab(BuildContext context, PlantCompleteData plant) {
    final textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildInfoCard(
            context: context,
            title: 'Minhas Informações',
            children: [
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
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            context: context,
            title: 'Minhas Notas de Cuidado',
            trailing: IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => _showEditCareNotesDialog(context, plant),
              tooltip: 'Editar Notas',
            ),
            children: [
              Text(
                plant.careNotes != null && plant.careNotes!.isNotEmpty
                    ? plant.careNotes!
                    : 'Nenhuma nota de cuidado adicionada.',
                style: textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            context: context,
            title: 'Histórico de Ações (Em breve)',
            children: const [
              ListTile(
                title: Text('Regou a planta - 02/11/2025 (Dado Fixo)'),
                leading: Icon(Icons.water_drop),
              ),
              ListTile(
                title: Text('Adubou a planta - 28/10/2025 (Dado Fixo)'),
                leading: Icon(Icons.eco),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumUnlockCard({
    required BuildContext context,
    required String title,
    required String description,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.lock_outline,
                size: 40,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: const Text('Analisar Agora (1 uso)'),
                onPressed: isLoading ? null : onTap,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Icon(Icons.eco, size: 100, color: Colors.white24),
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required String title,
    required List<Widget> children,
    Widget? trailing,
  }) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
            const Divider(height: 24, thickness: 0.5),
            ...children,
          ],
        ),
      ),
    );
  }

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

  Widget _buildGeminiDetailsCard(
    BuildContext context,
    PlantDetailsData details,
  ) {
    return _buildInfoCard(
      context: context,
      title: "Guia da Planta",
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

  Widget _buildGeminiNutritionalCard(
    BuildContext context,
    PlantNutritionalData nutritional,
  ) {
    return _buildInfoCard(
      context: context,
      title: "Usos e Nutrição",
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

  Widget _buildGeminiHealthCard(BuildContext context, PlantHealthData health) {
    return _buildInfoCard(
      context: context,
      title: "Plano de Saúde",
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

enum CareLogType { water, fertilizer }

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final bool highlight;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = highlight ? colorScheme.primary : colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
