import '../entities/plant_stage.dart';
import '../entities/weekly_cycle.dart';

class PlantGrowthStatus {
  final PlantStage stage;
  final bool isGrowthHalted;

  const PlantGrowthStatus({required this.stage, required this.isGrowthHalted});
}

abstract class PlantRepository {
  Future<PlantGrowthStatus> getCurrentPlantStage();
  Future<void> updatePlantStage(PlantStage stage);
  Future<List<WeeklyCycle>> getPlantHistory();
  Future<void> archiveAndResetWeek(PlantStage finalStage);
  Future<void> updateCycleNote(String cycleId, String note);
}
