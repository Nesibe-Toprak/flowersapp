enum PlantStage {
  seed,
  germination,
  seedling,
  growth,
  bud,
  growth_second,
  flower
}

extension PlantStageExtension on PlantStage {
  String get name {
    switch (this) {
      case PlantStage.seed: return 'Tohum';
      case PlantStage.germination: return 'Çimlenme';
      case PlantStage.seedling: return 'Fide';
      case PlantStage.growth: return 'Büyüme';
      case PlantStage.bud: return 'Tomurcuk';
      case PlantStage.growth_second: return 'Büyüme';
      case PlantStage.flower: return 'Çiçek';
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
