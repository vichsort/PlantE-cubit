import 'package:equatable/equatable.dart';
import 'package:plante/features/plant_detail/models/plant_full_data.dart';

abstract class PlantDetailState extends Equatable {
  const PlantDetailState();
  @override
  List<Object?> get props => [];
}

class PlantDetailInitial extends PlantDetailState {}

class PlantDetailLoading extends PlantDetailState {}

class PlantDetailLoaded extends PlantDetailState {
  final PlantFullData plant;
  final bool isAnalyzingHealth;
  final bool isAnalyzingDetails;

  const PlantDetailLoaded(
    this.plant, {
    this.isAnalyzingHealth = false,
    this.isAnalyzingDetails = false,
  });

  @override
  List<Object?> get props => [plant, isAnalyzingHealth, isAnalyzingDetails];

  PlantDetailLoaded copyWith({
    PlantFullData? plant,
    bool? isAnalyzingHealth,
    bool? isAnalyzingDetails,
  }) {
    return PlantDetailLoaded(
      plant ?? this.plant,
      isAnalyzingHealth: isAnalyzingHealth ?? this.isAnalyzingHealth,
      isAnalyzingDetails: isAnalyzingDetails ?? this.isAnalyzingDetails,
    );
  }
}

// Estado de erro (mostra uma mensagem de erro)
class PlantDetailError extends PlantDetailState {
  final String message;
  const PlantDetailError(this.message);
  @override
  List<Object> get props => [message];
}
