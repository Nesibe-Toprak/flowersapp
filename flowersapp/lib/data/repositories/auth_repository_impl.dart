import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase;

  AuthRepositoryImpl(this._supabase);

  @override
  Future<void> signInWithEmail(String email, String password) async {
    try {
    final response = await _supabase.auth.signInWithPassword(email: email, password: password);
    print("Giriş Başarılı: ${response.user?.email}"); // Log ekle
  } catch (e) {
    print("Giriş Hatası: $e"); // Hatayı gör
    rethrow; // Hatayı UI katmanına fırlat ki ekranda uyarı gösterebilesin
  }
  }

  @override
  Future<void> signUpWithEmail(String email, String password, String username) async {
    await _supabase.auth.signUp(
      email: email, 
      password: password,
      data: {
        'username': username,
      },
      emailRedirectTo: 'io.toprak.flowersapp://login-callback',
    );
  }

  @override
  Future<String?> getEmailFromUsername(String username) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select('email')
          .eq('username', username)
          .maybeSingle();
      return data?['email'] as String?;
    } catch (e) {
      return null;
    }
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
