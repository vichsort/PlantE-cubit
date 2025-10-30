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

  // Placeholder do erro
  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey[600],
        size: 40,
      ),
    );
  }

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- ÁREA DA IMAGEM  ---
            Padding(
              padding: const EdgeInsets.fromLTRB(
                sidePadding,
                topPadding,
                sidePadding,
                0,
              ),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2.0),
                  child:
                      (plant.primaryImageUrl != null &&
                          plant.primaryImageUrl!.isNotEmpty)
                      ? Image.network(
                          plant.primaryImageUrl!,
                          fit: BoxFit.cover,

                          // --- Feedback de Loading ---
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },

                          // --- Feedback de Erro ---
                          errorBuilder: (context, error, stackTrace) {
                            print("PlantCard Img Error: $error");
                            return _buildPlaceholder();
                          },
                        )
                      : _buildPlaceholder(),
                ),
              ),
            ),

            // --- ÁREA DE TEXTO E BOTÃO  ---
            Padding(
              padding: const EdgeInsets.fromLTRB(
                sidePadding,
                8.0,
                sidePadding / 2,
                bottomPadding,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          plant.nickname ?? plant.scientificName,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
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
