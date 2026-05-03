import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final hasUser = prefs.getString('studentUser') != null;

  runApp(MyApp(hasUser: hasUser));
}

class MyApp extends StatelessWidget {
  final bool hasUser;

  const MyApp({Key? key, required this.hasUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Management',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: hasUser ? HomeScreen() : AuthScreen(),
    );
  }
}
