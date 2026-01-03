abstract class AuthRepository {
  Future<void> signInWithEmail(String email, String password);
  Future<void> signUpWithEmail(String email, String password, String username);
  Future<String?> getEmailFromUsername(String username);
  Future<void> signOut();
  Stream<String?> get onAuthStateChanged;
}
