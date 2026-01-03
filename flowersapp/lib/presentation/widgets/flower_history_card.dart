import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/weekly_cycle.dart';
import '../../domain/entities/plant_stage.dart';
import '../bloc/plant_bloc.dart';

class FlowerHistoryCard extends StatefulWidget {
  final WeeklyCycle cycle;

  const FlowerHistoryCard({super.key, required this.cycle});

  @override
  State<FlowerHistoryCard> createState() => _FlowerHistoryCardState();
}

class _FlowerHistoryCardState extends State<FlowerHistoryCard> {
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.cycle.note);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showNoteDialog(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.cycle.status == PlantStage.flower 
            ? const Text('🌸', style: TextStyle(fontSize: 50))
            : Image.asset(
                _getAssetForStage(widget.cycle.status),
                width: 50,
                height: 50,
                cacheWidth: 150, 
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error, color: Colors.grey);
                },
              ),
            if (widget.cycle.note != null && widget.cycle.note!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  widget.cycle.note!,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.primaryText,
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  void _showNoteDialog(BuildContext context) {
    _noteController.text = widget.cycle.note ?? '';
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Flower Notes"),
          content: TextField(
            controller: _noteController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: "Add your notes about this flower...",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<PlantBloc>().add(UpdateCycleNote(widget.cycle.id, _noteController.text));
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  String _getAssetForStage(PlantStage stage) {
    return 'assets/images/plant_stage_1.png'; 
  }
}
