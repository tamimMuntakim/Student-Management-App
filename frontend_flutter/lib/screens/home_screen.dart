import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import '../services/api_service.dart';
import '../models/student.dart';
import '../models/subject.dart';
import 'auth_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton.icon(
              icon: const Icon(Icons.logout, color: Colors.white, size: 18),
              label: const Text('Logout', style: TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(
                backgroundColor: Colors.red[500],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onPressed: () {
                QuickAlert.show(
                  context: context,
                  type: QuickAlertType.confirm,
                  title: 'Logging out...',
                  text: 'Are you sure you want to log out?',
                  confirmBtnText: 'Yes, log out!',
                  confirmBtnColor: Colors.red,
                  onConfirmBtnTap: () async {
                    Navigator.pop(context);
                    await ApiService().logout();
                    if (!context.mounted) return;
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => AuthScreen()));
                  },
                );
              },
            ),
          ),
        ],
      ),
      body: _buildPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Students'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Subjects'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Assign'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analytics'),
        ],
      ),
    );
  }

  Widget _buildPage() {
    switch (_currentIndex) {
      case 0:
        return StudentsView();
      case 1:
        return SubjectsView();
      case 2:
        return AssignmentsView();
      case 3:
        return AnalyticsView();
      default:
        return StudentsView();
    }
  }
}

// -----------------------------------------------------
// STUDENTS VIEW
// -----------------------------------------------------
class StudentsView extends StatefulWidget {
  @override
  _StudentsViewState createState() => _StudentsViewState();
}

class _StudentsViewState extends State<StudentsView> {
  final ApiService _apiService = ApiService();
  List<Student> _students = [];
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  void _fetchStudents() async {
    final list = await _apiService.getStudents();
    setState(() => _students = list);
  }

  void _addStudent() async {
    if (_nameCtrl.text.isEmpty || _emailCtrl.text.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'Missing Info',
        text: 'Please fill out both name and email.',
      );
      return;
    }
    await _apiService.addStudent(_nameCtrl.text, _emailCtrl.text);
    _nameCtrl.clear();
    _emailCtrl.clear();
    FocusScope.of(context).unfocus();
    _fetchStudents();
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: 'Success',
      text: 'Student added successfully!',
    );
  }

  void _deleteStudent(String id) async {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'Are you sure?',
      text: 'You will not be able to revert this!',
      confirmBtnText: 'Yes, delete it!',
      confirmBtnColor: Colors.red,
      onConfirmBtnTap: () async {
        Navigator.pop(context);
        await _apiService.deleteStudent(id);
        _fetchStudents();
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Deleted!',
          text: 'Student has been deleted.',
        );
      },
    );
  }

  void _editStudent(Student student) {
    final nameCtrl = TextEditingController(text: student.name);
    final emailCtrl = TextEditingController(text: student.email);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Edit Student', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 16),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              await _apiService.updateStudent(student.id!, nameCtrl.text, emailCtrl.text);
              Navigator.pop(ctx);
              _fetchStudents();
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add Student', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: TextField(controller: _nameCtrl, decoration: const InputDecoration(hintText: 'Name'))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: _emailCtrl, decoration: const InputDecoration(hintText: 'Email'))),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
                      onPressed: _addStudent,
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _students.length,
            itemBuilder: (context, index) {
              final student = _students[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ListTile(
                    title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(student.email, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: student.subjects.isEmpty
                            ? [Text('No subjects', style: TextStyle(color: Colors.grey[400], fontStyle: FontStyle.italic, fontSize: 12))]
                            : student.subjects.map((s) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.teal.shade100)
                                ),
                                child: Text(s.name, style: TextStyle(color: Colors.teal.shade800, fontSize: 12, fontWeight: FontWeight.w500)),
                              )).toList(),
                        )
                      ],
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () => _editStudent(student),
                          child: const Text('Edit', style: TextStyle(color: Colors.blue)),
                        ),
                        TextButton(
                          onPressed: () => _deleteStudent(student.id!),
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------
// SUBJECTS VIEW
// -----------------------------------------------------
class SubjectsView extends StatefulWidget {
  @override
  _SubjectsViewState createState() => _SubjectsViewState();
}

class _SubjectsViewState extends State<SubjectsView> {
  final ApiService _apiService = ApiService();
  List<Subject> _subjects = [];
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  void _fetchSubjects() async {
    final list = await _apiService.getSubjects();
    setState(() => _subjects = list);
  }

  void _addSubject() async {
    if (_nameCtrl.text.isEmpty || _codeCtrl.text.isEmpty) {
       QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'Missing Info',
        text: 'Please fill out both name and code.',
      );
      return;
    }
    await _apiService.addSubject(_nameCtrl.text, _codeCtrl.text);
    _nameCtrl.clear();
    _codeCtrl.clear();
    FocusScope.of(context).unfocus();
    _fetchSubjects();
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: 'Success',
      text: 'Subject added successfully!',
    );
  }

  void _deleteSubject(int id) async {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'Are you sure?',
      text: 'You will not be able to revert this!',
      confirmBtnText: 'Yes, delete it!',
      confirmBtnColor: Colors.red,
      onConfirmBtnTap: () async {
        Navigator.pop(context);
        await _apiService.deleteSubject(id);
        _fetchSubjects();
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Deleted!',
          text: 'Subject has been deleted.',
        );
      },
    );
  }

  void _editSubject(Subject subject) {
    final nameCtrl = TextEditingController(text: subject.name);
    final codeCtrl = TextEditingController(text: subject.code);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Edit Subject', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Subject Name')),
            const SizedBox(height: 16),
            TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Subject Code')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              await _apiService.updateSubject(subject.id!, nameCtrl.text, codeCtrl.text);
              Navigator.pop(ctx);
              _fetchSubjects();
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add Subject', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: TextField(controller: _nameCtrl, decoration: const InputDecoration(hintText: 'Subject Name'))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: _codeCtrl, decoration: const InputDecoration(hintText: 'Subject Code'))),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
                      onPressed: _addSubject,
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _subjects.length,
            itemBuilder: (context, index) {
              final subject = _subjects[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey[300]!)
                      ),
                      child: Text(
                        subject.code,
                        style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, color: Colors.teal[800]),
                      ),
                    ),
                    title: Text(subject.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () => _editSubject(subject),
                          child: const Text('Edit', style: TextStyle(color: Colors.blue)),
                        ),
                        TextButton(
                          onPressed: () => _deleteSubject(subject.id!),
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------
// ASSIGNMENTS VIEW
// -----------------------------------------------------
class AssignmentsView extends StatefulWidget {
  @override
  _AssignmentsViewState createState() => _AssignmentsViewState();
}

class _AssignmentsViewState extends State<AssignmentsView> {
  final ApiService _apiService = ApiService();
  List<Student> _students = [];
  List<Subject> _subjects = [];
  String? _selectedStudent;
  int? _selectedSubject;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    final studentList = await _apiService.getStudents();
    final subjectList = await _apiService.getSubjects();
    setState(() {
      _students = studentList;
      _subjects = subjectList;
    });
  }

  void _assignSubject() async {
    if (_selectedStudent == null || _selectedSubject == null) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'Missing Selection',
        text: 'Please select both a student and a subject.',
      );
      return;
    }
    await _apiService.assignSubject(_selectedStudent!, _selectedSubject!);
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: 'Success',
      text: 'Subject assigned successfully!',
    );
    _selectedStudent = null;
    _selectedSubject = null;
    _fetchData(); // refresh data
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Assign Subject', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text('-- Select Student --'),
                      value: _selectedStudent,
                      items: _students.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(),
                      onChanged: (val) => setState(() => _selectedStudent = val),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      hint: const Text('-- Select Subject --'),
                      value: _selectedSubject,
                      items: _subjects.map((e) => DropdownMenuItem(value: e.id, child: Text('${e.name} (${e.code})'))).toList(),
                      onChanged: (val) => setState(() => _selectedSubject = val),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _assignSubject,
                    child: const Text('Assign Subject'),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Text('Assigned Subjects Log', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700])),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _students.length,
            itemBuilder: (ctx, idx) {
              final student = _students[idx];
              if (student.subjects.isEmpty) return const SizedBox.shrink();
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: student.subjects.map((s) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.grey[300]!)
                          ),
                          child: Text('${s.name} (${s.code})', style: TextStyle(fontSize: 12, color: Colors.grey[800], fontWeight: FontWeight.w500)),
                        )).toList(),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}

