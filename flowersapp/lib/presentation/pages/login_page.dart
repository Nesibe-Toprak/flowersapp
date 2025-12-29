import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // Navigate to Dashboard (Placeholder for now)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Giriş Başarılı!')),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                // Top Section - Logo (40% height)
                Expanded(
                  flex: 4,
                  child: Container(
                    width: double.infinity,
                    color: AppColors.backgroundBeige,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.eco, // Placeholder for Seed Logo
                            size: 100,
                            color: AppColors.sageGreen,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'EcoPlan',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: AppColors.darkGrey,
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTextField(
                          controller: _emailController,
                          hintText: 'E-posta',
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
                            onPressed: () {
                              context.read<AuthBloc>().add(
                                    AuthSignInRequested(
                                      _emailController.text,
                                      _passwordController.text,
                                    ),
                                  );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentPink,
                              foregroundColor: AppColors.darkGrey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              'Giriş Yap',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                             context.read<AuthBloc>().add(
                                    AuthSignUpRequested(
                                      _emailController.text,
                                      _passwordController.text,
                                    ),
                                  );
                          },
                          child: const Text('Hesap Oluştur'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
        style: const TextStyle(color: AppColors.darkGrey),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: AppColors.darkGrey.withOpacity(0.5)),
          prefixIcon: Icon(icon, color: AppColors.darkGrey),
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
