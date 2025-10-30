import 'package:plante/core/network/api_service.dart';

// -- Models --
import 'package:plante/features/garden/models/plant_summary.dart';
import 'package:plante/features/plant_detail/models/plant_complete_data.dart';

class GardenService {
  final ApiService _apiService;
  GardenService(this._apiService);

  Future<List<PlantSummary>> fetchPlants() async {
    try {
      final dynamic responseData = await _apiService.get('/garden/plants');

      if (responseData is List) {
        final plants = responseData
            .map(
              (jsonItem) =>
                  PlantSummary.fromJson(jsonItem as Map<String, dynamic>),
            )
            .toList();
        return plants;
      } else if (responseData is Map &&
          responseData.containsKey('items') &&
          responseData['items'] is List) {
        final List<dynamic> items = responseData['items'];
        final plants = items
            .map(
              (jsonItem) =>
                  PlantSummary.fromJson(jsonItem as Map<String, dynamic>),
            )
            .toList();

        return plants;
      } else {
        throw Exception(
          "Formato de dados inesperado recebido da API para a lista de plantas.",
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePlant(String plantId) async {
    try {
      await _apiService.delete('/garden/plants/$plantId');
    } catch (e) {
      rethrow;
    }
  }

  Future<PlantCompleteData> fetchPlantDetails(String plantId) async {
    try {
      final dynamic responseData = await _apiService.get(
        '/garden/plants/$plantId',
      );
      if (responseData is Map<String, dynamic>) {
        final plantDetails = PlantCompleteData.fromJson(responseData);
        return plantDetails;
      } else {
        throw Exception(
          "Formato de dados inesperado recebido da API para detalhes da planta.",
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // --- Métodos Futuros ---
  // Future<void> trackWatering(String plantId) async { ... }
  // Future<void> untrackWatering(String plantId) async { ... }
  // Future<void> updatePlant(String plantId, Map<String, dynamic> updates) async { ... }
}
