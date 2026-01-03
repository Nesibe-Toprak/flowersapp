import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../presentation/widgets/lazy_indexed_stack.dart';
import 'planner_view.dart';
import 'success_garden_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const PlannerView(),
    const SuccessGardenPage(mode: GardenViewMode.flowers),
    const SuccessGardenPage(mode: GardenViewMode.badges),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accentPink,
      body: LazyIndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.sageGreen,
          unselectedItemColor: AppColors.primaryText.withOpacity(0.5),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Ana Sayfa',
            ),
            BottomNavigationBarItem(
              icon: Text('🌸', style: TextStyle(fontSize: 24)),
              label: 'Başarı Bahçem',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.verified), // Or emoji_events
              label: 'Başarı Rozetlerim',
            ),
          ],
        ),
      ),
    );
  }
}
