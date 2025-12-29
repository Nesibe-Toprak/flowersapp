import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../presentation/bloc/plant_bloc.dart';
import '../../presentation/widgets/flower_history_card.dart';

class SuccessGardenPage extends StatelessWidget {
  const SuccessGardenPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Trigger load when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlantBloc>().add(LoadPlantHistory());
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        title: const Text("Success Garden"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: AppColors.darkGrey,
          fontSize: 20,
          fontWeight: FontWeight.bold
        ),
        iconTheme: const IconThemeData(color: AppColors.darkGrey),
      ),
      body: BlocBuilder<PlantBloc, PlantState>(
        builder: (context, state) {
          if (state is PlantLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PlantHistoryLoaded) {
            final history = state.history;
            if (history.isEmpty) {
              return const Center(
                child: Text("Your garden is waiting for your first bloom!"),
              );
            }
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8, // Taller cards
              ),
              itemCount: history.length,
              itemBuilder: (context, index) {
                return FlowerHistoryCard(cycle: history[index]);
              },
            );
          } else if (state is PlantError) {
             return Center(child: Text("Error: ${state.message}"));
          }
          
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
