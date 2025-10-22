import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/auth_service.dart';
import 'auth_state.dart';
import '../../../core/error/api_exception.dart'; // Importe a exceção

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit(this._authService) : super(AuthInitial());

  /// Verifica o status inicial de autenticação ao iniciar o app.
  Future<void> checkAuthStatus() async {
    // Não emite Loading aqui para evitar piscar a tela
    try {
      final token = await _authService.checkAuthenticationStatus();
      if (token != null) {
        emit(Authenticated());
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      // Se houver erro ao ler o token (raro), assume deslogado
      emit(Unauthenticated());
    }
  }

  /// Tenta realizar o login do usuário.
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

  /// Tenta registrar um novo usuário.
  Future<void> register(String email, String password) async {
    emit(AuthLoading());
    try {
      await _authService.register(email, password);
      // Após o registro, deixamos o usuário deslogado para que ele faça login
      emit(Unauthenticated());
      // (Opcional: Poderia emitir um estado 'RegistrationSuccess'
      // para a UI mostrar uma mensagem antes de ir para Unauthenticated)
    } on ApiException catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure("Erro inesperado durante o registro: ${e.toString()}"));
    }
  }

  /// Realiza o logout do usuário.
  Future<void> logout() async {
    emit(AuthLoading()); // Mostra loading durante o logout
    try {
      await _authService.logout();
      emit(Unauthenticated());
    } catch (e) {
      // Mesmo se o logout falhar, desloga localmente
      emit(Unauthenticated());
    }
  }
}