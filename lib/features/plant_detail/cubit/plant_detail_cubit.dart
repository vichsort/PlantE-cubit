import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'plant_detail_state.dart';
import '../../../core/error/api_exception.dart';
import '../../garden/services/garden_service.dart';
import 'package:plante/features/garden/services/identification_service.dart';

class PlantDetailCubit extends Cubit<PlantDetailState> {
  final String _userPlantId;
  final GardenService _gardenService;
  final IdentificationService _identificationService;
  final ImagePicker _imagePicker = ImagePicker();

  PlantDetailCubit({
    required String userPlantId,
    required GardenService gardenService,
    required IdentificationService identificationService,
  }) : _userPlantId = userPlantId,
       _gardenService = gardenService,
       _identificationService = identificationService,
       super(PlantDetailInitial());

  /// Busca os dados completos da planta na API
  Future<void> fetchDetails() async {
    emit(PlantDetailLoading());
    try {
      final plantData = await _gardenService.fetchPlantDetails(_userPlantId);
      // emit(PlantDetailLoaded(plantData));
    } on ApiException catch (e) {
      emit(PlantDetailError(e.message));
    } catch (e) {
      emit(
        PlantDetailError(
          "Erro inesperado ao carregar detalhes: ${e.toString()}",
        ),
      );
    }
  }

  /// Dispara a análise profunda (Gemini Details + Nutritional)
  Future<void> triggerDeepAnalysis() async {
    if (state is! PlantDetailLoaded)
      return; // Só funciona se já tiver carregado
    final currentState = state as PlantDetailLoaded;

    // Mostra loading no botão específico
    emit(currentState.copyWith(isAnalyzingDetails: true));
    try {
      // TODO: Chamar o serviço que chama POST /analyze-deep
      // await _gardenService.triggerDeepAnalysis(_userPlantId);

      // Simulação de espera
      await Future.delayed(const Duration(seconds: 2));
      print("TODO: Chamar API POST /analyze-deep para $_userPlantId");

      // Após sucesso, recarrega os dados para obter has_details = true
      await fetchDetails(); // O fetchDetails emitirá o novo PlantDetailLoaded

      // (Opcional) Mostrar SnackBar de "processando"
      // O ideal é o worker notificar via Push quando estiver pronto
    } on ApiException catch (e) {
      emit(PlantDetailError(e.message)); // Mostra erro
    } catch (e) {
      emit(PlantDetailError("Erro inesperado: ${e.toString()}"));
    }
    // Garante que o loading do botão pare, mesmo se fetchDetails falhar
    if (state is PlantDetailLoaded) {
      emit((state as PlantDetailLoaded).copyWith(isAnalyzingDetails: false));
    }
  }

  /// Dispara a análise de saúde (Plant.id Health + Gemini Treatment)
  Future<void> triggerHealthAnalysis() async {
    if (state is! PlantDetailLoaded) return;
    final currentState = state as PlantDetailLoaded;

    try {
      // 1. Pedir nova foto ao usuário
      final XFile? imageFile = await _imagePicker.pickImage(
        source: ImageSource.camera, // Ou galeria
        imageQuality: 80,
        maxWidth: 1024,
      );
      if (imageFile == null) return; // Usuário cancelou

      // 2. Mostrar loading no botão
      emit(currentState.copyWith(isAnalyzingHealth: true));

      // TODO: Chamar o serviço que chama POST /analyze-health
      // (Este serviço precisará do LocationService e ImageUtils)
      // await _gardenService.triggerHealthAnalysis(_userPlantId, File(imageFile.path));

      // Simulação de espera
      await Future.delayed(const Duration(seconds: 2));
      print("TODO: Chamar API POST /analyze-health para $_userPlantId");

      // 3. Recarregar os dados
      await fetchDetails();

      // (Opcional) Mostrar SnackBar "processando"
    } on ApiException catch (e) {
      emit(PlantDetailError(e.message));
    } catch (e) {
      emit(PlantDetailError("Erro inesperado: ${e.toString()}"));
    }
    // Garante que o loading do botão pare
    if (state is PlantDetailLoaded) {
      emit((state as PlantDetailLoaded).copyWith(isAnalyzingHealth: false));
    }
  }
}
