// lib/features/plant_detail/cubit/plant_detail_state.dart
import 'package:equatable/equatable.dart';
import '../models/plant_complete_data.dart'; // O modelo completo que criamos

abstract class PlantDetailState extends Equatable {
  const PlantDetailState();
  @override
  List<Object?> get props => [];
}

/// Estado inicial, tela nunca foi carregada
class PlantDetailInitial extends PlantDetailState {}

/// Estado de carregamento da página inteira
class PlantDetailLoading extends PlantDetailState {}

/// Estado de sucesso, a página está carregada com os dados da planta
class PlantDetailLoaded extends PlantDetailState {
  final PlantCompleteData plant;

  // Flags para os botões de ação (mostram loading neles)
  final bool isAnalyzingDetails;
  final bool isAnalyzingHealth;

  // Mensagens para SnackBars (para feedback de ações)
  final String? infoMessage;
  final String? errorMessage;

  const PlantDetailLoaded(
    this.plant, {
    this.isAnalyzingDetails = false,
    this.isAnalyzingHealth = false,
    this.infoMessage,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
    plant,
    isAnalyzingDetails,
    isAnalyzingHealth,
    infoMessage,
    errorMessage,
  ];

  /// Helper para criar cópias do estado modificando apenas o que é necessário
  PlantDetailLoaded copyWith({
    PlantCompleteData? plant,
    bool? isAnalyzingDetails,
    bool? isAnalyzingHealth,
    String? infoMessage,
    String? errorMessage,
    bool clearInfoMessage = false, // Flags para limpar as mensagens
    bool clearErrorMessage = false,
  }) {
    return PlantDetailLoaded(
      plant ?? this.plant,
      isAnalyzingDetails: isAnalyzingDetails ?? this.isAnalyzingDetails,
      isAnalyzingHealth: isAnalyzingHealth ?? this.isAnalyzingHealth,
      infoMessage: clearInfoMessage ? null : infoMessage ?? this.infoMessage,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

/// Estado de falha no carregamento inicial da página
class PlantDetailError extends PlantDetailState {
  final String message;
  const PlantDetailError(this.message);
  @override
  List<Object> get props => [message];
}
