import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time/screens/categories_screen.dart';
import 'package:time/services/alarm_manager_service.dart';
import 'providers/task_provider.dart';
import 'services/notification_service.dart';
import 'screens/idea_dump_screen.dart';
import 'screens/focus_screen.dart';
import 'screens/blocked_screen.dart';
import 'screens/completed_screen.dart';
import 'package:timezone/data/latest.dart' as tz;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await NotificationService.init();
  await AlarmManagerService.init();
  await NotificationService.scheduleDailyNudges();
  await AlarmManagerService.scheduleDynamicSummaries();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider()..loadTasks(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Life Mentor',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          scaffoldBackgroundColor: Colors.grey.shade100,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: Colors.indigo,
            unselectedItemColor: Colors.grey,
          ),
          cardTheme: CardTheme(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
          ),
        ),

        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;

  final _screens = [
    const IdeaDumpScreen(),
    const FocusScreen(),
    const BlockedScreen(),
    const CompletedScreen(),
    const CategoriesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: "Ideas"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "Focus"),
          BottomNavigationBarItem(icon: Icon(Icons.block), label: "Blocked"),
          BottomNavigationBarItem(icon: Icon(Icons.check), label: "Done"),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: "Categories"),
        ],
      ),
    );
  }
}
