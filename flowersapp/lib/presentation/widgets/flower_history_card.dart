import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/weekly_cycle.dart';
import '../../domain/entities/plant_stage.dart';

class FlowerHistoryCard extends StatefulWidget {
  final WeeklyCycle cycle;

  const FlowerHistoryCard({super.key, required this.cycle});

  @override
  State<FlowerHistoryCard> createState() => _FlowerHistoryCardState();
}

class _FlowerHistoryCardState extends State<FlowerHistoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _isFront = !_isFront;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * 3.14159; // PI
          final isBack = angle >= 1.5708; // PI / 2

          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            alignment: Alignment.center,
            child: isBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(3.14159), // Mirror back
                    child: _buildBack(),
                  )
                : _buildFront(),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Flower Icon
          Icon(
            _getIconForStage(widget.cycle.status),
            size: 64,
            color: _getColorForStage(widget.cycle.status),
          ),
          const SizedBox(height: 12),
          // Dates
          Text(
            DateFormat('MM/dd').format(widget.cycle.startDate),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // Badge ONLY if Growth (Most followed, but not all)
          if (widget.cycle.status == PlantStage.plant)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.creamPeach,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Perseverance",
                style: TextStyle(fontSize: 10, color: AppColors.accentPink, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundBeige,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sageGreen.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Text(
        widget.cycle.note ?? "Keep giving your best effort, and your garden will flourish!",
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontStyle: FontStyle.italic,
          color: AppColors.darkGrey,
        ),
      ),
    );
  }

  IconData _getIconForStage(PlantStage stage) {
    switch (stage) {
      case PlantStage.seed: return Icons.grain;
      case PlantStage.sprout: return Icons.eco;
      case PlantStage.plant: return Icons.local_florist;
      case PlantStage.bud: return Icons.nature;
      case PlantStage.flower: return Icons.filter_vintage;
      case PlantStage.withered: return Icons.sentiment_very_dissatisfied;
    }
  }

  Color _getColorForStage(PlantStage stage) {
    switch (stage) {
      case PlantStage.seed: return Colors.brown;
      case PlantStage.sprout: return AppColors.sageGreen;
      case PlantStage.plant: return Colors.green;
      case PlantStage.bud: return Colors.grey;
      case PlantStage.flower: return AppColors.accentPink;
      case PlantStage.withered: return AppColors.darkGrey;
    }
  }
}
