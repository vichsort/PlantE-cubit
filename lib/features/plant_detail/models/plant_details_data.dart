import 'package:equatable/equatable.dart';

class TaxonomyData extends Equatable {
  final String? classe;
  final String? genus;
  final String? ordem;
  final String? familia;
  final String? filo;

  const TaxonomyData({
    this.classe,
    this.genus,
    this.ordem,
    this.familia,
    this.filo,
  });

  factory TaxonomyData.fromJson(Map<String, dynamic> json) {
    return TaxonomyData(
      classe: json['classe'] as String?,
      genus: json['genus'] as String?,
      ordem: json['ordem'] as String?,
      familia: json['familia'] as String?,
      filo: json['filo'] as String?,
    );
  }

  @override
  List<Object?> get props => [classe, genus, ordem, familia, filo];
}

class PlantDetailsData extends Equatable {
  final List<String> popularName;
  final String description;
  final TaxonomyData taxonomy;
  final bool isEdible;
  final String water;
  final String season;
  final String sunlight;
  final String soil;
  final int wateringFrequencyDays;

  const PlantDetailsData({
    required this.popularName,
    required this.description,
    required this.taxonomy,
    required this.isEdible,
    required this.water,
    required this.season,
    required this.sunlight,
    required this.soil,
    required this.wateringFrequencyDays,
  });

  factory PlantDetailsData.fromJson(Map<String, dynamic> json) {
    return PlantDetailsData(
      popularName: List<String>.from(json['popular_name'] as List),
      description: json['description'] as String,
      taxonomy: TaxonomyData.fromJson(json['taxonomy'] as Map<String, dynamic>),
      isEdible: json['is_edible'] as bool,
      water: json['water'] as String,
      season: json['season'] as String,
      sunlight: json['sunlight'] as String,
      soil: json['soil'] as String,
      wateringFrequencyDays: json['watering_frequency_days'] as int? ?? 7,
    );
  }

  @override
  List<Object?> get props => [
    popularName,
    description,
    taxonomy,
    isEdible,
    water,
    season,
    sunlight,
    soil,
    wateringFrequencyDays,
  ];
}
