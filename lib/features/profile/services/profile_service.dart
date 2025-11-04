// -- Core --
import 'package:plante/core/network/api_service.dart';
import 'package:plante/core/error/api_exception.dart';

// -- Models --
import 'package:plante/features/profile/models/user_profile_model.dart';

// Serviço responsável por buscar e atualizar os dados do perfil do usuário.
class ProfileService {
  final ApiService _apiService;

  ProfileService(this._apiService);

  // Busca os dados de perfil do usuário logado (endpoint: GET /profile/me).
  Future<UserProfile> fetchProfile() async {
    try {
      final dynamic responseData = await _apiService.get('/profile/me');

      if (responseData is Map<String, dynamic>) {
        // Converte o JSON da resposta para o modelo UserProfile
        final userProfile = UserProfile.fromJson(responseData);
        return userProfile;
      } else {
        throw Exception(
          "Formato de dados inesperado para o perfil do usuário.",
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // Atualiza os dados do perfil do usuário (endpoint: PUT /profile/me).
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    try {
      await _apiService.put('/profile/me', updates);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> upgradeToPremium() async {
    try {
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
      final response = await _apiService.post('/auth/revert-to-free', {});
      return response['subscription_status'] as String;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception("Erro desconhecido ao reverter assinatura: $e");
    }
  }
}
