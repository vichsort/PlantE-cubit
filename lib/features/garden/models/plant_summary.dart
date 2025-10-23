import 'package:equatable/equatable.dart';

// Modelo de dados resumido para exibir uma planta na lista do jardim.
class PlantSummary extends Equatable {
  final String id; // O ID da UserPlant (UUID)
  final String? nickname; // Apelido dado pelo usuário (pode ser null)
  final String scientificName; // Nome científico (vem do PlantGuide)
  final bool isTrackedForWatering; // Flag de monitoramento de rega

  const PlantSummary({
    required this.id,
    this.nickname,
    required this.scientificName,
    required this.isTrackedForWatering,
  });

  factory PlantSummary.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null || json['scientific_name'] == null || json['tracked_watering'] == null) {
      throw FormatException("JSON inválido para PlantSummary: campos obrigatórios faltando.");
    }
    return PlantSummary(
      id: json['id'] as String,
      nickname: json['nickname'] as String?,
      scientificName: json['scientific_name'] as String,
      isTrackedForWatering: json['tracked_watering'] as bool,
    );
  }

  @override
  List<Object?> get props => [id, nickname, scientificName, isTrackedForWatering];
}