import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plante/features/profile/services/profile_service.dart';
import 'profile_state.dart';
import 'package:plante/core/error/api_exception.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileService _profileService;

  ProfileCubit(this._profileService) : super(ProfileInitial());

  /// (TESTE) Tenta atualizar o usuário para Premium
  Future<void> upgradeToPremium() async {
    emit(ProfileLoading());
    try {
      final newStatus = await _profileService.upgradeToPremium();
      emit(ProfileUpdateSuccess("Status atualizado para: $newStatus"));
      // Em um app real, chamaríamos loadProfile() aqui para atualizar a UI
      emit(ProfileInitial()); // Volta ao estado inicial após o sucesso
    } on ApiException catch (e) {
      emit(ProfileUpdateFailure(e.message));
      emit(ProfileInitial()); // Volta ao estado inicial após o erro
    } catch (e) {
      emit(ProfileUpdateFailure(e.toString()));
      emit(ProfileInitial());
    }
  }

  /// (TESTE) Tenta reverter o usuário para Free
  Future<void> revertToFree() async {
    emit(ProfileLoading());
    try {
      final newStatus = await _profileService.revertToFree();
      emit(ProfileUpdateSuccess("Status atualizado para: $newStatus"));
      emit(ProfileInitial());
    } on ApiException catch (e) {
      emit(ProfileUpdateFailure(e.message));
      emit(ProfileInitial());
    } catch (e) {
      emit(ProfileUpdateFailure(e.toString()));
      emit(ProfileInitial());
    }
  }
}
