import 'login_screen.dart';
import 'machine_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';
import 'party_yarn_screen.dart';
import 'job_summary_screen.dart';
import 'dashboard_home_screen.dart';
import 'product_manager_screen.dart';
import '../models/user_session.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _index = 0;

  late List<_NavItem> navItems;

  UserSession get s => UserSession.current!; // 🔥 GLOBAL SESSION

  @override
  void initState() {
    super.initState();

    navItems = [
      if (s.has("VIEW_DASHBOARD"))
        const _NavItem(Icons.dashboard, "Dashboard"),

      if (s.has("VIEW_JOBS"))
        const _NavItem(Icons.factory, "Jobwork Orders"),

      if (s.has("VIEW_YARN"))
        const _NavItem(Icons.inventory, "Yarn"),

      if (s.has("VIEW_MACHINES"))
        const _NavItem(Icons.precision_manufacturing, "Machines"),

      if (s.has("VIEW_PRODUCTS"))
        const _NavItem(Icons.category, "Products"),

      if (s.has("VIEW_REPORTS"))
        const _NavItem(Icons.bar_chart, "Reports"),

      if (s.has("VIEW_SETTINGS"))
        const _NavItem(Icons.settings, "Settings"),
    ];
  }

  List<Widget> _getVisibleScreens() {
    List<Widget> list = [];

    if (s.has("VIEW_DASHBOARD")) list.add(const DashboardHome());
    if (s.has("VIEW_JOBS")) list.add(const JobReportScreen());
    if (s.has("VIEW_YARN")) list.add(const PartyYarnScreen());
    if (s.has("VIEW_MACHINES")) list.add(const MachineScreen());
    if (s.has("VIEW_PRODUCTS")) list.add(const ProductManagerScreen());
    if (s.has("VIEW_REPORTS")) list.add(const ReportsScreen());
    if (s.has("VIEW_SETTINGS")) list.add(const SettingsScreen());

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final screens = _getVisibleScreens();

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return Scaffold(
            body: Row(
              children: [
                _buildSidebar(),
                Expanded(
                  child: Container(
                    color: const Color(0xFF121212),
                    child: screens[_index],
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: screens[_index],
        );
      },
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 230,
      color: const Color(0xFF1A1A1A),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Image.asset('assets/logo.png', height: 120),
            const SizedBox(height: 30),

            ...List.generate(navItems.length, (i) {
              final selected = i == _index;

              return ListTile(
                leading: Icon(
                  navItems[i].icon,
                  color: selected ? const Color(0xFF00BFA6) : Colors.grey,
                ),
                title: Text(
                  navItems[i].label,
                  style: TextStyle(
                    color: selected ? const Color(0xFF00BFA6) : Colors.grey,
                  ),
                ),
                onTap: () => setState(() => _index = i),
              );
            }),

            const Spacer(),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout"),
              onTap: () {
                UserSession.clear(); // 🔥 CLEAR SESSION

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem(this.icon, this.label);
}