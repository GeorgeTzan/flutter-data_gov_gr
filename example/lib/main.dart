import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'theme.dart';
import 'state.dart';
import 'screens/monitor_screen.dart';
import 'screens/catalog_screen.dart';
import 'screens/system_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SDKState(),
      child: const DataGovApp(),
    ),
  );
}

class DataGovApp extends StatelessWidget {
  const DataGovApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Data.gov.gr Command Center',
      debugShowCheckedModeBanner: false,
      theme: CommandCenterTheme.dark(),
      home: const MainScaffold(),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const MonitorScreen(),
    const CatalogScreen(),
    const SystemScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white.withAlpha(13))),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: CommandCenterTheme.darkBg,
          selectedItemColor: CommandCenterTheme.secondaryCyan,
          unselectedItemColor: Colors.white38,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.gaugeHigh, size: 20),
              label: 'Monitor',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.boxArchive, size: 20),
              label: 'Catalog',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.microchip, size: 20),
              label: 'System',
            ),
          ],
        ),
      ),
    );
  }
}
