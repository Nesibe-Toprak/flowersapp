import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';

class TemaDonationDialog extends StatelessWidget {
  const TemaDonationDialog({super.key});

  Future<void> _launchTemaUrl() async {
    final Uri url = Uri.parse('https://www.tema.org.tr/tek-seferlik-bagis');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      title: Column(
        children: [
           Icon(Icons.volunteer_activism, size: 48, color: AppColors.sageGreen),
           const SizedBox(height: 12),
           const Text(
            "Grow Real Hope!",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: const Text(
        "Your virtual flower has bloomed beautifully! \n\n"
        "Celebrate this achievement by planting a real sapling with TEMA Foundation.",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Maybe Later",
            style: TextStyle(color: AppColors.darkGrey.withOpacity(0.6)),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            _launchTemaUrl();
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.sageGreen,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text(
            "Donate to TEMA",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
