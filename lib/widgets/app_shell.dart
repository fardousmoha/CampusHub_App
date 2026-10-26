// lib/widgets/app_shell.dart
import 'package:flutter/material.dart';

class AppShell extends StatefulWidget {
  final List<Widget> pages;                       // one page for each tab
  final List<NavigationDestination> destinations; // the tabs

  const AppShell({super.key, required this.pages, required this.destinations});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;   // the open tab (state)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);   // change the tab and rebuild
        },
        destinations: widget.destinations,
      ),
    );
  }
}
