import 'config/app_config.dart';
import 'models/user_session.dart';
import 'package:flutter/material.dart';
import 'screens/job/job_summary_screen.dart';
import 'screens/reports/reports_screen.dart';
import 'screens/machine/machine_screen.dart';
import 'screens/yarn/party_yarn_screen.dart';
import 'screens/admin/product_manager_screen.dart';
import 'screens/dashboard/dashboard_home_screen.dart';
import 'screens/dashboard/dashboard_screen.dart'; // ✅ ADD THIS
import 'package:knit_jobwork_app/screens/auth/login_screen.dart';

import 'screens/dispatch/dispatch_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 
  await AppConfig.load();

if (!AppConfig.requireLogin); {
  UserSession.initDevSession(); // 🔥 THIS FIXES YOUR ISSUE
}
  runApp(const KnitApp());
}

/* ================= APP ROOT ================= */

class KnitApp extends StatelessWidget {
  const KnitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  debugShowCheckedModeBanner: false,

  theme: ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),

    colorScheme: const ColorScheme.dark(primary: Color(0xFF00BFA6)),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      elevation: 0,
      centerTitle: true,
    ),

    cardTheme: const CardThemeData(
      color: Color(0xFF1E1E1E),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF00BFA6),
      foregroundColor: Colors.black,
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: Color(0xFF00BFA6),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    ),
  ),

  initialRoute: AppConfig.requireLogin ? "/login" : "/dashboard",

  routes: {
    "/login": (context) =>  LoginScreen(),
    "/dashboard": (context) => const Dashboard(),
  },
);  
  }
}

/* ================= DASHBOARD ================= */



class _DashboardState extends State<Dashboard> {
  int _index = 0;

  final List<Widget> screens = [
    DashboardHome(),
    JobReportScreen(),
    PartyYarnScreen(),
    const DispatchListScreen(),
    MachineScreen(),
    ProductManagerScreen(),
    ReportsScreen(),
  ];

  final List<_NavItem> navItems = const [
  _NavItem(Icons.dashboard, "Dashboard"),
  _NavItem(Icons.factory, "Jobwork"),
  _NavItem(Icons.inventory, "Yarn"),
  _NavItem(Icons.local_shipping, "Dispatch"), // ✅ ADD THIS
  _NavItem(Icons.precision_manufacturing, "Machines"),
  _NavItem(Icons.category, "Products"),
  _NavItem(Icons.bar_chart, "Reports"),
];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop / Web Layout
        if (constraints.maxWidth > 900) {
          return Scaffold(
            body: Row(
              children: [

                _buildSidebar(),

                Expanded(
                  child: Column(
                    children: [

                      _buildTopBar(),

                      Expanded(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 1280,
                            ),
                            child: screens[_index],
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // Mobile Layout
        return Scaffold(
          body: screens[_index],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
            items: navItems
                .map(
                  (item) => BottomNavigationBarItem(
                    icon: Icon(item.icon),
                    label: item.label,
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 230,
      color: const Color(0xFF1A1A1A),
      child: SingleChildScrollView(
      child:  Column(
  children: [
    Image.asset(
      'assets/logo.png',
      height: 220,
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
          const SizedBox(height: 40),

          ...List.generate(navItems.length, (i) {
            final selected = i == _index;

            return InkWell(
              onTap: () => setState(() => _index = i),
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
      ),
    );
  }
}

Widget _buildTopBar() {
  return Container(
    height: 60,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    decoration: BoxDecoration(
      color: const Color(0xFF1E1E1E),
      border: Border(
        bottom: BorderSide(
          color: Colors.grey.shade800,
        ),
      ),
    ),
    child: Row(
      children: [

        const Text(
          "Factory Command Center",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const Spacer(),

        /// SERVER STATUS
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Row(
            children: [

              Icon(
                Icons.circle,
                size: 10,
                color: Colors.greenAccent,
              ),

              SizedBox(width: 6),

              Text(
                "SERVER ONLINE",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 20),

        /// NOTIFICATIONS
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {},
        ),

        /// USER
        const CircleAvatar(
          radius: 16,
          backgroundColor: Color(0xFF00BFA6),
          child: Icon(
            Icons.person,
            size: 18,
            color: Colors.black,
          ),
        ),

        const SizedBox(width: 10),
      ],
    ),
  );
}


class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem(this.icon, this.label);
}