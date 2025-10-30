import 'package:equatable/equatable.dart';

class PlantFullData extends Equatable {
  final String id;
  final String? nickname;
  final String scientificName;
  final DateTime addedAt;
  final DateTime? lastWatered;
  final String? careNotes;
  final bool trackedWatering;
  final String? primaryImageUrl;
  // Flags para sabermos quais dados do Gemini já foram buscados
  final bool hasDetails;
  final bool hasNutritional;
  final bool hasHealthInfo;
  // TODO: Adicionar campos para os dados do Gemini quando forem buscados
  // final Map<String, dynamic>? detailsCache;
  // final Map<String, dynamic>? nutritionalCache;
  // final Map<String, dynamic>? healthCache;

  const PlantFullData({
    required this.id,
    this.nickname,
    required this.scientificName,
    required this.addedAt,
    this.lastWatered,
    this.careNotes,
    required this.trackedWatering,
    this.primaryImageUrl,
    required this.hasDetails,
    required this.hasNutritional,
    required this.hasHealthInfo,
  });

  // Helper para facilitar a exibição do nome principal
  String get displayName => nickname ?? scientificName;

  factory PlantFullData.fromJson(Map<String, dynamic> json) {
    return PlantFullData(
      id: json['id'] as String,
      nickname: json['nickname'] as String?,
      scientificName: json['scientific_name'] as String,
      addedAt: DateTime.parse(json['added_at'] as String),
      lastWatered: json['last_watered'] != null
          ? DateTime.parse(json['last_watered'] as String)
          : null,
      careNotes: json['care_notes'] as String?,
      trackedWatering: json['tracked_watering'] as bool,
      primaryImageUrl: json['primary_image_url'] as String?,
      hasDetails: json['has_details'] as bool,
      hasNutritional: json['has_nutritional'] as bool,
      hasHealthInfo: json['has_health_info'] as bool,
      // TODO: Parsear os caches do Gemini (details_cache, etc.) se/quando a API os retornar
    );
  }

  @override
  List<Object?> get props => [
    id,
    nickname,
    scientificName,
    addedAt,
    lastWatered,
    careNotes,
    trackedWatering,
    primaryImageUrl,
    hasDetails,
    hasNutritional,
    hasHealthInfo,
  ];
}
