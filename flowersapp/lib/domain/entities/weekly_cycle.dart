import 'plant_stage.dart';

class WeeklyCycle {
  final String id;
  final String userId;
  final DateTime startDate;
  final DateTime? endDate;
  final PlantStage status;
  final String? note;

  const WeeklyCycle({
    required this.id,
    required this.userId,
    required this.startDate,
    this.endDate,
    required this.status,
    this.note,
  });
}
