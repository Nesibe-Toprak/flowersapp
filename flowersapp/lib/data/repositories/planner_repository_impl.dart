import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/habit.dart';
import '../../domain/repositories/planner_repository.dart';
import '../models/habit_model.dart';

class PlannerRepositoryImpl implements PlannerRepository {
  final SupabaseClient _supabase;

  PlannerRepositoryImpl(this._supabase);

  @override
  Future<List<Habit>> getHabitsForDate(DateTime date) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      // Note: In a full implementation, we should filter by the correct weekly_cycle_id too.
      // For now, we fetch all habits for this day of week.
      final dayOfWeek = date.weekday; 

      final response = await _supabase
          .from('daily_habits')
          .select()
          .eq('day_of_week', dayOfWeek);
      
      final data = response as List<dynamic>;
      return data.map((json) => HabitModel.fromJson(json)).toList();
    } catch (e) {
      // Log error (in a real app, use a logger)
      print('Error fetching habits: $e');
      return []; 
    }
  }

  @override
  Future<void> addHabit(String title, DateTime date) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');
      
      // For MVP: We are inserting without a cycle_id if it's nullable, 
      // or assuming the backend triggers might handle it.
      // If cycle_id is required, this needs to fetch/create a cycle first.
      
      await _supabase.from('daily_habits').insert({
        'id': const Uuid().v4(),
        'user_id': userId,
        'title': title,
        'day_of_week': date.weekday,
        'is_completed': false,
        // 'cycle_id': ... // TODO: Implement cycle management
      });
    } catch (e) {
       print('Error adding habit: $e');
       rethrow;
    }
  }

  @override
  Future<void> toggleHabitCompletion(String habitId, bool isCompleted) async {
    try {
      await _supabase.from('daily_habits').update({
        'is_completed': isCompleted,
        'completed_at': isCompleted ? DateTime.now().toIso8601String() : null,
      }).eq('id', habitId);
    } catch (e) {
       print('Error toggling habit: $e');
    }
  }

  @override
  Future<void> deleteHabit(String habitId) async {
    try {
      await _supabase.from('daily_habits').delete().eq('id', habitId);
    } catch (e) {
      print('Error deleting habit: $e');
    }
  }
}
