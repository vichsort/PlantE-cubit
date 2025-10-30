import 'package:plante/core/network/api_service.dart';

// -- Models --
import 'package:plante/features/garden/models/plant_summary.dart';
import 'package:plante/features/plant_detail/models/plant_complete_data.dart';

class GardenService {
  final ApiService _apiService;
  GardenService(this._apiService);

  // Pegar palantas do usuário
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

  // Tirar planta do jardim
  Future<void> deletePlant(String plantId) async {
    try {
      await _apiService.delete('/garden/plants/$plantId');
    } catch (e) {
      rethrow;
    }
  }

  // Mais detalhes da planta
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

  // Ativa monitoramento de rega para uma planta.
  Future<void> trackWatering(String plantId) async {
    try {
      print("GardenService: Tracking watering for $plantId..."); // Debug
      // Envia uma requisição POST vazia, como esperado pelo endpoint
      await _apiService.post('/garden/plants/$plantId/track-watering', {});
      print("GardenService: Watering tracking enabled for $plantId."); // Debug
    } catch (e) {
      print("GardenService: Error tracking watering - $e"); // Debug
      rethrow;
    }
  }

  // Desativa o monitoramento de rega para uma planta.
  Future<void> untrackWatering(String plantId) async {
    try {
      print("GardenService: Untracking watering for $plantId..."); // Debug
      await _apiService.delete('/garden/plants/$plantId/track-watering');
      print("GardenService: Watering tracking disabled for $plantId."); // Debug
    } catch (e) {
      print("GardenService: Error untracking watering - $e"); // Debug
      rethrow;
    }
  }

  // Atualiza os dados de uma planta (nickname, last_watered, care_notes).
  Future<void> updatePlant(String plantId, Map<String, dynamic> updates) async {
    try {
      print(
        "GardenService: Updating plant $plantId with data: $updates",
      ); // Debug
      // O endpoint PUT retorna os dados atualizados, mas não precisamos
      // usá-los aqui, pois o Cubit geralmente recarrega o estado.
      await _apiService.put('/garden/plants/$plantId', updates);
      print("GardenService: Plant $plantId updated successfully."); // Debug
    } catch (e) {
      print("GardenService: Error updating plant $plantId - $e"); // Debug
      rethrow;
    }
  }
}
