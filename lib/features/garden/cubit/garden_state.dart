// lib/features/garden/cubit/garden_state.dart
import 'package:equatable/equatable.dart';
// Importe seu modelo de resumo da planta
import '../models/plant_summary.dart';

abstract class GardenState extends Equatable {
  const GardenState();

  @override
  List<Object> get props => [];
}

// Estado inicial, antes de qualquer carregamento
class GardenInitial extends GardenState {}

// Estado enquanto as plantas estão sendo carregadas da API
class GardenLoading extends GardenState {}

// Estado quando o carregamento foi concluído, mas o jardim está vazio
class GardenEmpty extends GardenState {}

// Estado quando o carregamento foi concluído e há plantas para exibir
class GardenLoaded extends GardenState {
  // A lista COMPLETA de plantas recebida da API (para filtrar)
  final List<PlantSummary> allPlants;
  // A lista FILTRADA de plantas a ser exibida na UI
  final List<PlantSummary> filteredPlants;
  // O termo de busca atual (para manter o estado da busca)
  final String searchTerm;

  const GardenLoaded({
    required this.allPlants,
    required this.filteredPlants,
    this.searchTerm = '', // Começa sem filtro
  });

  // Sobrescreve props para que o Equatable compare os estados corretamente
  @override
  List<Object> get props => [allPlants, filteredPlants, searchTerm];

  // (Opcional) Método auxiliar para criar uma cópia do estado com modificações
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