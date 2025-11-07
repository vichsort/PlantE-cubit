import 'dart:io';
import 'package:/flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

// -- Core --
import 'package:plante/core/error/api_exception.dart';
import 'package:plante/core/utils/location_utils.dart';

// -- Features --
import 'package:plante/features/garden/services/garden_service.dart';
import 'package:plante/features/plant_detail/cubit/plant_detail_state.dart';
import 'package:plante/features/garden/services/identification_service.dart';
import 'package:plante/features/auth/cubit/auth_cubit.dart';

class PlantDetailCubit extends Cubit<PlantDetailState> {
  final String userPlantId;
  final GardenService _gardenService;
  final IdentificationService _identificationService;
  final LocationService _locationService;
  final AuthCubit _authCubit;
  final ImagePicker _imagePicker = ImagePicker();

  PlantDetailCubit({
    required this.userPlantId,
    required GardenService gardenService,
    required IdentificationService identificationService,
    required LocationService locationService,
    required AuthCubit authCubit,
  }) : _gardenService = gardenService,
       _identificationService = identificationService,
       _locationService = locationService,
       _authCubit = authCubit,
       super(PlantDetailInitial());

  Future<void> fetchDetails() async {
    if (state is PlantDetailLoading) return;
    if (state is! PlantDetailLoaded) {
      emit(PlantDetailLoading());
    }

    try {
      final plantData = await _gardenService.fetchPlantDetails(userPlantId);
      emit(PlantDetailLoaded(plantData));
    } on ApiException catch (e) {
      if (e.statusCode == 401) _authCubit.logout();
      emit(PlantDetailError(e.message));
    } catch (e) {
      emit(PlantDetailError("Erro inesperado: ${e.toString()}"));
    }
  }

  Future<void> triggerDeepAnalysis() async {
    if (state is! PlantDetailLoaded) return;
    final currentState = state as PlantDetailLoaded;
    if (currentState.isAnalyzingDetails) return;

    emit(
      currentState.copyWith(
        isAnalyzingDetails: true,
        clearInfoMessage: true,
        clearErrorMessage: true,
      ),
    );

    try {
      await _gardenService.triggerDeepAnalysis(userPlantId);

      emit(
        currentState.copyWith(
          isAnalyzingDetails: false,
          infoMessage: "Análise profunda solicitada! Você será notificado.",
        ),
      );
    } on ApiException catch (e) {
      if (e.statusCode == 401) _authCubit.logout();
      emit(
        currentState.copyWith(
          isAnalyzingDetails: false,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          isAnalyzingDetails: false,
          errorMessage: "Erro inesperado: ${e.toString()}",
        ),
      );
    }
  }

  Future<void> triggerHealthAnalysis() async {
    if (state is! PlantDetailLoaded) return;
    final currentState = state as PlantDetailLoaded;
    if (currentState.isAnalyzingHealth) return;

    try {
      final XFile? imageFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
      );
      if (imageFile == null) return;

      emit(
        currentState.copyWith(
          isAnalyzingHealth: true,
          clearInfoMessage: true,
          clearErrorMessage: true,
        ),
      );

      final location = await _locationService.getCurrentLocation();

      await _identificationService.analyzeHealth(
        userPlantId,
        File(imageFile.path),
        location,
      );

      emit(
        currentState.copyWith(
          isAnalyzingHealth: false,
          infoMessage: "Análise de saúde solicitada! Você será notificado.",
        ),
      );
    } on ApiException catch (e) {
      if (e.statusCode == 401) _authCubit.logout();
      emit(
        currentState.copyWith(
          isAnalyzingHealth: false,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          isAnalyzingHealth: false,
          errorMessage: "Erro inesperado: ${e.toString()}",
        ),
      );
    }
  }

  Future<void> updateNickname(String newNickname) async {
    if (state is! PlantDetailLoaded) return;
    final currentState = state as PlantDetailLoaded;

    emit(
      currentState.copyWith(
        plant: currentState.plant.copyWith(nickname: newNickname),
        clearInfoMessage: true,
        clearErrorMessage: true,
      ),
    );
    try {
      await _gardenService.updatePlant(userPlantId, {'nickname': newNickname});
      await fetchDetails();
    } on ApiException catch (e) {
      if (e.statusCode == 401) _authCubit.logout();
      emit(
        currentState.copyWith(
          errorMessage: e.message,
          plant: currentState.plant,
        ),
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          errorMessage: "Erro ao salvar apelido: ${e.toString()}",
          plant: currentState.plant,
        ),
      );
    }
  }

  Future<void> updateCareNotes(String newNotes) async {
    if (state is! PlantDetailLoaded) return;
    final currentState = state as PlantDetailLoaded;

    emit(
      currentState.copyWith(
        plant: currentState.plant.copyWith(careNotes: newNotes),
        clearInfoMessage: true,
        clearErrorMessage: true,
      ),
    );
    try {
      await _gardenService.updatePlant(userPlantId, {'care_notes': newNotes});
      await fetchDetails();
    } on ApiException catch (e) {
      if (e.statusCode == 401) _authCubit.logout();
      emit(
        currentState.copyWith(
          errorMessage: e.message,
          plant: currentState.plant,
        ),
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          errorMessage: "Erro ao salvar notas: ${e.toString()}",
          plant: currentState.plant,
        ),
      );
    }
  }

  Future<void> toggleWateringTracking() async {
    if (state is! PlantDetailLoaded) return;
    final currentState = state as PlantDetailLoaded;
    final bool currentTrackingState = currentState.plant.trackedWatering;

    emit(
      currentState.copyWith(
        plant: currentState.plant.copyWith(
          trackedWatering: !currentTrackingState,
        ),
        clearInfoMessage: true,
        clearErrorMessage: true,
      ),
    );

    try {
      if (currentTrackingState) {
        await _gardenService.untrackWatering(userPlantId);
      } else {
        await _gardenService.trackWatering(userPlantId);
      }
    } on ApiException catch (e) {
      emit(
        currentState.copyWith(
          plant: currentState.plant,
          errorMessage: e.message,
        ),
      );
      if (e.statusCode == 401) _authCubit.logout();
    } catch (e) {
      emit(
        currentState.copyWith(
          plant: currentState.plant,
          errorMessage: "Erro inesperado: ${e.toString()}",
        ),
      );
    }
  }

  Future<void> updateLastWatered(DateTime wateredAt) async {
    if (state is! PlantDetailLoaded) return;
    final currentState = state as PlantDetailLoaded;

    emit(
      currentState.copyWith(
        plant: currentState.plant.copyWith(lastWatered: wateredAt),
        clearInfoMessage: true,
        clearErrorMessage: true,
      ),
    );
    try {
      await _gardenService.updatePlant(userPlantId, {
        'last_watered': wateredAt.toIso8601String(),
      });
    } on ApiException catch (e) {
      if (e.statusCode == 401) _authCubit.logout();
      emit(
        currentState.copyWith(
          errorMessage: e.message,
          plant: currentState.plant,
        ),
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          errorMessage: "Erro ao salvar rega: ${e.toString()}",
          plant: currentState.plant,
        ),
      );
    }
  }

  void clearMessages() {
    if (state is PlantDetailLoaded) {
      final currentState = state as PlantDetailLoaded;
      emit(
        currentState.copyWith(clearInfoMessage: true, clearErrorMessage: true),
      );
    }
  }
}
