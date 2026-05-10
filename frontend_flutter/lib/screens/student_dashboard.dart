import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import '../services/api_service.dart';
import '../models/student.dart';
import 'auth_screen.dart';

class StudentDashboardScreen extends StatelessWidget {
  final Student student;

  const StudentDashboardScreen({Key? key, required this.student}) : super(key: key);

  void _logout(BuildContext context) async {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'Logging out...',
      text: 'Are you sure you want to log out?',
      confirmBtnText: 'Yes, log out!',
      confirmBtnColor: Colors.red,
      onConfirmBtnTap: () async {
        Navigator.pop(context);
        final authService = ApiService();
        await authService.logout();
        if (!context.mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => AuthScreen()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Welcome, ${student.name}'),
        backgroundColor: Colors.teal[700],
        elevation: 2,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () => _logout(context),
              tooltip: 'Logout',
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal[800])),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text('Name:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                        const SizedBox(width: 8),
                        Text(student.name, style: TextStyle(fontSize: 16, color: Colors.grey[900])),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('Email:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                        const SizedBox(width: 8),
                        Text(student.email, style: TextStyle(fontSize: 16, color: Colors.grey[900])),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text('Your Enrolled Subjects', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
            ),
            const SizedBox(height: 12),
            student.subjects.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('No subjects assigned yet.', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[500])),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: student.subjects.length,
                    itemBuilder: (context, index) {
                      final sub = student.subjects[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.grey[200]!, width: 1),
                        ),
                        elevation: 0,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.teal.shade100)
                            ),
                            child: Text(
                              sub.code,
                              style: TextStyle(
                                color: Colors.teal.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                fontFamily: 'monospace'
                              ),
                            ),
                          ),
                          title: Text(sub.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
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
