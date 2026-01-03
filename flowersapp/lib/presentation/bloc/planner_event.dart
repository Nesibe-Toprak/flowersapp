import 'package:equatable/equatable.dart';

abstract class PlannerEvent extends Equatable {
  const PlannerEvent();

  @override
  List<Object> get props => [];
}

class PlannerLoadHabits extends PlannerEvent {
  final DateTime date;
  final bool showLoading;

  const PlannerLoadHabits(this.date, {this.showLoading = true});

  @override
  List<Object> get props => [date, showLoading];
}

class PlannerAddHabit extends PlannerEvent {
  final String title;
  final DateTime date;

  const PlannerAddHabit(this.title, this.date);

  @override
  List<Object> get props => [title, date];
}

class PlannerToggleHabit extends PlannerEvent {
  final String habitId;
  final bool isCompleted;

  const PlannerToggleHabit(this.habitId, this.isCompleted);

  @override
  List<Object> get props => [habitId, isCompleted];
}

class PlannerDeleteHabit extends PlannerEvent {
  final String habitId;

  const PlannerDeleteHabit(this.habitId);

  @override
  List<Object> get props => [habitId];
}
