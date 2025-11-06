import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// -- Core --
import 'package:plante/core/error/api_exception.dart';
import 'package:plante/core/utils/location_utils.dart';

// -- Features --
import 'package:plante/features/garden/services/garden_service.dart';
import 'package:plante/features/plant_detail/cubit/plant_detail_state.dart';
import 'package:plante/features/garden/services/identification_service.dart';

class PlantDetailCubit extends Cubit<PlantDetailState> {
  final String userPlantId;
  final GardenService _gardenService;
  // ignore: unused_field
  final IdentificationService _identificationService;
  final LocationService _locationService;
  final ImagePicker _imagePicker = ImagePicker();

  PlantDetailCubit({
    required this.userPlantId,
    required GardenService gardenService,
    required IdentificationService identificationService,
    required LocationService locationService,
  }) : _gardenService = gardenService,
       _identificationService = identificationService,
       _locationService = locationService,
       super(PlantDetailInitial());

  /// Busca os dados completos da planta na API (GET /plants/[id])
  Future<void> fetchDetails() async {
    if (state is PlantDetailLoading) return;
    if (state is! PlantDetailLoaded) {
      emit(PlantDetailLoading());
    }

    try {
      final plantData = await _gardenService.fetchPlantDetails(userPlantId);
      emit(PlantDetailLoaded(plantData));
    } on ApiException catch (e) {
      emit(PlantDetailError(e.message));
    } catch (e) {
      emit(PlantDetailError("Erro inesperado: ${e.toString()}"));
    }
  }

  // analise profunda
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
      // --- REMOVE A SIMULAÇÃO ---
      // print("SIMULANDO: Chamando API POST /plants/$userPlantId/analyze-deep");
      // await Future.delayed(const Duration(seconds: 1));

      // --- CHAMA O SERVIÇO REAL ---
      await _gardenService.triggerDeepAnalysis(userPlantId);

      emit(
        currentState.copyWith(
          isAnalyzingDetails: false,
          infoMessage: "Análise profunda solicitada! Você será notificado.",
        ),
      );
    } on ApiException catch (e) {
      emit(
        currentState.copyWith(
          isAnalyzingDetails: false,
          errorMessage: e.message, // Ex: "Limite diário atingido"
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

  /// Dispara a análise de saúde (Plant.id Health + Gemini Treatment)
  Future<void> triggerHealthAnalysis() async {
    if (state is! PlantDetailLoaded) return;
    final currentState = state as PlantDetailLoaded;
    if (currentState.isAnalyzingHealth) return;

    try {
      final XFile? imageFile = await _imagePicker.pickImage(
        source: ImageSource.camera, // Ou galeria
        imageQuality: 80,
        maxWidth: 1024,
      );
      if (imageFile == null) return; // Usuário cancelou

      emit(
        currentState.copyWith(
          isAnalyzingHealth: true,
          clearInfoMessage: true,
          clearErrorMessage: true,
        ),
      );

      // Pega a localização
      final location = await _locationService.getCurrentLocation();
      print("Cubit: Localização obtida: $location");

      // --- REMOVE A SIMULAÇÃO ---
      // print("SIMULANDO: Chamando API POST /plants/$userPlantId/analyze-health");
      // await Future.delayed(const Duration(seconds: 1));

      // --- CHAMA O SERVIÇO REAL ---
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
      emit(
        currentState.copyWith(
          isAnalyzingHealth: false,
          errorMessage: e.message, // Ex: "Limite diário atingido"
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

  void clearMessages() {
    if (state is PlantDetailLoaded) {
      final currentState = state as PlantDetailLoaded;
      emit(
        currentState.copyWith(clearInfoMessage: true, clearErrorMessage: true),
      );
    }
  }
}
