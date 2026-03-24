import 'login_screen.dart';
import 'machine_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';
import 'party_yarn_screen.dart';
import 'job_summary_screen.dart';
import 'dashboard_home_screen.dart';
import 'product_manager_screen.dart';
import 'package:flutter/material.dart';


class Dashboard extends StatefulWidget {

  final String role;

  const Dashboard({super.key, required this.role});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  int _index = 0;

  late List<Widget> screens;
  late List<_NavItem> navItems;

  @override
  void initState() {
    super.initState();

    if (widget.role == "admin") {

      screens = [
        const DashboardHome(role: "admin"),
        const JobReportScreen(),
        const PartyYarnScreen(),
        const MachineScreen(),
        const ProductManagerScreen(),
        const ReportsScreen(),
        const SettingsScreen(),
      ];

      navItems = const [
        _NavItem(Icons.dashboard, "Dashboard"),
        _NavItem(Icons.factory, "Jobwork Orders"),
        _NavItem(Icons.inventory, "Yarn"),
        _NavItem(Icons.precision_manufacturing, "Machines"),
        _NavItem(Icons.category, "Products"),
        _NavItem(Icons.bar_chart, "Reports"),
        _NavItem(Icons.settings, "Settings"),
      ];

    } else {

      screens = [
        const DashboardHome(role: "admin")),
        const PartyYarnScreen(),
        const ReportsScreen(),
      ];

      navItems = const [
        _NavItem(Icons.dashboard, "Dashboard"),
        _NavItem(Icons.inventory, "Yarn"),
        _NavItem(Icons.bar_chart, "Reports"),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
      builder: (context, constraints) {

        /// DESKTOP LAYOUT
        if (constraints.maxWidth > 900) {

          return Scaffold(

            body: Row(
              children: [

                /// SIDEBAR
                _buildSidebar(),

                /// MAIN CONTENT
                Expanded(
                  child: Container(
                    color: const Color(0xFF121212),

                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 1600,
                        ),
                        child: screens[_index],
                      ),
                    ),
                  ),
                ),

              ],
            ),
          );
        }

        /// MOBILE LAYOUT
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

        /// FIXES OVERFLOW
        child: SingleChildScrollView(

          child: Column(
            children: [

              const SizedBox(height: 20),

              Image.asset(
                'assets/logo.png',
                height: 160,
              ),

              const SizedBox(height: 10),

              const Text(
                "ERP SYSTEM",
                style: TextStyle(
                  fontSize: 20,
                  letterSpacing: 2,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 30),

              ...List.generate(navItems.length, (i) {

                final selected = i == _index;

                return InkWell(
                  onTap: () => setState(() => _index = i),

                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),

                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),

                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF00BFA6).withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),

                    child: Row(
                      children: [

                        Icon(
                          navItems[i].icon,
                          color: selected
                              ? const Color(0xFF00BFA6)
                              : Colors.grey,
                        ),

                        const SizedBox(width: 14),

                        Text(
                          navItems[i].label,
                          style: TextStyle(
                            color: selected
                                ? const Color(0xFF00BFA6)
                                : Colors.grey,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),

                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 40),

              /// LOGOUT BUTTON
              ListTile(
                leading: const Icon(Icons.logout,
                    color: Colors.redAccent),

                title: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.white),
                ),

                onTap: () {

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                  );

                },
              ),

              const SizedBox(height: 20),

            ],
          ),
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