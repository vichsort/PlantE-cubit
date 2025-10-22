import 'package:equatable/equatable.dart';

// Classe base abstrata para todos os estados de autenticação
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => []; // Necessário para comparação de estados com Equatable
}

// Estado inicial, antes de verificar o status
class AuthInitial extends AuthState {}

// Estado enquanto uma operação (login, registro, logout) está em andamento
class AuthLoading extends AuthState {}

// Estado quando o usuário está autenticado com sucesso
class Authenticated extends AuthState {
  // Poderia carregar dados do usuário aqui se necessário
  // final UserProfile user;
  // const Authenticated(this.user);
  // @override List<Object?> get props => [user];
}

// Estado quando o usuário não está autenticado
class Unauthenticated extends AuthState {}

// Estado quando ocorre um erro durante a autenticação
class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}