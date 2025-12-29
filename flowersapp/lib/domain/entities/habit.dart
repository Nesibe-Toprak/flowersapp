import 'package:equatable/equatable.dart';

class Habit extends Equatable {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime? completedAt;
  final int dayOfWeek;

  const Habit({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.completedAt,
    required this.dayOfWeek,
  });

  @override
  List<Object?> get props => [id, title, isCompleted, completedAt, dayOfWeek];
}
