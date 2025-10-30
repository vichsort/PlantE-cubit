import 'package:plante/core/network/api_service.dart';
import 'package:plante/core/error/api_exception.dart';

class ProfileService {
  final ApiService _apiService;

  ProfileService(this._apiService);

  Future<String> upgradeToPremium() async {
    try {
      print("ProfileService: Upgrading to Premium...");
      final response = await _apiService.post('/auth/upgrade-to-premium', {});
      return response['subscription_status'] as String;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception("Erro desconhecido ao tentar upgrade: $e");
    }
  }

  Future<String> revertToFree() async {
    try {
      print("ProfileService: Reverting to Free...");
      final response = await _apiService.post('/auth/revert-to-free', {});
      return response['subscription_status'] as String;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception("Erro desconhecido ao reverter assinatura: $e");
    }
  }
}
