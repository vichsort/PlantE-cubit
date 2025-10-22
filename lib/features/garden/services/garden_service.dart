import '../../../core/network/api_service.dart';
import '../models/plant_summary.dart';
import '../models/plant_full_data.dart';

class GardenService {
  final ApiService _apiService;

  GardenService(this._apiService);

  Future<List<PlantSummary>> fetchPlants() async {
    try {
      print("GardenService: Fetching plants...");
      final dynamic responseData = await _apiService.get('/garden/plants');

      if (responseData is List) {
        final plants = responseData
            .map((jsonItem) => PlantSummary.fromJson(jsonItem as Map<String, dynamic>))
            .toList();
        print("GardenService: Fetched ${plants.length} plants.");
        return plants;
      } else if (responseData is Map && responseData.containsKey('items') && responseData['items'] is List) {
         final List<dynamic> items = responseData['items'];
         final plants = items
            .map((jsonItem) => PlantSummary.fromJson(jsonItem as Map<String, dynamic>))
            .toList();
         print("GardenService: Fetched ${plants.length} plants from 'items'.");
        return plants;
      }
      else {
        print("GardenService: Invalid data format received from API.");
        throw Exception("Formato de dados inesperado recebido da API para a lista de plantas.");
      }
    }
    catch (e) {
      print("GardenService: Error fetching plants - $e");
      rethrow;
    }
  }

  Future<void> deletePlant(String plantId) async {
    try {
      print("GardenService: Deleting plant $plantId...");
      await _apiService.delete('/garden/plants/$plantId');
      print("GardenService: Plant $plantId deleted successfully via API.");
    } catch (e) {
       print("GardenService: Error deleting plant $plantId - $e");
       rethrow;
    }
  }

  Future<PlantFullData> fetchPlantDetails(String plantId) async {
    try {
      print("GardenService: Fetching details for plant $plantId...");
      final dynamic responseData = await _apiService.get('/garden/plants/$plantId');
      if (responseData is Map<String, dynamic>) {
        final plantDetails = PlantFullData.fromJson(responseData);
        print("GardenService: Fetched details for plant $plantId.");
        return plantDetails;
      } else {
        print("GardenService: Invalid data format received for plant details.");
        throw Exception("Formato de dados inesperado recebido da API para detalhes da planta.");
      }
    } catch (e) {
      print("GardenService: Error fetching details for plant $plantId - $e");
      rethrow;
    }
  }

  // --- Métodos Futuros ---
  // Future<void> trackWatering(String plantId) async { ... }
  // Future<void> untrackWatering(String plantId) async { ... }
  // Future<void> updatePlant(String plantId, Map<String, dynamic> updates) async { ... }
}
