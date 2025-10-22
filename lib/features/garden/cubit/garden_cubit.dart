import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/garden_service.dart'; // Importe seu GardenService
import 'garden_state.dart';
import '../../../core/error/api_exception.dart'; // Importe ApiException
import '../models/plant_summary.dart'; // Importe seu modelo

class GardenCubit extends Cubit<GardenState> {
  final GardenService _gardenService;

  // Guarda a lista completa internamente para filtrar rapidamente
  List<PlantSummary> _internalAllPlants = [];

  GardenCubit(this._gardenService) : super(GardenInitial());

  /// Carrega a lista inicial de plantas do jardim.
  Future<void> loadGarden() async {
    // Só carrega se não estiver já carregado ou em erro,
    // ou pode adicionar lógica para recarregar se necessário (pull-to-refresh)
    if (state is GardenLoading) return;

    emit(GardenLoading());
    try {
      final plants = await _gardenService.fetchPlants();
      _internalAllPlants = plants; // Armazena a lista completa

      if (plants.isEmpty) {
        emit(GardenEmpty());
      } else {
        // Inicialmente, a lista filtrada é igual à lista completa
        emit(GardenLoaded(allPlants: plants, filteredPlants: plants));
      }
    } on ApiException catch (e) {
      emit(GardenError(e.message));
    } catch (e) {
      emit(GardenError("Erro inesperado ao carregar o jardim: ${e.toString()}"));
    }
  }

  /// Filtra a lista de plantas exibida com base no termo de busca.
  void searchPlants(String searchTerm) {
    // Só filtra se já tivermos dados carregados
    if (state is GardenLoaded) {
      final currentState = state as GardenLoaded; // Cast seguro
      final normalizedSearch = searchTerm.toLowerCase().trim();

      if (normalizedSearch.isEmpty) {
        // Se a busca está vazia, mostra todas as plantas
        emit(currentState.copyWith(
          filteredPlants: _internalAllPlants, // Usa a lista interna completa
          searchTerm: '',
        ));
      } else {
        // Filtra a lista interna completa
        final filtered = _internalAllPlants.where((plant) {
          final nameMatch = plant.scientificName.toLowerCase().contains(normalizedSearch);
          final nicknameMatch = plant.nickname?.toLowerCase().contains(normalizedSearch) ?? false;
          return nameMatch || nicknameMatch;
        }).toList();

        // Emite um novo estado Loaded com a lista filtrada e o termo de busca
        emit(currentState.copyWith(
          filteredPlants: filtered,
          searchTerm: searchTerm,
          // Mantém 'allPlants' igual, pois a lista original não mudou
        ));
      }
    } else {
      // Opcional: Logar um aviso se tentar buscar sem dados carregados
      print("GardenCubit: Tentativa de busca em estado inválido ($state)");
    }
  }

  // --- Funções Futuras (Exemplos) ---
  // Future<void> deletePlant(String plantId) async { ... }
  // Future<void> identifyNewPlant(File imageFile) async { ... }
}