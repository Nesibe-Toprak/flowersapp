enum PlantStage {
  seed,
  sprout,
  plant,
  bud,
  flower,
  withered // For broken chain
}

extension PlantStageExtension on PlantStage {
  String get name {
    switch (this) {
      case PlantStage.seed: return 'Seed';
      case PlantStage.sprout: return 'Sprout';
      case PlantStage.plant: return 'Plant';
      case PlantStage.bud: return 'Bud';
      case PlantStage.flower: return 'Flower';
      case PlantStage.withered: return 'Withered';
    }
  }

  // Helper to map from string (DB)
  static PlantStage fromString(String val) {
    return PlantStage.values.firstWhere(
      (e) => e.toString().split('.').last == val,
      orElse: () => PlantStage.seed,
    );
  }
}