// -----------------------------------------------------
// ANALYTICS VIEW
// -----------------------------------------------------
class AnalyticsView extends StatefulWidget {
  @override
  _AnalyticsViewState createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  final ApiService _apiService = ApiService();
  List<Student> _students = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    final studentList = await _apiService.getStudents();
    setState(() {
      _students = studentList;
    });
  }
  
  Map<String, List<String>> _getCourseStudents() {
    Map<String, List<String>> map = {};
    for (var student in _students) {
      for (var subject in student.subjects) {
        String key = '${subject.code}: ${subject.name}';
        if (!map.containsKey(key)) {
          map[key] = [];
        }
        map[key]!.add(student.name);
      }
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final courseStudents = _getCourseStudents();
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Students and Enrolled Courses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
          child: Column(
            children: _students.map((s) => Column(
              children: [
                ListTile(
                  title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(s.email, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  trailing: Wrap(
                    spacing: 4,
                    children: s.subjects.isEmpty
                      ? [Text('No courses', style: TextStyle(color: Colors.grey[400], fontStyle: FontStyle.italic))]
                      : s.subjects.map((sub) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(sub.code, style: TextStyle(color: Colors.teal.shade700, fontSize: 12, fontWeight: FontWeight.w600)),
                        )).toList(),
                  ),
                ),
                if (s != _students.last) const Divider(height: 1, thickness: 1),
              ],
            )).toList(),
          ),
        ),
        const SizedBox(height: 24),
        Text('Courses and Enrolled Students', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
        const SizedBox(height: 12),
        if (courseStudents.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('No enrolled subjects found.', style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic)),
          )
        else
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey[200]!, width: 1),
            ),
            child: Column(
              children: courseStudents.entries.map((entry) {
                final isLast = entry.key == courseStudents.entries.last.key;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(entry.key, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[800])),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(entry.value.join(', '), style: TextStyle(color: Colors.grey[800])),
                      ),
                    ),
                    if (!isLast) const Divider(height: 1, thickness: 1),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
