import 'package:equatable/equatable.dart';
import '../../domain/entities/plant_stage.dart';
import '../../domain/entities/weekly_cycle.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/plant_repository.dart';
// Event
abstract class PlantEvent extends Equatable {
  const PlantEvent();
  @override
  List<Object> get props => [];
}

class LoadPlantStage extends PlantEvent {}

class LoadPlantHistory extends PlantEvent {}

class UpdatePlantStage extends PlantEvent {
  final PlantStage newStage;
  const UpdatePlantStage(this.newStage);
  @override
  List<Object> get props => [newStage];
}

// State
abstract class PlantState extends Equatable {
  const PlantState();
  @override
  List<Object> get props => [];
}

class PlantInitial extends PlantState {}
class PlantLoading extends PlantState {}
class PlantLoaded extends PlantState {
  final PlantStage stage;
  const PlantLoaded(this.stage);
  @override
  List<Object> get props => [stage];
}
class PlantError extends PlantState {
  final String message;
  const PlantError(this.message);
  @override
  List<Object> get props => [message];
}

class PlantHistoryLoaded extends PlantState {
  final List<WeeklyCycle> history;
  const PlantHistoryLoaded(this.history);
  @override
  List<Object> get props => [history];
}

// Bloc
//import 'package:flutter_bloc/flutter_bloc.dart';
//import '../../domain/repositories/plant_repository.dart';

class PlantBloc extends Bloc<PlantEvent, PlantState> {
  final PlantRepository _repository;

  PlantBloc(this._repository) : super(PlantInitial()) {
    on<LoadPlantStage>((event, emit) async {
      emit(PlantLoading());
      try {
        final stage = await _repository.getCurrentPlantStage();
        emit(PlantLoaded(stage));
      } catch (e) {
        emit(PlantError(e.toString()));
      }
    });
    
    on<UpdatePlantStage>((event, emit) async {
       // Optimistically update UI
       emit(PlantLoaded(event.newStage)); 
       try {
         await _repository.updatePlantStage(event.newStage);
         // Optionally reload to confirm
       } catch (e) {
         emit(PlantError("Failed to update plant: $e"));
         // Rollback could be handled here if needed
       }
    });

    on<LoadPlantHistory>((event, emit) async {
      emit(PlantLoading()); // Or a specific history loading state if needed
      try {
        final history = await _repository.getPlantHistory();
        emit(PlantHistoryLoaded(history));
      } catch (e) {
        emit(PlantError("Failed to load history: $e"));
      }
    });
  }
}
