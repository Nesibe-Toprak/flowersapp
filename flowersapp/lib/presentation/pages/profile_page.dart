import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../core/theme/app_colors.dart';
import '../../presentation/bloc/auth_bloc.dart';
import '../../presentation/bloc/auth_event.dart';
import '../../presentation/bloc/auth_state.dart';
import '../../presentation/bloc/plant_bloc.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _username = 'Misafir';
  String _name = '';
  String _email = 'No Email';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      _email = user.email ?? 'No Email';
      
      try {
        final data = await Supabase.instance.client
            .from('profiles')
            .select('username, full_name')
            .eq('id', user.id)
            .maybeSingle();

        if (data != null) {
           setState(() {
             _username = data['username'] as String? ?? 'Misafir';
             _name = data['full_name'] as String? ?? '';
             _isLoading = false;
           });
           return;
        }
      } catch (e) {
        debugPrint('Profile fetch error: $e');
      }

      if (mounted) {
        setState(() {
          _username = user.userMetadata?['username'] as String? ?? 'Misafir';
          _name = user.userMetadata?['full_name'] as String? ?? '';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.accentPink,
        appBar: AppBar(
          title: const Text("Profile"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            color: AppColors.primaryText,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryText),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
               
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 60,
                    color: AppColors.accentPink,
                  ),
                ),
                const SizedBox(height: 24),

                if (_name.isNotEmpty) ...[
                  Text(
                    _name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.primaryText,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                ],
               
                Text(
                  '@$_username',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 8),
               
                Text(
                  _email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryText.withOpacity(0.6),
                      ),
                ),
                const SizedBox(height: 48),
               
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<PlantBloc>().add(ClearPlantData());
                      context.read<AuthBloc>().add(AuthSignOutRequested());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.creamPeach,
                      foregroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Log Out",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
}
