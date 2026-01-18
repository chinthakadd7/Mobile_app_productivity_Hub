import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:Actify/pages/notes_page.dart';
import 'package:Actify/pages/reminder_page.dart';
import 'package:Actify/pages/timetable_page.dart';
import 'package:Actify/pages/userprofile_page.dart';
import 'package:Actify/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Organizer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        scaffoldBackgroundColor: const Color.fromARGB(255, 17, 16, 16),
        useMaterial3: true,
      
      ),
      home: const LoginPage(),
    );
  }
}

class HomeShell extends StatefulWidget {
  final String userId;
  final String userName;
  final String userEmail;

  const HomeShell({
    super.key,
    required this.userId,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<HomeShell> createState() => HomeShellState();
}

class HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      NotesPage(userId: widget.userId, userName: widget.userName, userEmail: widget.userEmail),
      const RemindersPage(),
      const TimetablePage(),
      UserProfilePage(userId: widget.userId, userName: widget.userName, userEmail: widget.userEmail),
    ];

    return Scaffold(
      body: pages[_index],
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
