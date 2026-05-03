import 'subject.dart';

class Student {
  final String? id;
  final String name;
  final String email;
  final String? password;
  final List<Subject> subjects;

  Student({
    this.id,
    required this.name,
    required this.email,
    this.password,
    this.subjects = const [],
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    var subjectsList = json['subjects'] as List? ?? [];
    List<Subject> parsedSubjects = subjectsList.map((i) => Subject.fromJson(i)).toList();

    return Student(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      subjects: parsedSubjects,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'subjects': subjects.map((e) => e.toJson()).toList(),
    };
  }
}