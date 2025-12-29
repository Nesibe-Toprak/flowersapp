import '../entities/plant_stage.dart';
import '../entities/weekly_cycle.dart';

abstract class PlantRepository {
  Future<PlantStage> getCurrentPlantStage();
  Future<void> updatePlantStage(PlantStage stage);
  Future<List<WeeklyCycle>> getPlantHistory();
}
