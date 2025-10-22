import 'package:equatable/equatable.dart';

class PlantFullData extends Equatable {
  final String id;
  final String? nickname;
  final String scientificName;
  final String addedAt;
  final String? lastWatered;
  final String? careNotes;
  final bool trackedWatering;
  final bool hasDetails;
  final bool hasNutritional;

  const PlantFullData({
    required this.id,
    this.nickname,
    required this.scientificName,
    required this.addedAt,
    this.lastWatered,
    this.careNotes,
    required this.trackedWatering,
    required this.hasDetails,
    required this.hasNutritional,
  });

  factory PlantFullData.fromJson(Map<String, dynamic> json) {
    return PlantFullData(
      id: json['id'] as String,
      nickname: json['nickname'] as String?,
      scientificName: json['scientific_name'] as String,
      addedAt: json['added_at'] as String,
      lastWatered: json['last_watered'] as String?,
      careNotes: json['care_notes'] as String?,
      trackedWatering: json['tracked_watering'] as bool,
      hasDetails: json['has_details'] as bool,
      hasNutritional: json['has_nutritional'] as bool,
    );
  }

  @override
  List<Object?> get props => [id, nickname, scientificName, addedAt, lastWatered, careNotes, trackedWatering, hasDetails, hasNutritional];
}