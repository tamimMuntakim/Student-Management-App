import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/student.dart';
import 'auth_screen.dart';

class StudentDashboardScreen extends StatelessWidget {
  final Student student;

  const StudentDashboardScreen({Key? key, required this.student}) : super(key: key);

  void _logout(BuildContext context) async {
    final authService = ApiService();
    await authService.logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Welcome, ${student.name}'),
        backgroundColor: Colors.teal,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
                    const SizedBox(height: 10),
                    Text('Name: ${student.name}', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 5),
                    Text('Email: ${student.email}', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Your Enrolled Subjects', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
            const SizedBox(height: 10),
            student.subjects.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('No subjects assigned yet.', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: student.subjects.length,
                    itemBuilder: (context, index) {
                      final sub = student.subjects[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 2,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal.shade100,
                            child: Text(sub.code.substring(0, 1).toUpperCase(), style: TextStyle(color: Colors.teal.shade900)),
                          ),
                          title: Text(sub.name, style: TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('Code: ${sub.code}'),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}