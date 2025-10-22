import 'package:equatable/equatable.dart';

/// Modelo de dados resumido para exibir uma planta na lista do jardim.
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

  // Método factory para criar uma instância a partir de um Map (JSON da API)
  factory PlantSummary.fromJson(Map<String, dynamic> json) {
    // Validações básicas (em um app real, poderiam ser mais robustas)
    if (json['id'] == null || json['scientific_name'] == null || json['tracked_watering'] == null) {
      throw FormatException("JSON inválido para PlantSummary: campos obrigatórios faltando.");
    }
    return PlantSummary(
      id: json['id'] as String,
      nickname: json['nickname'] as String?, // Permite null
      scientificName: json['scientific_name'] as String,
      isTrackedForWatering: json['tracked_watering'] as bool,
      // last_watered não é necessário para a lista inicial, mas poderia ser adicionado
    );
  }

  // Sobrescreve props para comparação com Equatable (útil em listas e testes)
  @override
  List<Object?> get props => [id, nickname, scientificName, isTrackedForWatering];

  // (Opcional) Método toJson se precisar enviar este objeto de volta para a API
  // Map<String, dynamic> toJson() => { ... };
}