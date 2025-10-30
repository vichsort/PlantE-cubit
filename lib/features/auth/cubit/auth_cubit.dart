import 'package:flutter_bloc/flutter_bloc.dart';

// -- Core --
import 'package:plante/core/error/api_exception.dart';

// -- Features --
import 'package:plante/features/auth/services/auth_service.dart';
import 'package:plante/features/auth/cubit/auth_state.dart';
import 'package:plante/features/profile/services/profile_service.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;
  final ProfileService _profileService;

  AuthCubit(this._authService, this._profileService) : super(AuthInitial()) {
    _authService.setSessionExpiredCallback(logout);
  }

  // Verifica o status inicial de autenticação ao iniciar o app.
  Future<void> checkAuthStatus() async {
    try {
      final token = await _authService.checkAuthenticationStatus();
      if (token != null) {
        try {
          final userProfile = await _profileService.fetchProfile();
          emit(Authenticated(userProfile));
        } catch (e) {
          await _authService.logout();
          emit(Unauthenticated());
        }
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  // Tenta realizar o login do usuário.
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      await _authService.login(email, password);
      final userProfile = await _profileService.fetchProfile();
      emit(Authenticated(userProfile));
    } on ApiException catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure("Erro inesperado durante o login: ${e.toString()}"));
    }
  }

  // Tenta registrar um novo usuário.
  Future<void> register(String email, String password) async {
    emit(AuthLoading());
    try {
      await _authService.register(email, password);
      // Após o registro, força o usuário a logar
      emit(Unauthenticated());
    } on ApiException catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure("Erro inesperado during register: ${e.toString()}"));
    }
  }

  // Realiza o logout do usuário.
  Future<void> logout() async {
    if (state is Unauthenticated) return;

    emit(AuthLoading());
    try {
      await _authService.logout();
      emit(Unauthenticated());
    } catch (e) {
      emit(Unauthenticated());
    }
  }
}
