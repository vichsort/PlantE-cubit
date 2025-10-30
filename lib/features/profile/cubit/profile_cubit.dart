import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plante/core/error/api_exception.dart';
import 'package:plante/features/auth/cubit/auth_cubit.dart';
import 'package:plante/features/profile/services/profile_service.dart';
import 'package:plante/features/profile/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileService _profileService;
  final AuthCubit _authCubit;

  ProfileCubit(this._profileService, this._authCubit) : super(ProfileInitial());

  // Busca os dados do perfil do usuário logado (GET /profile/me)
  Future<void> loadProfile() async {
    if (state is ProfileLoading) return;

    emit(ProfileLoading());
    try {
      final userProfile = await _profileService.fetchProfile();
      emit(ProfileIdle(userProfile));
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        _authCubit.logout();
      } else {
        emit(ProfileError(e.message));
      }
    } catch (e) {
      emit(ProfileError("Erro inesperado ao carregar perfil: ${e.toString()}"));
    }
  }

  // Atualiza o status do usuário para Premium (TESTE)
  Future<void> upgradeToPremium() async {
    if (state is! ProfileLoaded) return;
    final currentProfile = (state as ProfileLoaded).profile;

    emit(ProfileUpdating(currentProfile));
    try {
      // TODO: Chamar o serviço que chama POST /auth/upgrade-to-premium
      // await _profileService.upgradeToPremium();
      print("SIMULANDO: Upgrade para Premium");
      await Future.delayed(const Duration(seconds: 1)); // Simulação de API

      // Recarrega o perfil para obter o novo status
      await loadProfile();
      // Após o loadProfile, o estado será ProfileIdle (com dados atualizados)
      // Poderíamos emitir ProfileUpdateSuccess, mas recarregar é mais robusto
    } on ApiException catch (e) {
      emit(ProfileUpdateFailure(currentProfile, e.message)); // Emite falha
    } catch (e) {
      emit(
        ProfileUpdateFailure(
          currentProfile,
          "Erro inesperado: ${e.toString()}",
        ),
      );
    }
  }

  /// Reverte o status do usuário para Free (TESTE)
  Future<void> revertToFree() async {
    if (state is! ProfileLoaded) return;
    final currentProfile = (state as ProfileLoaded).profile;

    emit(ProfileUpdating(currentProfile)); // Mostra loading no botão
    try {
      // TODO: Chamar o serviço que chama POST /auth/revert-to-free
      // await _profileService.revertToFree();
      print("SIMULANDO: Revertendo para Free");
      await Future.delayed(const Duration(seconds: 1)); // Simulação de API

      // Recarrega o perfil para obter o novo status
      await loadProfile();
    } on ApiException catch (e) {
      emit(ProfileUpdateFailure(currentProfile, e.message));
    } catch (e) {
      emit(
        ProfileUpdateFailure(
          currentProfile,
          "Erro inesperado: ${e.toString()}",
        ),
      );
    }
  }
}
