import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../bloc/plant_bloc.dart';

class BadgeCard extends StatefulWidget {
  final String title;
  final String description;
  final DateTime dateEarned;
  final String? assetPath;
  final IconData icon;
  final String? initialNote;
  final String cycleId;

  final String? emoji;

  const BadgeCard({
    super.key,
    required this.title,
    required this.description,
    required this.dateEarned,
    this.icon = Icons.emoji_events,
    this.assetPath,
    this.initialNote,
    required this.cycleId,
    this.emoji,
  });

  @override
  State<BadgeCard> createState() => _BadgeCardState();
}

class _BadgeCardState extends State<BadgeCard> {
  // ... (Controller logic remains same)
  late TextEditingController _noteController; 

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.initialNote);
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
          // ... (style remains same)
          boxShadow: [
             BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
          border: Border.all(color: AppColors.creamPeach, width: 2),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.creamPeach.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: widget.emoji != null 
                  ? Text(
                      widget.emoji!,
                      style: const TextStyle(fontSize: 32),
                    )
                  : widget.assetPath != null
                  ? Image.asset(
                      widget.assetPath!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                    )
                  : Icon(
                      widget.icon,
                      size: 24,
                      color: AppColors.accentPink,
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10,
                color: AppColors.primaryText,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // Date removed as requested
            if (widget.initialNote != null && widget.initialNote!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  widget.initialNote!,
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
    _noteController.text = widget.initialNote ?? '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Badge Notes"),
          content: TextField(
            controller: _noteController,
             maxLines: 4,
             decoration: const InputDecoration(
               hintText: "Add your notes about this badge...",
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
                context.read<PlantBloc>().add(UpdateCycleNote(widget.cycleId, _noteController.text));
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
