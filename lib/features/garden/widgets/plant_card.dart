import 'package:flutter/material.dart';
import 'package:plante/features/garden/models/plant_summary.dart';

class PlantCard extends StatelessWidget {
  final PlantSummary plant;
  final Color cardColor;
  final VoidCallback onMoreOptionsTap;
  final VoidCallback onTap;

  const PlantCard({
    super.key,
    required this.plant,
    required this.onTap,
    required this.onMoreOptionsTap,
    this.cardColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    const double sidePadding = 12.0;
    const double topPadding = 12.0;
    const double bottomPadding = 16.0;

    return Card(
      elevation: 3.0,
      color: cardColor,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Área da Imagem (com bordas internas) ---
            Padding(
              padding: const EdgeInsets.fromLTRB(sidePadding, topPadding, sidePadding, 0),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  // --- Placeholder da Imagem ---
                  // TODO: Substituir por Image.network(plant.imageUrl) quando disponível
                  color: Colors.grey[800],
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.grey[600],
                    size: 40,
                  ),
                  // -----------------------------
                ),
              ),
            ),

            // --- Área de Texto e Botão (na base) ---
            Padding(
              padding: const EdgeInsets.fromLTRB(sidePadding, 8.0, sidePadding / 2, bottomPadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4), // Pequeno espaço acima do nickname
                        // Nickname (ou Nome Científico se nickname for nulo)
                        Text(
                          plant.nickname ?? plant.scientificName,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        // Nome Científico (menor e cinza)
                        Text(
                          plant.scientificName,
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                           maxLines: 1,
                           overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Botão "Mais Opções"
                  SizedBox(
                    width: 40,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      icon: Icon(Icons.more_vert, color: Colors.grey[700]),
                      onPressed: onMoreOptionsTap,
                      tooltip: 'Mais opções',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}