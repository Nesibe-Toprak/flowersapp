import 'package:equatable/equatable.dart';
import '../../domain/entities/plant_stage.dart';
import '../../domain/entities/weekly_cycle.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/plant_repository.dart';

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

class UpdatePlantProgress extends PlantEvent {
  final int currentDayIndex;
  final bool allTasksCompleted;

  const UpdatePlantProgress({
    required this.currentDayIndex,
    required this.allTasksCompleted,
  });

  @override
  List<Object> get props => [currentDayIndex, allTasksCompleted];
}

class CompleteWeek extends PlantEvent {}

class UpdateCycleNote extends PlantEvent {
  final String cycleId;
  final String note;
  const UpdateCycleNote(this.cycleId, this.note);
  @override
  List<Object> get props => [cycleId, note];
}

class ClearPlantData extends PlantEvent {}


abstract class PlantState extends Equatable {
  const PlantState();
  @override
  List<Object> get props => [];
}

class PlantInitial extends PlantState {}
class PlantLoading extends PlantState {}
class PlantLoaded extends PlantState {
  final PlantStage stage;
  final bool isGrowthHalted;
  const PlantLoaded(this.stage, {this.isGrowthHalted = false});
  @override
  List<Object> get props => [stage, isGrowthHalted];
}
class PlantError extends PlantState {
  final String message;
  const PlantError(this.message);
  @override
  List<Object> get props => [message];
}

class PlantWeekArchived extends PlantState {
  final PlantStage archivedStage;
  const PlantWeekArchived(this.archivedStage);
  @override
  List<Object> get props => [archivedStage];
}

class PlantHistoryLoaded extends PlantState {
  final List<WeeklyCycle> history;
  const PlantHistoryLoaded(this.history);
  @override
  List<Object> get props => [history];
}

class PlantBloc extends Bloc<PlantEvent, PlantState> {
  final PlantRepository _repository;

  PlantBloc(this._repository) : super(PlantInitial()) {
    on<LoadPlantStage>((event, emit) async {
      emit(PlantLoading());
      try {
        final result = await _repository.getCurrentPlantStage();
        emit(PlantLoaded(result.stage, isGrowthHalted: result.isGrowthHalted));
      } catch (e) {
        emit(PlantError(e.toString()));
      }
    });
    
    on<UpdatePlantProgress>((event, emit) async {
      if (!event.allTasksCompleted) return;

      if (state is PlantLoaded) {
        final currentLoadedState = state as PlantLoaded;
        if (currentLoadedState.isGrowthHalted) return;
      }

      PlantStage newStage;
      if (event.currentDayIndex >= 0 && event.currentDayIndex < PlantStage.values.length) {
        newStage = PlantStage.values[event.currentDayIndex];
      } else {
        return;
      }

      try {
       
        await _repository.updatePlantStage(newStage);
        emit(PlantLoaded(newStage));
        if (event.currentDayIndex == 6) {
          add(CompleteWeek());
        }
      } catch (e) {
        emit(PlantError("Günlük ilerleme hatası: $e"));
      }
    });

    on<UpdatePlantStage>((event, emit) async {
       emit(PlantLoaded(event.newStage)); 
       try {
         await _repository.updatePlantStage(event.newStage);
         add(LoadPlantStage()); 
       } catch (e) {
         emit(PlantError("Failed to update plant: $e"));
       }
    });

    on<LoadPlantHistory>((event, emit) async {
      emit(PlantLoading());
      try {
        final history = await _repository.getPlantHistory();
        emit(PlantHistoryLoaded(history));
      } catch (e) {
        emit(PlantError("Failed to load history: $e"));
      }
    });

    on<CompleteWeek>((event, emit) async {
      emit(PlantLoading());
      try {
         final currentStatus = await _repository.getCurrentPlantStage();
         
         await _repository.archiveAndResetWeek(currentStatus.stage);

         emit(PlantWeekArchived(currentStatus.stage));
         
         emit(const PlantLoaded(PlantStage.seed));
         
         add(LoadPlantHistory());
      } catch (e) {
        emit(PlantError("Failed to reset week: $e"));
      }
    });

    on<UpdateCycleNote>((event, emit) async {
       try {
         await _repository.updateCycleNote(event.cycleId, event.note);
         add(LoadPlantHistory());
       } catch (e) {
         print("Failed to save note: $e");
       }
    });

    on<ClearPlantData>((event, emit) {
      emit(PlantInitial());
    });
  }
}
