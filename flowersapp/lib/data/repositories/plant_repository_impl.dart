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

      // Ideally fetch from 'weekly_cycles' where user_id = userId AND date is current week.
      // For MVP without managing cycles strictly, we could store it in profiles or a 'current_status' table.
      // Or we just query the latest weekly_cycle.
      
      // Attempt to query weekly_cycles
      final response = await _supabase
          .from('weekly_cycles')
          .select('status')
          .eq('user_id', userId)
          .order('start_date', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return PlantStage.seed;
      
      final statusStr = response['status'] as String;
      return PlantStageExtension.fromString(statusStr);
    } catch (e) {
      return PlantStage.seed;
    }
  }

  @override
  Future<void> updatePlantStage(PlantStage stage) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Update the latest cycle's status
      // We first find the ID of the latest cycle
      final latestCycle = await _supabase
          .from('weekly_cycles')
          .select('id')
          .eq('user_id', userId)
          .order('start_date', ascending: false)
          .limit(1)
          .maybeSingle();

      if (latestCycle != null) {
        final cycleId = latestCycle['id'];
        await _supabase.from('weekly_cycles').update({
          'status': stage.toString().split('.').last, // Extract 'seed', 'sprout' etc.
        }).eq('id', cycleId);
      } else {
        // Option: Create a new cycle if none exists? 
        // For now, simpler to just log that we couldn't find a cycle to update.
        print('No active cycle found to update plant stage.');
      }
    } catch (e) {
      print('Error updating plant stage: $e');
    }
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
}
