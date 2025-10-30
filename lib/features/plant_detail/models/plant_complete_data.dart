import 'package:equatable/equatable.dart';

// -- Features --
import 'package:plante/features/plant_detail/models/plant_details_data.dart';
import 'package:plante/features/plant_detail/models/plant_nutritional_data.dart';
import 'package:plante/features/plant_detail/models/plant_health_data.dart';

class PlantCompleteData extends Equatable {
  final String id;
  final String? nickname;
  final DateTime addedAt;
  final DateTime? lastWatered;
  final String? careNotes;
  final bool trackedWatering;
  final String? primaryImageUrl;
  final String scientificName;
  final PlantDetailsData? details;
  final PlantNutritionalData? nutritional;
  final PlantHealthData? health;

  const PlantCompleteData({
    required this.id,
    this.nickname,
    required this.addedAt,
    this.lastWatered,
    this.careNotes,
    required this.trackedWatering,
    this.primaryImageUrl,
    required this.scientificName,
    this.details,
    this.nutritional,
    this.health,
  });

  String get displayName => nickname ?? scientificName;

  bool get hasDetails => details != null;
  bool get hasNutritional => nutritional != null;
  bool get hasHealthInfo => health != null;

  factory PlantCompleteData.fromJson(Map<String, dynamic> json) {
    return PlantCompleteData(
      id: json['id'] as String,
      nickname: json['nickname'] as String?,
      addedAt: DateTime.parse(json['added_at'] as String),
      lastWatered: json['last_watered'] != null
          ? DateTime.parse(json['last_watered'] as String)
          : null,
      careNotes: json['care_notes'] as String?,
      trackedWatering: json['tracked_watering'] as bool,
      primaryImageUrl: json['primary_image_url'] as String?,

      scientificName: json['scientific_name'] as String,

      details: json['guide_details'] != null
          ? PlantDetailsData.fromJson(
              json['guide_details'] as Map<String, dynamic>,
            )
          : null,
      nutritional: json['guide_nutritional'] != null
          ? PlantNutritionalData.fromJson(
              json['guide_nutritional'] as Map<String, dynamic>,
            )
          : null,
      health: json['guide_health'] != null
          ? PlantHealthData.fromJson(
              json['guide_health'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    nickname,
    addedAt,
    lastWatered,
    careNotes,
    trackedWatering,
    primaryImageUrl,
    scientificName,
    details,
    nutritional,
    health,
  ];
}
