import 'package:equatable/equatable.dart';
import '../../domain/entities/habit.dart';

abstract class PlannerState extends Equatable {
  const PlannerState();
  
  @override
  List<Object> get props => [];
}

class PlannerInitial extends PlannerState {}

class PlannerLoading extends PlannerState {}

class PlannerLoaded extends PlannerState {
  final List<Habit> habits;
  final DateTime selectedDate;

  const PlannerLoaded(this.habits, this.selectedDate);

  @override
  List<Object> get props => [habits, selectedDate];
}

class PlannerError extends PlannerState {
  final String message;

  const PlannerError(this.message);

  @override
  List<Object> get props => [message];
}
