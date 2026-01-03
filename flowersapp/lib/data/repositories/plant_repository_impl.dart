import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/plant_stage.dart';
import '../../domain/entities/weekly_cycle.dart';
import '../../domain/repositories/plant_repository.dart';

class PlantRepositoryImpl implements PlantRepository {
  final SupabaseClient _supabase;

  PlantRepositoryImpl(this._supabase);

  @override
  Future<PlantGrowthStatus> getCurrentPlantStage() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return const PlantGrowthStatus(stage: PlantStage.seed, isGrowthHalted: false);

      final response = await _supabase
          .from('daily_habits')
          .select('day_of_week, is_completed')
          .eq('user_id', userId);

      final habits = response as List<dynamic>;

      final Map<int, List<Map<String, dynamic>>> habitsByDay = {};
      for (var h in habits) {
        final day = h['day_of_week'] as int;
        if (!habitsByDay.containsKey(day)) habitsByDay[day] = [];
        habitsByDay[day]!.add(h as Map<String, dynamic>);
      }

      int completedDays = 0;
      bool isGrowthHalted = false;
      final currentWeekday = DateTime.now().weekday;

      for (int day = 1; day <= 7; day++) {
        if (day > currentWeekday) break;

        final dayHabits = habitsByDay[day] ?? [];
        bool dayComplete = false;
        
        if (dayHabits.isNotEmpty) {
          dayComplete = dayHabits.every((h) => h['is_completed'] == true);
        } else {
          dayComplete = true; 
        }

        print('Checking Day $day. CurrentWeekday: $currentWeekday. DayComplete: $dayComplete');
        
        if (day < currentWeekday) {
           if (!dayComplete) {
             isGrowthHalted = true;
             break;
           } else {
             if (dayHabits.isNotEmpty) {
               completedDays++;
             }
           }
        } else if (day == currentWeekday) {
           if (dayHabits.isNotEmpty && dayComplete) {
             completedDays++;
           }
        }
      }

      PlantStage stage;
      if (completedDays >= 6) {
        stage = PlantStage.flower;
      } else {
        switch (completedDays) {
          case 5: stage = PlantStage.bud; break;
          case 4: stage = PlantStage.growth_second; break;
          case 3: stage = PlantStage.growth; break;
          case 2: stage = PlantStage.seedling; break;
          case 1: stage = PlantStage.germination; break;
          case 0:
          default:
            stage = PlantStage.seed;
        }
      }
      
      return PlantGrowthStatus(stage: stage, isGrowthHalted: isGrowthHalted);

    } catch (e) {
      print('Error calculating plant stage: $e');
      return const PlantGrowthStatus(stage: PlantStage.seed, isGrowthHalted: false);
    }
  }

  @override
  Future<void> updatePlantStage(PlantStage stage) async {
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
          note: json['note'] as String?,
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
         finalStatusStr = finalStage.toString().split('.').last;
         if (finalStatusStr == 'flower') finalStatusStr = 'perseverance_badge';
      }
      
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
      });

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
