import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../presentation/bloc/plant_bloc.dart';
import '../../presentation/widgets/badge_card.dart';
import '../../presentation/widgets/flower_history_card.dart';
import '../../domain/entities/plant_stage.dart';

class SuccessGardenPage extends StatefulWidget {
  const SuccessGardenPage({super.key});

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
        title: const Text("Success Garden"),
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
            final flowers = state.history;
            final badgeCycles = state.history
                .where((cycle) =>
                    cycle.status == PlantStage.growth ||
                    cycle.status == PlantStage.growth_second ||
                    cycle.status == PlantStage.bud ||
                    cycle.status == PlantStage.flower)
                .toList();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CustomScrollView(
                slivers: [
                  // --- Çiçekler Başlığı ---
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.local_florist, color: AppColors.primaryText),
                          const SizedBox(width: 8),
                          Text(
                            "Çiçek Koleksiyonum (${flowers.length})",
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
                  flowers.isEmpty
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
                              final flower = flowers[index];
                              // Performans için Key ekledik
                              return FlowerHistoryCard(
                                key: ValueKey(flower.id), 
                                cycle: flower
                              );
                            },
                            childCount: flowers.length,
                          ),
                        ),

                  // --- Rozetler Başlığı ---
                   SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 32.0, bottom: 16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.emoji_events, color: AppColors.primaryText),
                          const SizedBox(width: 8),
                          Text(
                            "Rozetlerim (${badgeCycles.length})",
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
                               String title = "Perseverance";
                               String desc = "Great effort!";
                               IconData icon = Icons.spa;

                               if (cycle.status == PlantStage.flower) {
                                 title = "Master";
                                 desc = "Fully Bloomed!";
                                 icon = Icons.local_florist;
                               }
                              
                              return BadgeCard(
                                key: ValueKey("badge_${cycle.id}"), // Rozetlere de key ekledik
                                title: title,
                                description: desc,
                                dateEarned: cycle.endDate ?? cycle.startDate,
                                icon: icon,
                                cycleId: cycle.id,
                                initialNote: cycle.note,
                              );
                            },
                            childCount: badgeCycles.length,
                          ),
                        ),
                  
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



