// lib/screens/lecturer/lecturer_shell.dart

import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../widgets/app_shell.dart';
import '../profile_screen.dart';
import '../shared/announcements_screen.dart';
import '../shared/events_screen.dart';
import 'courses_screen.dart';
import 'lecturer_dashboard.dart';

class LecturerShell extends StatelessWidget {
  final User user;

  const LecturerShell({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      pages: [
        LecturerDashboard(user: user),
        CoursesScreen(user: user),
        EventsScreen(user: user),
        AnnouncementsScreen(user: user),
        ProfileScreen(user: user),
      ],
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.menu_book_outlined),
          selectedIcon: Icon(Icons.menu_book),
          label: 'Courses',
        ),
        NavigationDestination(
          icon: Icon(Icons.event_outlined),
          selectedIcon: Icon(Icons.event),
          label: 'Events',
        ),
        NavigationDestination(
          icon: Icon(Icons.campaign_outlined),
          selectedIcon: Icon(Icons.campaign),
          label: 'News',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
