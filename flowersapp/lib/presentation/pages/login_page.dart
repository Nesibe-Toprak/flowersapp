import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoginMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accentPink,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // Navigate to Dashboard (Placeholder for now)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Giriş Başarılı!')),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DashboardPage()),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is AuthSignUpSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Kayıt Başarılı! Lütfen giriş yapın.')),
            );
            // Optional: Switch to login mode automatically
            // setState(() { _isLoginMode = true; }); // Cannot call setState inside clean stateless logic easily without context access or changing current widget state.
            // Since we are in a listener of a StatefulWidget, we CAN call setState if we want, or just let user do it.
            // Let's just show message for now as we are inside the listener callback of _LoginPageState.
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                // Top Section - Logo (40% height)
                Expanded(
                  flex: 4,
                  child: Container(
                    width: double.infinity,
                    color: AppColors.accentPink,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '🌸',
                            style: TextStyle(fontSize: 100),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'FLOWERS',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: AppColors.primaryText,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Bottom Section - Form (60% height)
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!_isLoginMode) ...[
                            _buildTextField(
                              controller: _usernameController,
                              hintText: 'Kullanıcı Adı',
                              icon: Icons.person,
                            ),
                            const SizedBox(height: 16),
                          ],
                          _buildTextField(
                            controller: _emailController,
                            hintText: _isLoginMode ? 'E-posta veya Kullanıcı Adı' : 'E-posta',
                            icon: Icons.email,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _passwordController,
                            hintText: 'Şifre',
                            icon: Icons.lock,
                            obscureText: true,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: state is AuthLoading 
                                  ? null 
                                  : () {
                                if (_isLoginMode) {
                                  final input = _emailController.text.trim();
                                  final password = _passwordController.text.trim();
                                  
                                  if (input.isEmpty || password.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Lütfen tüm alanları doldurun.')),
                                    );
                                    return;
                                  }

                                  if (input.contains('@')) {
                                     context.read<AuthBloc>().add(
                                        AuthSignInRequested(
                                          email: input,
                                          password: password,
                                        ),
                                      );
                                  } else {
                                     context.read<AuthBloc>().add(
                                        AuthSignInRequested(
                                          username: input,
                                          password: password,
                                        ),
                                      );
                                  }
                                } else {
                                  final username = _usernameController.text.trim();
                                  final email = _emailController.text.trim();
                                  final password = _passwordController.text.trim();

                                  if (username.isEmpty || email.isEmpty || password.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Lütfen tüm alanları doldurun.')),
                                    );
                                    return;
                                  }

                                  context.read<AuthBloc>().add(
                                        AuthSignUpRequested(
                                          email,
                                          password,
                                          username,
                                        ),
                                      );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.creamPeach,
                                foregroundColor: AppColors.primaryText,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: state is AuthLoading 
                                ? const SizedBox(
                                    width: 24, 
                                    height: 24, 
                                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryText),
                                  )
                                : Text(
                                  _isLoginMode ? 'Giriş Yap' : 'Kayıt Ol',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLoginMode = !_isLoginMode;
                              });
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primaryText,
                            ),
                            child: Text(
                              _isLoginMode
                                  ? 'Hesabınız yok mu? Kayıt Olun'
                                  : 'Zaten hesabınız var mı? Giriş Yapın',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        },
       ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.creamPeach,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: AppColors.primaryText),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: AppColors.primaryText.withOpacity(0.5)),
          prefixIcon: Icon(icon, color: AppColors.primaryText),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
