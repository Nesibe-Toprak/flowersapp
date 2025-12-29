import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase;

  AuthRepositoryImpl(this._supabase);

  @override
  Future<void> signInWithEmail(String email, String password) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signUpWithEmail(String email, String password) async {
    await _supabase.auth.signUp(email: email, password: password);
  }

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  @override
  Stream<String?> get onAuthStateChanged {
    return _supabase.auth.onAuthStateChange.map((event) => event.session?.user.id);
  }
}
