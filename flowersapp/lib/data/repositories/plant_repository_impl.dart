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

      // Check strictly from Day 1 upwards
      for (int day = 1; day <= 7; day++) {
        // If we are looking at a future day, stop checking
        if (day > currentWeekday) break;

        final dayHabits = habitsByDay[day] ?? [];
        bool dayComplete = false;
        
        if (dayHabits.isNotEmpty) {
          dayComplete = dayHabits.every((h) => h['is_completed'] == true);
        } else {
          // If no habits for the day, consider it complete? 
          // Or incomplete? Usually incomplete implies 'failed to do habits'.
          // If no habits planned, maybe success?
          // For now, let's assume 'no habits' = 'incomplete' if strict, OR 'complete' if lenient.
          // Given "Salı günü hedeflediklerimin tümüne uymazsam", implies there ARE habits.
          // Let's assume if no habits exist for a past day, it might be missed.
          // BUT, to be safe, treat 'no habits' as 'nothing to do' -> incomplete for growth purposes?
          // Let's assume dayComplete = false if empty.
          dayComplete = false; 
        }

        if (day < currentWeekday) {
           // Past day
           if (!dayComplete) {
             isGrowthHalted = true;
             // Stop counting further growth
             break;
           } else {
             completedDays++;
           }
        } else if (day == currentWeekday) {
          // Today
          if (dayComplete) {
            completedDays++;
          }
          // If today is incomplete, it's not 'halted' yet, effectively just 'not grown yet today'.
        }
      }

      // Map completed days to PlantStage (0 to 7)
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

      // Calculate Badge Eligibility
      // A badge is earned if successDays > failedDays at end of week.
      // We check if it is still POSSIBLE to achieve this.
      int failedDays = 0;
      for (int day = 1; day < currentWeekday; day++) {
         if ((habitsByDay[day] ?? []).every((h) => h['is_completed'] == true) == false) {
           failedDays++;
         }
      }
      // If today is incomplete, we don't count it as failed yet for potential calculation, 
      // but we do know we haven't succeeded yet.
      // Actually 'isGrowthHalted' means we failed a past day or failed today?
      // Existing logic:
      // if (day < currentWeekday && !dayComplete) -> halted.
      
      // Let's count max potential successes.
      // Max Success = Current Successes + Remaining Days (including today if not done yet? No, today is halted if checked and failed?)
      // Actually, if we are 'halted', it means we failed a scan.
      // Let's count explicitly:
      int potentialSuccesses = 0;
      int currentFailures = 0;

      for (int day = 1; day <= 7; day++) {
        bool dayComplete = false;
        final dayHabits = habitsByDay[day] ?? [];
        if (dayHabits.isNotEmpty) {
           dayComplete = dayHabits.every((h) => h['is_completed'] == true);
        }

        if (day < currentWeekday) {
           if (dayComplete) potentialSuccesses++; 
           else currentFailures++;
        } else if (day == currentWeekday) {
           // We can still succeed today if not already successful?
           // If we are halted, it means we failed a past day.
           // For today, if we are halted, we can still fix today? 
           // Usually halted refers to "growth halted due to past failure".
           // But let's assume "remaining days" includes today.
           potentialSuccesses++; 
        } else {
           // Future
           potentialSuccesses++;
        }
      }
      
      // Badge Condition: Success > Failure
      // So if (potentialSuccesses > currentFailures), we can still earn it?
      // Wait, Total Days = 7.
      // If I fail 3 days, I can get 4 successes -> Badge.
      // If I fail 4 days, max success 3 -> No Badge.
      // So constraint is: failures < 4.
      bool canEarnBadge = currentFailures < 4;

      return PlantGrowthStatus(
        stage: stage, 
        isGrowthHalted: isGrowthHalted,
        canEarnBadge: canEarnBadge,
      );

    } catch (e) {
      print('Error calculating plant stage: $e');
      return const PlantGrowthStatus(
        stage: PlantStage.seed, 
        isGrowthHalted: false,
        canEarnBadge: true, // Default to true or false? True allows hope.
      );
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
