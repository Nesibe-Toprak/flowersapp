import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/planner_repository.dart';
import 'planner_event.dart';
import 'planner_state.dart';

class PlannerBloc extends Bloc<PlannerEvent, PlannerState> {
  final PlannerRepository _repository;

  PlannerBloc(this._repository) : super(PlannerInitial()) {
    on<PlannerLoadHabits>(_onLoadHabits);
    on<PlannerAddHabit>(_onAddHabit);
    on<PlannerToggleHabit>(_onToggleHabit);
    on<PlannerDeleteHabit>(_onDeleteHabit);
  }

  void _onLoadHabits(PlannerLoadHabits event, Emitter<PlannerState> emit) async {
    if (event.showLoading) {
      emit(PlannerLoading());
    }
    try {
      final habits = await _repository.getHabitsForDate(event.date);
      emit(PlannerLoaded(habits, event.date));
    } catch (e) {
      emit(PlannerError(e.toString()));
    }
  }

  void _onAddHabit(PlannerAddHabit event, Emitter<PlannerState> emit) async {
    try {
      await _repository.addHabit(event.title, event.date);
      add(PlannerLoadHabits(event.date, showLoading: false));
    } catch (e) {
      emit(PlannerError(e.toString()));
    }
  }

  void _onToggleHabit(PlannerToggleHabit event, Emitter<PlannerState> emit) async {
     try {
       await _repository.toggleHabitCompletion(event.habitId, event.isCompleted);
       if (state is PlannerLoaded) {
          add(PlannerLoadHabits((state as PlannerLoaded).selectedDate, showLoading: false));
       }
     } catch (e) {
       emit(PlannerError(e.toString()));
     }
  }

  void _onDeleteHabit(PlannerDeleteHabit event, Emitter<PlannerState> emit) async {
    try {
      await _repository.deleteHabit(event.habitId);
       if (state is PlannerLoaded) {
          add(PlannerLoadHabits((state as PlannerLoaded).selectedDate, showLoading: false));
       }
    } catch (e) {
      emit(PlannerError(e.toString()));
    }
  }
}
