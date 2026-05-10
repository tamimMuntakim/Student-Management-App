import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'student_dashboard.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final ApiService _apiService = ApiService();

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  void _submit() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final name = _nameCtrl.text.trim();

    try {
      if (isLogin) {
        final user = await _apiService.login(email, password);
        if (user != null) {
          if (!mounted) return;
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: 'Login Successful',
            text: 'Welcome back!',
            onConfirmBtnTap: () {
              Navigator.pop(context);
              if (user.role == 'ADMIN') {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => HomeScreen()));
              } else {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => StudentDashboardScreen(student: user)));
              }
            }
          );
        } else {
          if (!mounted) return;
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Login Failed',
            text: 'Invalid credentials or Server unreachable',
          );
        }
      } else {
        final success = await _apiService.register(name, email, password);
        if (success) {
          if (!mounted) return;
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: 'Registered successfully',
            text: 'Please login to continue.',
            onConfirmBtnTap: () {
              Navigator.pop(context);
              setState(() {
                isLogin = true;
              });
            }
          );
        } else {
          if (!mounted) return;
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Registration failed',
            text: 'Please check your information.',
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: 'Network Error: Make sure backend is running!',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Student Management App',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.teal[800],
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        isLogin ? 'Sign In' : 'Create an Account',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      if (!isLogin) ...[
                        const Text('Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(hintText: 'John Doe'),
                        ),
                        const SizedBox(height: 16),
                      ],
                      const Text('Email Address', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _emailCtrl,
                        decoration: const InputDecoration(hintText: 'john@example.com'),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      const Text('Password', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passwordCtrl,
                        decoration: const InputDecoration(hintText: '••••••••'),
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          isLogin ? 'Login' : 'Register',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isLogin = !isLogin;
                          });
                        },
                        child: Text(isLogin
                            ? "Don't have an account? Register"
                            : 'Already have an account? Login'),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
