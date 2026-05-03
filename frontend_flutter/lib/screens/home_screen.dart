import 'package:flutter/material.dart';
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
        title: Text('Student Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await ApiService().logout();
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => AuthScreen()));
            },
          )
        ],
      ),
      body: _buildPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Students'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Subjects'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Assignments'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analytics'),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
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
    if (_nameCtrl.text.isEmpty || _emailCtrl.text.isEmpty) return;
    await _apiService.addStudent(_nameCtrl.text, _emailCtrl.text);
    _nameCtrl.clear();
    _emailCtrl.clear();
    _fetchStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(child: TextField(controller: _nameCtrl, decoration: InputDecoration(labelText: 'Name'))),
              SizedBox(width: 8),
              Expanded(child: TextField(controller: _emailCtrl, decoration: InputDecoration(labelText: 'Email'))),
              IconButton(icon: Icon(Icons.add), onPressed: _addStudent),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _students.length,
            itemBuilder: (context, index) {
              final student = _students[index];
              final subjects = student.subjects.map((s) => s.name).join(', ');
              return ListTile(
                title: Text(student.name),
                subtitle: Text('${student.email}\\nSubjects: ${subjects.isEmpty ? 'None' : subjects}'),
              );
            },
          ),
        ),
      ],
    );
  }
}

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
    if (_nameCtrl.text.isEmpty || _codeCtrl.text.isEmpty) return;
    await _apiService.addSubject(_nameCtrl.text, _codeCtrl.text);
    _nameCtrl.clear();
    _codeCtrl.clear();
    _fetchSubjects();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(child: TextField(controller: _nameCtrl, decoration: InputDecoration(labelText: 'Name'))),
              SizedBox(width: 8),
              Expanded(child: TextField(controller: _codeCtrl, decoration: InputDecoration(labelText: 'Code'))),
              IconButton(icon: Icon(Icons.add), onPressed: _addSubject),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _subjects.length,
            itemBuilder: (context, index) {
              final subject = _subjects[index];
              return ListTile(
                title: Text(subject.name),
                subtitle: Text(subject.code),
              );
            },
          ),
        ),
      ],
    );
  }
}

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
    if (_selectedStudent == null || _selectedSubject == null) return;
    await _apiService.assignSubject(_selectedStudent!, _selectedSubject!);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Subject Assigned!')));
    _fetchData(); // refresh data
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButton<String>(
            isExpanded: true,
            hint: Text('-- Select Student --'),
            value: _selectedStudent,
            items: _students.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(),
            onChanged: (val) => setState(() => _selectedStudent = val),
          ),
          SizedBox(height: 16),
          DropdownButton<int>(
            isExpanded: true,
            hint: Text('-- Select Subject --'),
            value: _selectedSubject,
            items: _subjects.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(),
            onChanged: (val) => setState(() => _selectedSubject = val),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _assignSubject,
            child: Text('Assign Subject'),
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _students.length,
              itemBuilder: (ctx, idx) {
                final student = _students[idx];
                final subList = student.subjects.map((s) => '\${s.name} (\${s.code})').join(', ');
                if (student.subjects.isEmpty) return SizedBox.shrink();
                return ListTile(
                  title: Text(student.name),
                  subtitle: Text(subList),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

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
        if (!map.containsKey(subject.name)) {
          map[subject.name] = [];
        }
        map[subject.name]!.add(student.name);
      }
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final courseStudents = _getCourseStudents();
    
    return ListView(
      padding: EdgeInsets.all(8),
      children: [
        Text('Students and Enrolled Courses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ..._students.map((s) => ListTile(
          title: Text(s.name),
          subtitle: Text(s.subjects.isEmpty ? 'No courses' : s.subjects.map((sub) => sub.name).join(', ')),
        )),
        Divider(),
        Text('Courses and Enrolled Students', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ...courseStudents.entries.map((entry) => ListTile(
          title: Text(entry.key),
          subtitle: Text(entry.value.join(', ')),
        )),
      ],
    );
  }
}
