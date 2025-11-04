import 'package:flutter_bloc/flutter_bloc.dart';

// -- Core --
import 'package:plante/core/error/api_exception.dart';

// -- Cubits e services --
import 'package:plante/features/auth/cubit/auth_cubit.dart';
import 'package:plante/features/auth/cubit/auth_state.dart';
import 'package:plante/features/profile/cubit/profile_state.dart';
import 'package:plante/features/profile/services/profile_service.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileService _profileService;
  final AuthCubit _authCubit;

  ProfileCubit(this._profileService, this._authCubit) : super(ProfileInitial());

  // Busca os dados do perfil (para o primeiro carregamento da tela)
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

  // Atualiza os dados do perfil do usuário (bio, país, estado)
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    if (state is! ProfileLoaded) return;
    final currentProfile = (state as ProfileLoaded).profile;

    emit(ProfileUpdating(currentProfile));
    try {
      // Chama o serviço que chama PUT /profile/me
      await _profileService.updateProfile(updates);
      await _authCubit.checkAuthStatus();

      // Emite um estado de sucesso local para o SnackBar
      emit(
        ProfileUpdateSuccess(
          (_authCubit.state as Authenticated).user,
          "Perfil atualizado com sucesso!",
        ),
      );

      await Future.delayed(const Duration(milliseconds: 50));
      emit(ProfileIdle((_authCubit.state as Authenticated).user));
    } on ApiException catch (e) {
      emit(ProfileUpdateFailure(currentProfile, e.message));
    } catch (e) {
      emit(
        ProfileUpdateFailure(
          currentProfile,
          "Erro inesperado ao atualizar: ${e.toString()}",
        ),
      );
    }
  }

  // Atualiza o status do usuário para Premium (TESTE)
  Future<void> upgradeToPremium() async {
    if (state is! ProfileLoaded) return;
    final currentProfile = (state as ProfileLoaded).profile;

    emit(ProfileUpdating(currentProfile));
    try {
      await _profileService.upgradeToPremium();
      await _authCubit.checkAuthStatus();

      emit(
        ProfileUpdateSuccess(
          (_authCubit.state as Authenticated).user,
          "Assinatura Premium ativada!",
        ),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      emit(ProfileIdle((_authCubit.state as Authenticated).user));
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

  // Reverte o status do usuário para Free (TESTE)
  Future<void> revertToFree() async {
    if (state is! ProfileLoaded) return;
    final currentProfile = (state as ProfileLoaded).profile;

    emit(ProfileUpdating(currentProfile));
    try {
      await _profileService.revertToFree();
      await _authCubit.checkAuthStatus();

      emit(
        ProfileUpdateSuccess(
          (_authCubit.state as Authenticated).user,
          "Assinatura revertida para Gratuito.",
        ),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      emit(ProfileIdle((_authCubit.state as Authenticated).user));
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
