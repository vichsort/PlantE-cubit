import 'package:plante/core/network/api_service.dart';
import 'package:plante/core/error/api_exception.dart';

class ProfileService {
  final ApiService _apiService;

  ProfileService(this._apiService);

  /// (TESTE) Chama a API para atualizar o status do usuário para Premium.
  Future<String> upgradeToPremium() async {
    try {
      print("ProfileService: Upgrading to Premium...");
      final response = await _apiService.post('/auth/upgrade-to-premium', {});
      // Retorna o novo status vindo da API
      return response['subscription_status'] as String;
    } on ApiException {
      rethrow; // Deixa o Cubit tratar
    } catch (e) {
      throw Exception("Erro desconhecido ao tentar upgrade: $e");
    }
  }

  /// (TESTE) Chama a API para reverter o status do usuário para Free.
  Future<String> revertToFree() async {
    try {
      print("ProfileService: Reverting to Free...");
      final response = await _apiService.post('/auth/revert-to-free', {});
      // Retorna o novo status vindo da API
      return response['subscription_status'] as String;
    } on ApiException {
      rethrow; // Deixa o Cubit tratar
    } catch (e) {
      throw Exception("Erro desconhecido ao reverter assinatura: $e");
    }
  }
}
