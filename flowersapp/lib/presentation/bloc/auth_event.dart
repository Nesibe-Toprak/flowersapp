import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthSignInRequested extends AuthEvent {
  final String? email;
  final String? username;
  final String password;

  const AuthSignInRequested({this.email, this.username, required this.password});

  @override
  List<Object> get props => [email ?? '', username ?? '', password];
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String username;

  const AuthSignUpRequested(this.email, this.password, this.username);

  @override
  List<Object> get props => [email, password, username];
}

class AuthSignOutRequested extends AuthEvent {}

class AuthCheckStatus extends AuthEvent {}
