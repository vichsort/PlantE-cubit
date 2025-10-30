import 'package:equatable/equatable.dart';

// -- Models --
import '../models/plant_complete_data.dart';

abstract class PlantDetailState extends Equatable {
  const PlantDetailState();
  @override
  List<Object?> get props => [];
}

class PlantDetailInitial extends PlantDetailState {}

class PlantDetailLoading extends PlantDetailState {}

class PlantDetailLoaded extends PlantDetailState {
  final PlantCompleteData plant;

  final bool isAnalyzingDetails;
  final bool isAnalyzingHealth;
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

  // Helper de cópia pra ajudar na atualização parcial do estado
  PlantDetailLoaded copyWith({
    PlantCompleteData? plant,
    bool? isAnalyzingDetails,
    bool? isAnalyzingHealth,
    String? infoMessage,
    String? errorMessage,
    bool clearInfoMessage = false,
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

class PlantDetailError extends PlantDetailState {
  final String message;
  const PlantDetailError(this.message);
  @override
  List<Object> get props => [message];
}
