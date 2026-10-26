import 'package:flutter/material.dart';

import '../models/app_user.dart';
import 'discover/discover_screen.dart';
import 'my_skills/my_skills_screen.dart';
import 'profile/profile_screen.dart';
import 'requests/requests_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({required this.user, super.key});

  final AppUser user;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DiscoverScreen(user: widget.user),
      MySkillsScreen(user: widget.user),
      RequestsScreen(user: widget.user),
      ProfileScreen(user: widget.user),
    ];
    return Scaffold(
      body: IndexedStack(index: _selected, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selected,
        onDestinationSelected: (index) => setState(() => _selected = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.lightbulb_outline),
            selectedIcon: Icon(Icons.lightbulb),
            label: 'My Skills',
          ),
          NavigationDestination(
            icon: Icon(Icons.markunread_mailbox_outlined),
            selectedIcon: Icon(Icons.markunread_mailbox),
            label: 'Requests',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
