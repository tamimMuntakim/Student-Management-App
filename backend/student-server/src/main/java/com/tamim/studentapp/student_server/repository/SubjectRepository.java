package com.tamim.studentapp.student_server.repository;

import com.tamim.studentapp.student_server.entity.Subject;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SubjectRepository extends JpaRepository<Subject, Long> {
}