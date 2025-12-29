import '../entities/habit.dart';

abstract class PlannerRepository {
  Future<List<Habit>> getHabitsForDate(DateTime date);
  Future<void> addHabit(String title, DateTime date);
  Future<void> toggleHabitCompletion(String habitId, bool isCompleted);
  Future<void> deleteHabit(String habitId);
}
