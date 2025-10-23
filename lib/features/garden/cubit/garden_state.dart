import 'package:equatable/equatable.dart';

// -- Models --
import 'package:plante/features/garden/models/plant_summary.dart';

abstract class GardenState extends Equatable {
  const GardenState();

  @override
  List<Object> get props => [];
}

class GardenInitial extends GardenState {}
class GardenLoading extends GardenState {}
class GardenEmpty extends GardenState {}

class GardenLoaded extends GardenState {
  final List<PlantSummary> allPlants;
  final List<PlantSummary> filteredPlants;
  final String searchTerm;

  const GardenLoaded({
    required this.allPlants,
    required this.filteredPlants,
    this.searchTerm = '',
  });

  @override
  List<Object> get props => [allPlants, filteredPlants, searchTerm];

  GardenLoaded copyWith({
    List<PlantSummary>? allPlants,
    List<PlantSummary>? filteredPlants,
    String? searchTerm,
  }) {
    return GardenLoaded(
      allPlants: allPlants ?? this.allPlants,
      filteredPlants: filteredPlants ?? this.filteredPlants,
      searchTerm: searchTerm ?? this.searchTerm,
    );
  }
}

// Estado quando ocorreu um erro ao carregar as plantas
class GardenError extends GardenState {
  final String message;

  const GardenError(this.message);

  @override
  List<Object> get props => [message];
}