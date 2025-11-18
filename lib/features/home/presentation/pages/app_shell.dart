import 'package:expense_tracker/core/constants/colors.dart';
import 'package:expense_tracker/features/home/domain/entities/transaction.dart';
import 'package:expense_tracker/features/home/presentation/pages/dashboard_page.dart';
import 'package:expense_tracker/features/home/presentation/pages/save_transaction.dart';
import 'package:expense_tracker/features/home/presentation/pages/profile_page.dart';
import 'package:expense_tracker/features/home/presentation/pages/transactions_page.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/svg.dart';

class AppShell extends StatefulWidget {
  const AppShell({Key? key}) : super(key: key);

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: [
          Scaffold(
            extendBody: true,
            body: IndexedStack(
              index: _index,
              children: [
                DashboardPage(),
                const TransactionsPage(),
                const _PlaceholderPage(title: 'Budget'),
                const ProfilePage(),
              ],
            ),
            floatingActionButton: GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _expanded ? AppColors.primary : AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  _expanded ? Icons.close : Icons.add,
                  size: 28,
                  color: Colors.white,
                ),
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),
                child: BottomAppBar(
                  shape: const CircularNotchedRectangle(),
                  notchMargin: 8,
                  color: Colors.white,
                  elevation: 0,
                  child: SizedBox(
                    height: 65,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(Icons.home, 'Home', 0),
                        _buildNavItem(Icons.swap_horiz, 'Transaction', 1),
                        const SizedBox(width: 60),
                        _buildNavItem(Icons.pie_chart_outline, 'Budget', 2),
                        _buildNavItem(Icons.person_outline, 'Profile', 3),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_expanded)
            Positioned(
              bottom: 130,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  circleButton(
                    color: const Color(0xFF00A86B),
                    icon: 'income',
                    onTap: () {
                      setState(() => _expanded = false);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddTxnPage(isIncome: true),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 50),
                  circleButton(
                    color: const Color(0xFFFF3B30),
                    icon: 'expense',
                    onTap: () {
                      setState(() => _expanded = false);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddTxnPage(isIncome: false),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
      );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _index == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _expanded = false;
            _index = index;
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : Colors.grey,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget circleButton({
    required Color color,
    required String icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black26,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: SvgPicture.asset(
          'assets/$icon.svg',
          // colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          width: 24,
          height: 24,
        ),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title coming soon')),
    );
  }
}


