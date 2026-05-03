// The base URL for your Spring Boot Backend API
const API_BASE_URL = 'http://localhost:8080/api';

// DOM Elements
const studentsTableBody = document.querySelector('#students-table tbody');
const subjectsTableBody = document.querySelector('#subjects-table tbody');
const assignmentsTableBody = document.querySelector('#assignments-table tbody');
const selectStudent = document.getElementById('select-student');
const selectSubject = document.getElementById('select-subject');

// Forms
const addStudentForm = document.getElementById('add-student-form');
const addSubjectForm = document.getElementById('add-subject-form');
const assignSubjectForm = document.getElementById('assign-subject-form');

// Initialize the app by fetching data
window.onload = () => {
    const user = localStorage.getItem('studentUser');
    if (!user && !window.location.href.includes('login.html')) {
        window.location.href = 'login.html';
        return;
    }
    fetchStudents();
    fetchSubjects();
};

// Logout Function
function logout() {
    localStorage.removeItem('studentUser');
    window.location.href = 'login.html';
}

// --- API Calls & UI Updates ---

// Get all students
async function fetchStudents() {
    try {
        const response = await fetch(`${API_BASE_URL}/students`);
        const students = await response.json();
        
        // Update table
        studentsTableBody.innerHTML = '';
        assignmentsTableBody.innerHTML = '';
        selectStudent.innerHTML = '<option value="">-- Select Student --</option>';

        students.forEach(student => {
            // Populate table row
            const tr = document.createElement('tr');
            const assignedSubjects = student.subjects 
                ? student.subjects.map(sub => sub.name).join(', ') 
                : 'None';

            tr.innerHTML = `
                <td>${student.name}</td>
                <td>${student.email}</td>
                <td>${assignedSubjects || 'None'}</td>
            `;
            studentsTableBody.appendChild(tr);

            // Populate dropdown
            const option = document.createElement('option');
            option.value = student.id;
            option.textContent = `${student.name} - (${student.email})`;

            // Populate Assignments Table
            if (student.subjects && student.subjects.length > 0) {
                student.subjects.forEach(subject => {
                    const trAssign = document.createElement('tr');
                    trAssign.innerHTML = `
                        <td>${student.name}</td>
                        <td>${subject.name}</td>
                        <td>${subject.code}</td>
                    `;
                    assignmentsTableBody.appendChild(trAssign);
                });
            }
            selectStudent.appendChild(option);
        });
    } catch (error) {
        console.error('Error fetching students:', error);
    }
}

// Get all subjects
async function fetchSubjects() {
    try {
        const response = await fetch(`${API_BASE_URL}/subjects`);
        const subjects = await response.json();

        // Update table
        subjectsTableBody.innerHTML = '';
        selectSubject.innerHTML = '<option value="">-- Select Subject --</option>';

        subjects.forEach(subject => {
            // Populate table row
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>${subject.id}</td>
                <td>${subject.name}</td>
                <td>${subject.code}</td>
            `;
            subjectsTableBody.appendChild(tr);

            // Populate dropdown
            const option = document.createElement('option');
            option.value = subject.id;
            option.textContent = `${subject.name} - ${subject.code}`;
            selectSubject.appendChild(option);
        });
    } catch (error) {
        console.error('Error fetching subjects:', error);
    }
}

// --- Event Listeners for Forms ---

// 1. Add Student
addStudentForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const name = document.getElementById('student-name').value;
    const email = document.getElementById('student-email').value;

    try {
        const res = await fetch(`${API_BASE_URL}/students`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ name, email })
        });
        
        if (res.ok) {
            addStudentForm.reset();
            fetchStudents(); // Refresh data
        }
    } catch (err) {
        console.error('Failure saving student:', err);
    }
});

// 2. Add Subject
addSubjectForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const name = document.getElementById('subject-name').value;
    const code = document.getElementById('subject-code').value;

    try {
        const res = await fetch(`${API_BASE_URL}/subjects`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ name, code })
        });

        if (res.ok) {
            addSubjectForm.reset();
            fetchSubjects(); // Refresh data
        }
    } catch (err) {
        console.error('Failure saving subject:', err);
    }
});

// 3. Assign Subject
assignSubjectForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const studentId = selectStudent.value;
    const subjectId = selectSubject.value;

    if (!studentId || !subjectId) return alert('Please select both student and subject');

    try {
        const res = await fetch(`${API_BASE_URL}/${studentId}/subjects/${subjectId}`, {
            method: 'PUT'
        });

        if (res.ok) {
            assignSubjectForm.reset();
            fetchStudents(); // The student's subject list should update now
            alert("Subject assigned successfully!");
        }
    } catch (err) {
        console.error('Failure assigning subject:', err);
    }
});