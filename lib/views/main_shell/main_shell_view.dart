import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../accounts/accounts_list_view.dart';
import '../dashboard/dashboard_view.dart';
import '../more/more_view.dart';
import '../operations/operations_view.dart';
import '../reports/reports_view.dart';

/// الشاشة الهيكلية الرئيسية ذات شريط التنقل السفلي (Main Shell View)
class MainShellView extends StatefulWidget {
  final int initialIndex;

  const MainShellView({super.key, this.initialIndex = 0});

  @override
  State<MainShellView> createState() => _MainShellViewState();
}

class _MainShellViewState extends State<MainShellView> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _views = const [
    DashboardView(),
    OperationsView(),
    AccountsListView(),
    ReportsView(),
    MoreView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _views,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1.0),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 11),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'العمليات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'الحسابات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics),
              label: 'التقارير',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_rounded),
              activeIcon: Icon(Icons.menu_open_rounded),
              label: 'المزيد',
            ),
          ],
        ),
      ),
    );
  }
}
