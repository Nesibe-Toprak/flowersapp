import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../presentation/bloc/planner_bloc.dart';
import '../../presentation/bloc/planner_event.dart';
import '../../presentation/bloc/planner_state.dart';
import '../../presentation/bloc/plant_bloc.dart'; // Contains Plant logic
import '../../domain/entities/plant_stage.dart';
import '../../presentation/widgets/tema_donation_dialog.dart';

import 'success_garden_page.dart';
import 'profile_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        title: const Text("EcoPlan"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: AppColors.darkGrey,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_edu, color: AppColors.darkGrey),
            tooltip: 'Success Garden',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SuccessGardenPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: AppColors.darkGrey),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<PlannerBloc, PlannerState>(
          listener: (context, state) {
            if (state is PlannerError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
            // Gamification Logic: Calculate growth upon habit updates
            if (state is PlannerLoaded) {
               if (state.habits.isEmpty) return;
               
               final completedCount = state.habits.where((h) => h.isCompleted).length;
               final total = state.habits.length;
               final percentage = completedCount / total;
               
               PlantStage newStage = PlantStage.seed;
               if (percentage > 0.8) {
                 newStage = PlantStage.flower;
               } else if (percentage > 0.5) {
                 newStage = PlantStage.plant;
               } else if (percentage > 0.2) {
                 newStage = PlantStage.sprout;
               } else {
                 newStage = PlantStage.seed;
               }
               
               // Dispatch update to PlantBloc
               // access via context.read
               context.read<PlantBloc>().add(UpdatePlantStage(newStage));
               
               // Show Donation Dialog if bloom
               if (newStage == PlantStage.flower) {
                  // Small delay to let the UI update first
                  Future.delayed(const Duration(seconds: 1), () {
                     if (context.mounted) {
                       showDialog(
                         context: context, 
                         builder: (_) => const TemaDonationDialog(),
                       );
                     }
                  });
               }
            }
          },
          builder: (context, plannerState) {
            return Column(
              children: [
                // 1. Plant Area (40%)
                Expanded(
                  flex: 40,
                  child: Container(
                    width: double.infinity,
                    color: AppColors.backgroundBeige,
                    child: BlocBuilder<PlantBloc, PlantState>(
                      builder: (context, plantState) {
                         String stageName = 'Seed';
                         if (plantState is PlantLoaded) {
                           stageName = plantState.stage.toString().split('.').last; 
                           // Capitalize first letter
                           stageName = stageName[0].toUpperCase() + stageName.substring(1);
                         }

                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildPlantIcon(plantState),
                              const SizedBox(height: 16),
                              Text(
                                'Day ${(plannerState is PlannerLoaded) ? plannerState.selectedDate.weekday : DateTime.now().weekday}: $stageName',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: AppColors.darkGrey,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // 2. Weekly Calendar (15%) - Placeholder
                 Expanded(
                  flex: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(7, (index) {
                        final now = DateTime.now();
                        // Calculate Monday of the current week
                        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
                        final date = startOfWeek.add(Duration(days: index));
                        
                        final selectedDate = (plannerState is PlannerLoaded) 
                            ? plannerState.selectedDate 
                            : DateTime.now();

                        return _buildDayBox(context, date, selectedDate);  
                      }),
                    ),
                  ),
                ),

                // 3. Habits / Planner Area (45%)
                Expanded(
                  flex: 45,
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Today's Goals",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkGrey,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: plannerState is PlannerLoading
                                ? const Center(child: CircularProgressIndicator())
                                : plannerState is PlannerLoaded
                                    ? ListView.builder(
                                        itemCount: plannerState.habits.length,
                                        itemBuilder: (context, index) {
                                          final habit = plannerState.habits[index];
                                          return _buildHabitItem(context, habit);
                                        },
                                      )
                                    : const Center(child: Text("No habits yet.")),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHabitDialog(context),
        backgroundColor: AppColors.accentPink,
        child: const Icon(Icons.add, color: AppColors.darkGrey),
      ),
    );
  }

  Widget _buildDayBox(BuildContext context, DateTime date, DateTime selectedDate) {
    final isSelected = date.year == selectedDate.year && 
                       date.month == selectedDate.month && 
                       date.day == selectedDate.day;
    
    final dayLabel = ['M', 'T', 'W', 'T', 'F', 'S', 'S'][date.weekday - 1];
    
    return GestureDetector(
      onTap: () {
        context.read<PlannerBloc>().add(PlannerLoadHabits(date));
      },
      child: Container(
        width: 44, // Slightly wider to fit day number
        height: 60, // Taller for two lines of text
        decoration: BoxDecoration(
          color: isSelected ? AppColors.creamPeach : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.accentPink : AppColors.darkGrey.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12), // Softer corners
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.accentPink.withOpacity(0.4),
                    blurRadius: 8,
                  )
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: AppColors.darkGrey.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: AppColors.darkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitItem(BuildContext context, habit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: habit.isCompleted ? AppColors.sageGreen.withOpacity(0.5) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Custom Checkbox
          GestureDetector(
            onTap: () {
              context.read<PlannerBloc>().add(
                PlannerToggleHabit(habit.id, !habit.isCompleted),
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: habit.isCompleted ? AppColors.sageGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: habit.isCompleted ? AppColors.sageGreen : AppColors.darkGrey.withOpacity(0.4),
                  width: 2,
                ),
              ),
              child: habit.isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              habit.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                decoration: habit.isCompleted ? TextDecoration.lineThrough : null,
                color: habit.isCompleted ? AppColors.darkGrey.withOpacity(0.5) : AppColors.darkGrey,
              ),
            ),
          ),
           IconButton(
            icon: Icon(Icons.delete_outline, color: AppColors.accentPink.withOpacity(0.8)),
            onPressed: () {
               context.read<PlannerBloc>().add(PlannerDeleteHabit(habit.id));
            },
          )
        ],
      ),
    );
  }

  Widget _buildPlantIcon(PlantState state) {
    IconData icon;
    Color color;
    double size = 120;

    if (state is PlantLoaded) {
      switch (state.stage) {
        case PlantStage.seed:
          icon = Icons.grain;
          color = Colors.brown;
          size = 80; // Seeds are small
          break;
        case PlantStage.sprout:
          icon = Icons.eco;
          color = AppColors.sageGreen;
          size = 100;
          break;
        case PlantStage.plant:
          icon = Icons.local_florist;
          color = Colors.green;
          size = 120;
          break;
        case PlantStage.flower:
          icon = Icons.filter_vintage;
          color = AppColors.accentPink;
          size = 140; // Big bloom
          break;
        default:
           icon = Icons.grain;
           color = Colors.brown;
      }
    } else {
      icon = Icons.grain;
      color = Colors.grey;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      child: Icon(
        icon,
        size: size,
        color: color,
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Goal"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter goal title"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              // Note: using context.read here works because Dialog context 
              // is usually a child of the main app context. 
              // If not, we'd need to pass the bloc.
              // For now assuming safe.
              if (controller.text.isNotEmpty) {
                 // We need to access the bloc from the PARENT context or provided context
              }
              Navigator.pop(context, controller.text);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    ).then((value) {
      if (value != null && value is String && value.isNotEmpty) {
         final selectedDate = (context.read<PlannerBloc>().state is PlannerLoaded)
             ? (context.read<PlannerBloc>().state as PlannerLoaded).selectedDate
             : DateTime.now();
         context.read<PlannerBloc>().add(PlannerAddHabit(value, selectedDate));
      }
    });
  }
}
