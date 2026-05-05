import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models/student.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/student_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final userStr = prefs.getString('studentUser');
  
  Widget initialScreen = AuthScreen();

  if (userStr != null) {
    try {
      final userMap = jsonDecode(userStr);
      final student = Student.fromJson(userMap);
      if (student.role == 'ADMIN') {
        initialScreen = HomeScreen();
      } else {
        initialScreen = StudentDashboardScreen(student: student);
      }
    } catch (e) {
      initialScreen = AuthScreen();
    }
  }

  runApp(MyApp(initialScreen: initialScreen));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;

  const MyApp({Key? key, required this.initialScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Management',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: initialScreen,
    );
  }
}
