import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  // TODO: Futuramente, este estado carregará os dados do perfil
  // final UserProfile profile;
  // const ProfileInitial(this.profile);
}

class ProfileLoading extends ProfileState {}

class ProfileUpdateSuccess extends ProfileState {
  final String message;
  const ProfileUpdateSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class ProfileUpdateFailure extends ProfileState {
  final String message;
  const ProfileUpdateFailure(this.message);
  @override
  List<Object?> get props => [message];
}
