import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

// -- Core --
import 'package:plante/core/error/api_exception.dart';

// -- Features --
import 'package:plante/features/garden/cubit/garden_state.dart';
import 'package:plante/features/garden/services/garden_service.dart';
import 'package:plante/features/garden/services/identification_service.dart';
import 'package:plante/features/auth/cubit/auth_cubit.dart';
import 'package:plante/features/garden/models/plant_summary.dart';

class GardenCubit extends Cubit<GardenState> {
  final GardenService _gardenService;
  final IdentificationService _identificationService;
  final AuthCubit _authCubit;
  final ImagePicker _imagePicker = ImagePicker();

  List<PlantSummary> _internalAllPlants = [];

  GardenCubit(this._gardenService, this._identificationService, this._authCubit)
    : super(GardenInitial());

  Future<void> loadGarden({bool force = false}) async {
    if (state is GardenLoading && !force) return;

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
      if (e.statusCode == 401) {
        _authCubit.logout();
      } else {
        emit(GardenError(e.message));
      }
    } catch (e) {
      emit(
        GardenError("Erro inesperado ao carregar o jardim: ${e.toString()}"),
      );
    }
  }

  void searchPlants(String searchTerm) {
    if (state is GardenLoaded) {
      final currentState = state as GardenLoaded;
      final normalizedSearch = searchTerm.toLowerCase().trim();

      if (normalizedSearch.isEmpty) {
        emit(
          currentState.copyWith(
            filteredPlants: _internalAllPlants,
            searchTerm: '',
          ),
        );
      } else {
        final filtered = _internalAllPlants.where((plant) {
          final nameMatch = plant.scientificName.toLowerCase().contains(
            normalizedSearch,
          );
          final nicknameMatch =
              plant.nickname?.toLowerCase().contains(normalizedSearch) ?? false;
          return nameMatch || nicknameMatch;
        }).toList();

        emit(
          currentState.copyWith(
            filteredPlants: filtered,
            searchTerm: searchTerm,
          ),
        );
      }
    }
  }

  // Identifica uma nova planta e adiciona ao "Jardim"
  Future<void> identifyNewPlant(ImageSource source) async {
    emit(GardenLoading());
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
      );

      if (pickedFile != null) {
        await _identificationService.identifyPlant(File(pickedFile.path));
        await loadGarden(force: true);
      } else {
        await loadGarden(force: true);
      }
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        _authCubit.logout();
      } else {
        emit(GardenError("Falha ao identificar planta: ${e.message}"));
      }
    } catch (e) {
      emit(
        GardenError("Erro inesperado ao identificar planta: ${e.toString()}"),
      );
    }
  }

  // Retira uma planta da listagem do jardim
  Future<void> deletePlant(String plantId) async {
    emit(GardenLoading());
    try {
      await _gardenService.deletePlant(plantId);
      await loadGarden(force: true);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        _authCubit.logout();
      } else {
        emit(GardenError("Falha ao remover planta: ${e.message}"));
      }
    } catch (e) {
      emit(GardenError("Erro inesperado ao remover planta: ${e.toString()}"));
    }
  }

  // adiciona a planta atual na track de pedidos de rega
  Future<void> trackWatering(String plantId) async {
    if (state is! GardenLoaded) {
      return;
    }

    try {
      await _gardenService.trackWatering(plantId);
      _updatePlantInState(
        plantId,
        (plant) => plant.copyWith(isTrackedForWatering: true),
      );
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        _authCubit.logout();
      } else {
        emit(GardenError("Falha ao ativar lembretes: ${e.message}"));
      }
    } catch (e) {
      emit(GardenError("Erro inesperado: ${e.toString()}"));
    }
  }

  // retira a planta atual da track de pedidos de rega
  Future<void> untrackWatering(String plantId) async {
    if (state is! GardenLoaded) return;
    try {
      await _gardenService.untrackWatering(plantId);
      _updatePlantInState(
        plantId,
        (plant) => plant.copyWith(isTrackedForWatering: false),
      );
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        _authCubit.logout();
      } else {
        emit(GardenError("Falha ao desativar lembretes: ${e.message}"));
      }
    } catch (e) {
      emit(GardenError("Erro inesperado: ${e.toString()}"));
    }
  }

  // muda dados da planta
  void _updatePlantInState(
    String plantId,
    PlantSummary Function(PlantSummary) updateFn,
  ) {
    if (state is! GardenLoaded) return;
    final currentState = state as GardenLoaded;

    _internalAllPlants = _internalAllPlants.map((plant) {
      return plant.id == plantId ? updateFn(plant) : plant;
    }).toList();

    final updatedFilteredPlants = currentState.filteredPlants.map((plant) {
      return plant.id == plantId ? updateFn(plant) : plant;
    }).toList();

    emit(
      currentState.copyWith(
        allPlants: _internalAllPlants,
        filteredPlants: updatedFilteredPlants,
      ),
    );
  }
}
