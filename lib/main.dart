import 'package:flutter/material.dart';
import 'package:new_test/pages/notes_page.dart';
import 'package:new_test/pages/reminder_page.dart';
import 'package:new_test/pages/timetable_page.dart';
import 'package:new_test/pages/userprofile_page.dart';
import 'package:new_test/pages/login_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Organizer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        scaffoldBackgroundColor: Colors.grey[50],
        useMaterial3: true,
      ),
      home:  LoginPage(),
      routes: {
        '/notes': (_) => const NotesPage(),
        '/reminders': (_) => const RemindersPage(),
        '/timetable': (_) => const TimetablePage(),
        '/profile': (_) => const UserProfilePage(),
      },
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell();

  @override
  State<HomeShell> createState() => HomeShellState();
}

class HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _pages = const [
    NotesPage(),
    RemindersPage(),
    TimetablePage(),
    UserProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.note_outlined), label: 'Notes'),
          NavigationDestination(icon: Icon(Icons.alarm_outlined), label: 'Reminders'),
          NavigationDestination(icon: Icon(Icons.event_outlined), label: 'Timetable'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
