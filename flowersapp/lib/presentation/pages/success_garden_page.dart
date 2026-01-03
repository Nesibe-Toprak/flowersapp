import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../presentation/bloc/plant_bloc.dart';
import '../../presentation/widgets/badge_card.dart';
import '../../presentation/widgets/flower_history_card.dart';
import '../../domain/entities/plant_stage.dart';

enum GardenViewMode { flowers, badges }

class SuccessGardenPage extends StatefulWidget {
  final GardenViewMode mode;

  const SuccessGardenPage({super.key, required this.mode});

  @override
  State<SuccessGardenPage> createState() => _SuccessGardenPageState();
}

class _SuccessGardenPageState extends State<SuccessGardenPage> {
  @override
  void initState() {
    super.initState();
    context.read<PlantBloc>().add(LoadPlantHistory());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accentPink,
      appBar: AppBar(
        title: Text(widget.mode == GardenViewMode.flowers ? "Başarı Bahçem 🏆" : "Rozetlerim 🥇"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
            color: AppColors.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: AppColors.primaryText),
      ),
      body: BlocBuilder<PlantBloc, PlantState>(
        builder: (context, state) {
          if (state is PlantLoading) {
            return const Center(child: CircularProgressIndicator());
          } 
          else if (state is PlantHistoryLoaded) {
            // Filter flowers: Show everything EXCEPT perseverance badge
            final displayedFlowers = state.history
                .where((cycle) => cycle.status != PlantStage.perseverance_badge)
                .toList();

            // Filter badges: Show ONLY Perseverance Badge (Flowers are in Garden tab)
            final badgeCycles = state.history
                .where((cycle) =>
                    cycle.status == PlantStage.perseverance_badge)
                .toList();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CustomScrollView(
                slivers: [
                  if (widget.mode == GardenViewMode.flowers) ...[
                      // --- Çiçekler Başlığı ---
                      // ... (unchanged)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Row(
                            children: [

                              Text(
                                "Çiçeklerim 🌸 (${displayedFlowers.length})",
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: AppColors.primaryText,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // --- Çiçekler Izgarası (Grid) ---
                      displayedFlowers.isEmpty
                          ? SliverToBoxAdapter(
                              child: Container(
                                height: 100,
                                alignment: Alignment.center,
                                child: const Text("Henüz bir çiçeğiniz yok. Büyütmeye başlayın!"),
                              ),
                            )
                          : SliverGrid(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3, 
                                childAspectRatio: 0.8,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final flower = displayedFlowers[index];
                                  return FlowerHistoryCard(
                                    key: ValueKey(flower.id), 
                                    cycle: flower
                                  );
                                },
                                childCount: displayedFlowers.length,
                              ),
                            ),
                  ],

                  if (widget.mode == GardenViewMode.badges) ...[
                      // --- Rozetler Başlığı ---
                       SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Row(
                            children: [
                              Text(
                                "Rozetlerim 🥇 (${badgeCycles.length})",
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: AppColors.primaryText,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // --- Rozetler Izgarası (Grid) ---
                      badgeCycles.isEmpty
                          ? SliverToBoxAdapter(
                              child: Container(
                                height: 100,
                                alignment: Alignment.center,
                                child: const Text("Rozet kazanmak için hedeflerinizi tamamlayın!"),
                              ),
                            )
                          : SliverGrid(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 0.8,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final cycle = badgeCycles[index];
                                   String title = "";
                                   String desc = "";
                                   IconData icon = Icons.spa;
                                   String? assetPath;

                                   if (cycle.status == PlantStage.perseverance_badge) {
                                      title = "Başarı Rozeti";
                                      desc = "Pes etmedin, başardın! Harika bir geri dönüş.";
                                      icon = Icons.verified;
                                      assetPath = 'assets/images/icon_badge.png';
                                   }
                                  
                                  return BadgeCard(
                                    key: ValueKey("badge_${cycle.id}"), 
                                    title: title,
                                    description: desc,
                                    dateEarned: cycle.endDate ?? cycle.startDate,
                                    icon: icon,
                                    assetPath: assetPath, 
                                    cycleId: cycle.id,
                                    initialNote: cycle.note,
                                    emoji: '🥇', 
                                  );
                                },
                                childCount: badgeCycles.length,
                              ),
                            ),
                  ],
                  
                  // Alt boşluk
                  const SliverToBoxAdapter(child: SizedBox(height: 50)),
                ],
              ),
            );
          } else if (state is PlantError) {
            return Center(child: Text("Hata: ${state.message}"));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}



