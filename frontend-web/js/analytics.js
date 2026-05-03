const API_BASE_URL = 'http://localhost:8080/api';

window.onload = async () => {
    try {
        const response = await fetch(`${API_BASE_URL}/students`);
        const students = await response.json();
        
        populateStudentCoursesTable(students);
        populateCourseStudentsTable(students);
    } catch (error) {
        console.error('Error fetching analytics data:', error);
    }
};

function populateStudentCoursesTable(students) {
    const tbody = document.querySelector('#student-courses-table tbody');
    tbody.innerHTML = '';

    students.forEach(student => {
        const tr = document.createElement('tr');
        const subjectsList = student.subjects && student.subjects.length > 0 
            ? student.subjects.map(sub => `${sub.name} (${sub.code})`).join(', ') 
            : 'None';

        tr.innerHTML = `
            <td>${student.name}</td>
            <td>${student.email}</td>
            <td>${subjectsList}</td>
        `;
        tbody.appendChild(tr);
    });
}

function populateCourseStudentsTable(students) {
    const tbody = document.querySelector('#course-students-table tbody');
    tbody.innerHTML = '';

    // Group students by course
    const courseMap = {}; // key: subject.code, value: { course: subject, students: [] }

    students.forEach(student => {
        if (student.subjects) {
            student.subjects.forEach(subject => {
                if (!courseMap[subject.code]) {
                    courseMap[subject.code] = {
                        course: subject,
                        students: []
                    };
                }
                courseMap[subject.code].students.push(student.name);
            });
        }
    });

    const courses = Object.values(courseMap);
    
    if (courses.length === 0) {
        tbody.innerHTML = '<tr><td colspan="3">No courses with enrolled students found.</td></tr>';
        return;
    }

    courses.forEach(item => {
        const tr = document.createElement('tr');
        const studentsList = item.students.join(', ');

        tr.innerHTML = `
            <td>${item.course.code}</td>
            <td>${item.course.name}</td>
            <td>${studentsList}</td>
        `;
        tbody.appendChild(tr);
    });
}