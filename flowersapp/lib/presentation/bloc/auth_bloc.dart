import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
//import 'package:supabase_flutter/supabase_flutter.dart';
// "hide AuthState" ekleyerek çakışmayı önlüyoruz
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
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
      String? targetEmail = event.email;
      
      if (targetEmail == null && event.username != null) {
        targetEmail = await _authRepository.getEmailFromUsername(event.username!);
        if (targetEmail == null) {
           emit(AuthError("Kullanıcı adı bulunamadı."));
           emit(AuthUnauthenticated());
           return;
        }
      }

      if (targetEmail != null) {
        await _authRepository.signInWithEmail(targetEmail, event.password);
      } else {
         emit(AuthError("E-posta veya kullanıcı adı gerekli."));
         emit(AuthUnauthenticated());
      }
      // The stream subscription in _onCheckStatus will handle the state update
    } on AuthException catch (e) {
      emit(AuthError(_mapAuthErrorMessage(e.message)));
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError("Bir hata oluştu: ${e.toString()}"));
      emit(AuthUnauthenticated());
    }
  }

  void _onSignUp(AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.signUpWithEmail(event.email, event.password, event.username);
      emit(AuthSignUpSuccess());
      emit(AuthUnauthenticated()); // Reset to unauthenticated so user can login or retry
    } on AuthException catch (e) {
      emit(AuthError(_mapAuthErrorMessage(e.message)));
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError("Bir hata oluştu: ${e.toString()}"));
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
  String _mapAuthErrorMessage(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'E-posta veya şifre hatalı.';
    } else if (message.contains('User already registered')) {
      return 'Bu e-posta adresi zaten kayıtlı.';
    } else if (message.contains('Password should be at least')) {
        return 'Şifre en az 6 karakter olmalıdır.';
    } else if (message.contains('Email not confirmed')) {
      return 'Lütfen e-posta adresinizi doğrulayın.';
    }
    return 'Bir hata oluştu: $message';
  }
}
