enum PlantStage {
  seed,
  germination,
  seedling,
  growth,
  growth_second,
  bud,
  flower,
  perseverance_badge
}

extension PlantStageExtension on PlantStage {
  String get name {
    switch (this) {
      case PlantStage.seed: return 'Tohum';
      case PlantStage.germination: return 'Çimlenme';
      case PlantStage.seedling: return 'Fide';
      case PlantStage.growth: return 'Büyüme';
      case PlantStage.growth_second: return 'Büyüme';
      case PlantStage.bud: return 'Tomurcuk';
      case PlantStage.flower: return 'Çiçek';
      case PlantStage.perseverance_badge: return 'Azim Rozeti';
    }
  }

  static PlantStage fromString(String val) {
    return PlantStage.values.firstWhere(
      (e) => e.toString().split('.').last == val,
      orElse: () => PlantStage.seed,
    );
  }
}
