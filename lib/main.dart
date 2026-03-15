import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/organization_provider.dart';
import 'providers/biller_provider.dart';
import 'providers/item_provider.dart';
import 'providers/invoice_provider.dart';
import 'screens/home_screen.dart';
import 'screens/billers_screen.dart';
import 'screens/items_screen.dart';
import 'screens/history_screen.dart';
import 'screens/analysis_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/bill_generation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize providers (load data)
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OrganizationProvider()),
        ChangeNotifierProvider(create: (_) => BillerProvider()),
        ChangeNotifierProvider(create: (_) => ItemProvider()),
        ChangeNotifierProvider(create: (_) => InvoiceProvider()),
      ],
      child: MaterialApp(
        title: 'Billing App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    HomeScreen(),
    BillersScreen(),
    ItemsScreen(),
    HistoryScreen(),
    AnalysisScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Billers'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Items'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analysis'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BillGenerationScreen()),
                );
              },
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}