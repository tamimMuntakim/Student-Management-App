import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/student.dart';
import '../models/subject.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080/api';
    }
    // If running on Android Emulator, use 10.0.2.2. Otherwise assume localhost
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8080/api';
    } catch (e) {
      // Ignored for non-io platforms
    }
    return 'http://localhost:8080/api';
  }

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  // Auth Methods
  Future<Student?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: headers,
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final userJson = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('studentUser', jsonEncode(userJson));
        return Student.fromJson(userJson);
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('studentUser');
  }

  Future<bool> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: headers,
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    return response.statusCode == 200;
  }

  // Students Methods
  Future<List<Student>> getStudents() async {
    final response = await http.get(Uri.parse('$baseUrl/students'));
    if (response.statusCode == 200) {
      Iterable l = jsonDecode(response.body);
      return List<Student>.from(l.map((model) => Student.fromJson(model)));
    }
    return [];
  }

  Future<bool> addStudent(String name, String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/students'),
      headers: headers,
      body: jsonEncode({'name': name, 'email': email}),
    );
    return response.statusCode == 200;
  }

  Future<bool> updateStudent(String id, String name, String email) async {
    final response = await http.put(
      Uri.parse('$baseUrl/students/$id'),
      headers: headers,
      body: jsonEncode({'name': name, 'email': email}),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteStudent(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/students/$id'),
      headers: headers,
    );
    return response.statusCode == 200;
  }

  // Subjects Methods
  Future<List<Subject>> getSubjects() async {
    final response = await http.get(Uri.parse('$baseUrl/subjects'));
    if (response.statusCode == 200) {
      Iterable l = jsonDecode(response.body);
      return List<Subject>.from(l.map((model) => Subject.fromJson(model)));
    }
    return [];
  }

  Future<bool> addSubject(String name, String code) async {
    final response = await http.post(
      Uri.parse('$baseUrl/subjects'),
      headers: headers,
      body: jsonEncode({'name': name, 'code': code}),
    );
    return response.statusCode == 200;
  }

  Future<bool> updateSubject(int id, String name, String code) async {
    final response = await http.put(
      Uri.parse('$baseUrl/subjects/$id'),
      headers: headers,
      body: jsonEncode({'name': name, 'code': code}),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteSubject(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/subjects/$id'),
      headers: headers,
    );
    return response.statusCode == 200;
  }

  // Assign Subject
  Future<bool> assignSubject(String studentId, int subjectId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$studentId/subjects/$subjectId'),
      headers: headers,
    );
    return response.statusCode == 200;
  }
}
