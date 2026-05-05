package com.tamim.studentapp.student_server.controller;

import com.tamim.studentapp.student_server.entity.Student;
import com.tamim.studentapp.student_server.entity.Subject;
import com.tamim.studentapp.student_server.repository.StudentRepository;
import com.tamim.studentapp.student_server.repository.SubjectRepository;
import com.tamim.studentapp.student_server.service.StudentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*") // Allows your HTML and Flutter apps to connect
public class StudentController {

    @Autowired
    private StudentService studentService;

    @Autowired
    private StudentRepository studentRepository;

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> credentials) {
        String email = credentials.get("email");
        String password = credentials.get("password");

        Optional<Student> studentOpt = studentRepository.findByEmail(email);
        if (studentOpt.isPresent()) {
            Student student = studentOpt.get();
            String dbPass = student.getPassword();

            if (dbPass != null && dbPass.equals(password)) {
                return ResponseEntity.ok(student);
            }
        }
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Invalid credentials"));
    }

    @PostMapping("/register")
    public Student register(@RequestBody Student student) {
        if (student.getPassword() == null || student.getPassword().isEmpty()) {
            student.setPassword("1234");
        }
        return studentService.saveStudent(student);
    }

    @PostMapping("/students")
    public Student addStudent(@RequestBody Student student) {
        if (student.getPassword() == null || student.getPassword().isEmpty()) {
            student.setPassword("1234");
        }
        return studentService.saveStudent(student);
    }

    @PostMapping("/subjects")
    public Subject addSubject(@RequestBody Subject subject) {
        return studentService.saveSubject(subject);
    }

    @GetMapping("/students")
    public List<Student> getStudents() {
        return studentService.getAllStudents();
    }

    @PutMapping("/{studentId}/subjects/{subjectId}")
    public Student assignSubject(@PathVariable UUID studentId, @PathVariable Long subjectId) {
        return studentService.assignSubjectToStudent(studentId, subjectId);
    }

    @Autowired
    private SubjectRepository subjectRepository; // Add this line

    // GET to see all subjects
    @GetMapping("/subjects")
    public List<Subject> getSubjects() {
        return subjectRepository.findAll();
    }

    @PutMapping("/students/{id}")
    public Student updateStudent(@PathVariable UUID id, @RequestBody Student studentDetails) {
        Student student = studentRepository.findById(id).orElseThrow(() -> new RuntimeException("Student not found"));
        student.setName(studentDetails.getName());
        student.setEmail(studentDetails.getEmail());
        if (studentDetails.getRole() != null) {
            student.setRole(studentDetails.getRole());
        }
        return studentRepository.save(student);
    }

    @DeleteMapping("/students/{id}")
    public ResponseEntity<?> deleteStudent(@PathVariable UUID id) {
        studentRepository.deleteById(id);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/subjects/{id}")
    public Subject updateSubject(@PathVariable Long id, @RequestBody Subject subjectDetails) {
        Subject subject = subjectRepository.findById(id).orElseThrow(() -> new RuntimeException("Subject not found"));
        subject.setName(subjectDetails.getName());
        subject.setCode(subjectDetails.getCode());
        return subjectRepository.save(subject);
    }

    @DeleteMapping("/subjects/{id}")
    public ResponseEntity<?> deleteSubject(@PathVariable Long id) {
        Subject subject = subjectRepository.findById(id).orElseThrow(() -> new RuntimeException("Subject not found"));
        List<Student> students = studentRepository.findAll();
        for (Student s : students) {
            if (s.getSubjects().contains(subject)) {
                s.getSubjects().remove(subject);
                studentRepository.save(s);
            }
        }
        subjectRepository.delete(subject);
        return ResponseEntity.ok().build();
    }
}