import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

// -- Core --
import 'garden_state.dart';
import 'package:plante/core/error/api_exception.dart';

// -- Services --
import 'package:plante/features/garden/services/garden_service.dart';
import 'package:plante/features/garden/services/identification_service.dart';

// -- Models --
import 'package:plante/features/garden/models/plant_summary.dart';

class GardenCubit extends Cubit<GardenState> {
  final GardenService _gardenService;
  final IdentificationService _identificationService;
  final ImagePicker _imagePicker = ImagePicker();

  // Guarda a lista completa internamente para filtrar rapidamente
  List<PlantSummary> _internalAllPlants = [];

  GardenCubit(this._gardenService, this._identificationService) : super(GardenInitial());

  /// Carrega a lista inicial de plantas do jardim.
  Future<void> loadGarden() async {
    if (state is GardenLoading) return;

    emit(GardenLoading());
    try {
      final plants = await _gardenService.fetchPlants();
      _internalAllPlants = plants;

      if (plants.isEmpty) {
        emit(GardenEmpty());
      } else {
        emit(GardenLoaded(allPlants: plants, filteredPlants: plants));
      }
    } on ApiException catch (e) {
      emit(GardenError(e.message));
    } catch (e) {
      emit(GardenError("Erro inesperado ao carregar o jardim: ${e.toString()}"));
    }
  }

  void searchPlants(String searchTerm) {
    if (state is GardenLoaded) {
      final currentState = state as GardenLoaded;
      final normalizedSearch = searchTerm.toLowerCase().trim();

      if (normalizedSearch.isEmpty) {
        // Se a busca está vazia, mostra todas as plantas
        emit(currentState.copyWith(
          filteredPlants: _internalAllPlants,
          searchTerm: '',
        ));
      } else {
        final filtered = _internalAllPlants.where((plant) {
          final nameMatch = plant.scientificName.toLowerCase().contains(normalizedSearch);
          final nicknameMatch = plant.nickname?.toLowerCase().contains(normalizedSearch) ?? false;
          return nameMatch || nicknameMatch;
        }).toList();

        emit(currentState.copyWith(
          filteredPlants: filtered,
          searchTerm: searchTerm,
        ));
      }
    }
  }

  Future<void> identifyNewPlant(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
      );

      if (pickedFile != null) {
        print("GardenCubit: Image picked, sending to service...");

        await _identificationService.identifyPlant(File(pickedFile.path));

        print("GardenCubit: Identification successful, reloading garden.");

        await loadGarden();

      }
    } on ApiException catch (e) {
       print("GardenCubit: API Error during identification - ${e.message}");
       emit(GardenError("Falha ao identificar planta: ${e.message}"));
    } catch (e) {
      print("GardenCubit: Unexpected error during identification - $e");
      emit(GardenError("Erro inesperado ao identificar planta: ${e.toString()}"));
    }
  }

  Future<void> deletePlant(String plantId) async {
    emit(GardenLoading());

    try {
      await _gardenService.deletePlant(plantId);
      await loadGarden();
    } on ApiException catch (e) {
      emit(GardenError("Falha ao remover planta: ${e.message}"));
    } catch (e) {
       emit(GardenError("Erro inesperado ao remover planta: ${e.toString()}"));
    }
  }
}