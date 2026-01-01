import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/plant_stage.dart';
import '../../domain/entities/weekly_cycle.dart';
import '../../domain/repositories/plant_repository.dart';

class PlantRepositoryImpl implements PlantRepository {
  final SupabaseClient _supabase;

  PlantRepositoryImpl(this._supabase);

  @override
  Future<PlantStage> getCurrentPlantStage() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return PlantStage.seed;

      // Fetch all daily habits for the user
      // Assuming 'daily_habits' table represents the current active week's habits.
      final response = await _supabase
          .from('daily_habits')
          .select('day_of_week, is_completed')
          .eq('user_id', userId);

      final habits = response as List<dynamic>;

      // Group habits by day_of_week (1..7)
      final Map<int, List<Map<String, dynamic>>> habitsByDay = {};
      for (var h in habits) {
        final day = h['day_of_week'] as int;
        if (!habitsByDay.containsKey(day)) habitsByDay[day] = [];
        habitsByDay[day]!.add(h as Map<String, dynamic>);
      }

      int completedDays = 0;
      // We only count days that actually have habits scheduled.
      // If a day has NO habits, it doesn't contribute to growth (or penalty).
      habitsByDay.forEach((day, dayHabits) {
        if (dayHabits.isNotEmpty) {
          final allDone = dayHabits.every((h) => h['is_completed'] == true);
          if (allDone) {
            completedDays++;
          }
        }
      });

      // Map completed days to PlantStage (0 to 7)
      // 0 days -> Seed
      // 1 day  -> Germination
      // 2 days -> Seedling
      // 3 days -> Growth
      // 4 days -> Bud
      // 5 days -> Growth (Second phase)
      // 6-7 days -> Flower
      
      if (completedDays >= 7) return PlantStage.flower;
      switch (completedDays) {
        case 6: return PlantStage.bud;
        case 5: return PlantStage.growth_second;
        case 4: return PlantStage.growth;
        case 3: return PlantStage.seedling;
        case 2: return PlantStage.germination;
        case 1: 
        case 0:
        default:
          return PlantStage.seed;
      }
    } catch (e) {
      print('Error calculating plant stage: $e');
      return PlantStage.seed;
    }
  }

  @override
  Future<void> updatePlantStage(PlantStage stage) async {
    // Stage is now calculated dynamically from habits.
    // We do not manually update it anymore.
    // We could log this or maybe update a cache in 'weekly_cycles' if needed.
    print('updatePlantStage called but stage is dynamic. Ignoring.');
  }

  @override
  Future<List<WeeklyCycle>> getPlantHistory() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('weekly_cycles')
          .select()
          .eq('user_id', userId)
          .order('start_date', ascending: false);

      final data = response as List<dynamic>;
      return data.map((json) {
        return WeeklyCycle(
          id: json['id'] as String,
          userId: json['user_id'] as String,
          startDate: DateTime.parse(json['start_date'] as String),
          endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
          status: PlantStageExtension.fromString(json['status'] as String),
          note: json['note'] as String?, // Assuming 'note' column exists or ignore
        );
      }).toList();
    } catch (e) {
      print('Error fetching plant history: $e');
      return [];
    }
  }
  @override
  Future<void> archiveAndResetWeek(PlantStage finalStage) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // 1. Calculate final status based on history
      final habitsResponse = await _supabase
          .from('daily_habits')
          .select('day_of_week, is_completed')
          .eq('user_id', userId);

      final habits = habitsResponse as List<dynamic>;
      final Map<int, List<Map<String, dynamic>>> habitsByDay = {};
      for (var h in habits) {
        final day = h['day_of_week'] as int;
        if (!habitsByDay.containsKey(day)) habitsByDay[day] = [];
        habitsByDay[day]!.add(h as Map<String, dynamic>);
      }

      int successDays = 0;
      int failedDays = 0;
      int totalActiveDays = 0;

      habitsByDay.forEach((day, dayHabits) {
        if (dayHabits.isNotEmpty) {
          totalActiveDays++;
          final allDone = dayHabits.every((h) => h['is_completed'] == true);
          if (allDone) {
            successDays++;
          } else {
            failedDays++;
          }
        }
      });

      String finalStatusStr = 'seed';
      if (successDays == 7) {
        finalStatusStr = 'flower';
      } else if (successDays > failedDays) {
        finalStatusStr = 'perseverance_badge';
      } else {
        // Fallback to calculated stage or just seed
         finalStatusStr = finalStage.toString().split('.').last;
         if (finalStatusStr == 'flower') finalStatusStr = 'perseverance_badge'; // Handle edge case where input was flower but days < 7 (unlikely)
      }
      
      // If original logic said flower (7 days) but we found otherwise, trust calculation.
      // Actually simpler:
      if (successDays == 7) {
        finalStatusStr = 'flower';
      } else if (successDays > failedDays) {
        finalStatusStr = 'perseverance_badge';
      } else {
        finalStatusStr = 'seed';
      }

      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 6));

      await _supabase.from('weekly_cycles').insert({
        'user_id': userId,
        'start_date': startDate.toIso8601String(),
        'end_date': now.toIso8601String(),
        'status': finalStatusStr,
        // 'note': 'Weekly Goal Reached!' 
      });

      // 2. Clear daily habits for a fresh start
      await _supabase
          .from('daily_habits')
          .delete()
          .eq('user_id', userId);
          
    } catch (e) {
      print('Error archiving and resetting week: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateCycleNote(String cycleId, String note) async {
    try {
      await _supabase
          .from('weekly_cycles')
          .update({'note': note})
          .eq('id', cycleId);
    } catch (e) {
      print('Error updating note: $e');
      rethrow;
    }
  }
}
