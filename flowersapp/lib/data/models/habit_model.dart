import '../../domain/entities/habit.dart';

class HabitModel extends Habit {
  const HabitModel({
    required super.id,
    required super.title,
    super.isCompleted,
    super.completedAt,
    required super.dayOfWeek,
  });

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['is_completed'] as bool? ?? false,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      dayOfWeek: json['day_of_week'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
      'day_of_week': dayOfWeek,
    };
  }
}
