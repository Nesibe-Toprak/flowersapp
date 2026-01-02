import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/di/injection_container.dart' as di;
import 'presentation/bloc/auth_bloc.dart';
import 'presentation/bloc/auth_event.dart';
import 'presentation/bloc/auth_state.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/dashboard_page.dart';
import 'presentation/bloc/planner_bloc.dart';
import 'presentation/bloc/planner_event.dart';
import 'presentation/bloc/plant_bloc.dart'; // Contains State/Event/Bloc

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );
  
  await di.init();

  runApp(const EcoPlanApp());
}

class EcoPlanApp extends StatelessWidget {
  const EcoPlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<AuthBloc>()..add(AuthCheckStatus()),
        ),
        BlocProvider(
           create: (_) => di.sl<PlannerBloc>()..add(PlannerLoadHabits(DateTime.now())),
        ),
        BlocProvider(
           create: (_) => di.sl<PlantBloc>()..add(LoadPlantStage()),
        ),
      ],
      child: MaterialApp(
        title: 'FLOWERS',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return const DashboardPage();
        }
        return const LoginPage();
      },
    );
  }
}
