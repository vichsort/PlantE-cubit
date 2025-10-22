import '../../../core/network/api_service.dart';
import '../models/plant_summary.dart';

/// Serviço responsável pelas operações relacionadas ao jardim do usuário.
class GardenService {
  final ApiService _apiService;

  // Recebe a instância do ApiService via construtor
  GardenService(this._apiService);

  /// Busca a lista de plantas resumidas do jardim do usuário logado.
  /// Retorna uma lista de [PlantSummary].
  /// Lança [ApiException] ou outra exceção em caso de falha na API.
  Future<List<PlantSummary>> fetchPlants() async {
    try {
      print("GardenService: Fetching plants..."); // Debug

      // Chama o endpoint GET /garden/plants através do ApiService
      // Espera-se que a API retorne um Map com uma chave 'items' contendo a lista,
      // ou diretamente a lista (ajuste conforme a resposta real da sua API).
      // Nosso ApiService atual retorna 'dynamic', então precisamos checar o tipo.
      final dynamic responseData = await _apiService.get('/garden/plants');

      // Verifica se a resposta contém uma lista (ou um mapa com 'items')
      if (responseData is List) {
        // Mapeia cada item da lista JSON para um objeto PlantSummary
        final plants = responseData
            .map((jsonItem) => PlantSummary.fromJson(jsonItem as Map<String, dynamic>))
            .toList();
        print("GardenService: Fetched ${plants.length} plants."); // Debug
        return plants;
      } else if (responseData is Map && responseData.containsKey('items') && responseData['items'] is List) {
         // Se a API envelopar a lista dentro de 'items'
         final List<dynamic> items = responseData['items'];
         final plants = items
            .map((jsonItem) => PlantSummary.fromJson(jsonItem as Map<String, dynamic>))
            .toList();
         print("GardenService: Fetched ${plants.length} plants from 'items'."); // Debug
        return plants;
      }
      else {
        // Se a resposta não for uma lista ou o formato esperado, lança um erro.
        print("GardenService: Invalid data format received from API."); // Debug
        throw Exception("Formato de dados inesperado recebido da API para a lista de plantas.");
      }
    }
    // Não precisamos capturar ApiException aqui, deixamos o Cubit tratar.
    catch (e) {
      print("GardenService: Error fetching plants - $e"); // Debug
      rethrow; // Re-lança a exceção para o Cubit
    }
  }
}