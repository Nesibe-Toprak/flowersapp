import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthSignInRequested>(_onSignIn);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthSignOutRequested>(_onSignOut);
  }

  void _onCheckStatus(AuthCheckStatus event, Emitter<AuthState> emit) async {
    await emit.forEach(
      _authRepository.onAuthStateChanged,
      onData: (userId) {
        if (userId != null) {
          return AuthAuthenticated(userId);
        } else {
          return AuthUnauthenticated();
        }
      },
    );
  }

  void _onSignIn(AuthSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.signInWithEmail(event.email, event.password);
      // The stream subscription in _onCheckStatus will handle the state update
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  void _onSignUp(AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.signUpWithEmail(event.email, event.password);
       // The stream subscription in _onCheckStatus will handle the state update
       // Note: Depending on Supabase settings, email confirmation might be required.
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  void _onSignOut(AuthSignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.signOut();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
