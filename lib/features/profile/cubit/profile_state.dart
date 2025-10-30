import 'package:equatable/equatable.dart';
import 'package:plante/features/profile/models/user_profile_model.dart'; // Importe seu modelo

// Classe base
abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

/// Estado inicial, nada foi carregado
class ProfileInitial extends ProfileState {}

/// Carregando os dados do perfil (mostra tela de loading)
class ProfileLoading extends ProfileState {}

/// Super-classe para todos os estados que ocorrem APÓS o carregamento inicial,
/// garantindo que sempre tenhamos os dados do perfil para exibir,
/// mesmo durante outras ações (como atualizar).
abstract class ProfileLoaded extends ProfileState {
  final UserProfile profile;
  const ProfileLoaded(this.profile);
  @override
  List<Object?> get props => [profile];
}

/// Estado padrão de "perfil carregado e ocioso".
class ProfileIdle extends ProfileLoaded {
  const ProfileIdle(super.profile);
}

/// Estado enquanto uma ação (upgrade/revert) está em andamento (mostra loading no botão)
class ProfileUpdating extends ProfileLoaded {
  const ProfileUpdating(super.profile);
}

/// Estado temporário após um update de sucesso (para mostrar SnackBar verde)
class ProfileUpdateSuccess extends ProfileLoaded {
  final String message;
  const ProfileUpdateSuccess(super.profile, this.message);
  @override
  List<Object?> get props => [profile, message];
}

/// Estado temporário após um update falhar (para mostrar SnackBar vermelho)
class ProfileUpdateFailure extends ProfileLoaded {
  final String message;
  const ProfileUpdateFailure(super.profile, this.message);
  @override
  List<Object?> get props => [profile, message];
}

/// Falha ao carregar o perfil inicial (mostra tela de erro)
class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object> get props => [message];
}
