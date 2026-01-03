import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../presentation/bloc/auth_bloc.dart';

import '../../domain/repositories/planner_repository.dart';
import '../../data/repositories/planner_repository_impl.dart';
import '../../presentation/bloc/planner_bloc.dart';

import '../../domain/entities/plant_stage.dart';
import '../../domain/repositories/plant_repository.dart';
import '../../data/repositories/plant_repository_impl.dart';
import '../../presentation/bloc/plant_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  
  final supabase = Supabase.instance.client;
  sl.registerLazySingleton(() => supabase);

  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerFactory(() => AuthBloc(sl()));

  sl.registerLazySingleton<PlannerRepository>(() => PlannerRepositoryImpl(sl()));
  sl.registerFactory(() => PlannerBloc(sl()));

  sl.registerLazySingleton<PlantRepository>(() => PlantRepositoryImpl(sl()));
  sl.registerFactory(() => PlantBloc(sl()));
}
