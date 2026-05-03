package com.tamim.studentapp.student_server.service;

import com.tamim.studentapp.student_server.entity.Student;
import com.tamim.studentapp.student_server.entity.Subject;
import com.tamim.studentapp.student_server.repository.StudentRepository;
import com.tamim.studentapp.student_server.repository.SubjectRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@Transactional
public class StudentService {

    @Autowired
    private StudentRepository studentRepository;

    @Autowired
    private SubjectRepository subjectRepository;

    public Student saveStudent(Student student) {
        return studentRepository.save(student);
    }

    public Subject saveSubject(Subject subject) {
        return subjectRepository.save(subject);
    }

    public List<Student> getAllStudents() {
        return studentRepository.findAll();
    }

    public List<Subject> getAllSubjects() {
        return subjectRepository.findAll();
    }

    public Student assignSubjectToStudent(UUID studentId, Long subjectId) {
        Student student = studentRepository.findById(studentId)
            .orElseThrow(() -> new RuntimeException("Student not found with ID: " + studentId));
            
        Subject subject = subjectRepository.findById(subjectId)
            .orElseThrow(() -> new RuntimeException("Subject not found with ID: " + subjectId));
            
        student.getSubjects().add(subject);
        return studentRepository.save(student);
    }
}