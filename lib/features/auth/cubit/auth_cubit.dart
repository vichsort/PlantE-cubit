import 'package:flutter_bloc/flutter_bloc.dart';

// -- Core --
import 'package:plante/core/error/api_exception.dart';

// -- Features --
import 'package:plante/features/auth/services/auth_service.dart';
import 'package:plante/features/auth/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit(this._authService) : super(AuthInitial()) {
    _authService.setSessionExpiredCallback(logout);
  }

  // Verifica o status inicial de autenticação ao iniciar o app.
  Future<void> checkAuthStatus() async {
    try {
      final token = await _authService.checkAuthenticationStatus();
      if (token != null) {
        emit(Authenticated());
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
      emit(Authenticated());
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
      // Após o registro, deixamos o usuário deslogado para que ele faça login
      emit(Unauthenticated());
    } on ApiException catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure("Erro inesperado durante o registro: ${e.toString()}"));
    }
  }

  // Realiza o logout do usuário.
  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _authService.logout();
      emit(Unauthenticated());
    } catch (e) {
      emit(Unauthenticated());
    }
  }
}
