import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

// -- Core --
import 'package:plante/core/error/api_exception.dart';
import 'package:plante/core/utils/location_utils.dart';

// -- Features --
import 'package:plante/features/garden/services/garden_service.dart';
import 'package:plante/features/plant_detail/cubit/plant_detail_state.dart';
import 'package:plante/features/garden/services/identification_service.dart';
import 'package:plante/features/plant_detail/models/plant_complete_data.dart';

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
      emit(PlantDetailLoaded(plantData as PlantCompleteData));
    } on ApiException catch (e) {
      emit(PlantDetailError(e.message));
    } catch (e) {
      emit(PlantDetailError("Erro inesperado: ${e.toString()}"));
    }
  }

  /// Dispara a análise profunda (Gemini Details + Nutritional)
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
      // TODO: Criar 'triggerDeepAnalysis' no GardenService
      // await _gardenService.triggerDeepAnalysis(userPlantId);
      print("SIMULANDO: Chamando API POST /plants/$userPlantId/analyze-deep");
      await Future.delayed(const Duration(seconds: 1)); // Simulação

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

  /// Dispara a análise de saúde (Plant.id Health + Gemini Treatment)
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

      // Chama o serviço
      // TODO: Criar 'analyzeHealth' no IdentificationService
      // await _identificationService.analyzeHealth(
      //   userPlantId,
      //   File(imageFile.path),
      //   location
      // );
      print("SIMULANDO: Chamando API POST /plants/$userPlantId/analyze-health");
      await Future.delayed(const Duration(seconds: 1)); // Simulação

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

  /// Limpa as mensagens de SnackBar (chamado pela UI após exibir)
  void clearMessages() {
    if (state is PlantDetailLoaded) {
      final currentState = state as PlantDetailLoaded;
      emit(
        currentState.copyWith(clearInfoMessage: true, clearErrorMessage: true),
      );
    }
  }
}
