// Removed the redeclaration of API_BASE_URL since it's already in app.js
// If analytics.js is the only file, we'd need it, but they are included together now.

async function fetchAnalytics() {
    try {
        const response = await fetch(`${API_BASE_URL}/students`);
        const students = await response.json();
        
        populateStudentCoursesTable(students);
        populateCourseStudentsTable(students);
    } catch (error) {
        console.error('Error fetching analytics data:', error);
    }
}

function populateStudentCoursesTable(students) {
    const tbody = document.querySelector('#student-courses-table tbody');
    if (!tbody) return;
    tbody.innerHTML = '';

    students.forEach(student => {
        const tr = document.createElement('tr');
        tr.className = "hover:bg-gray-50 transition";

        const subjectsList = student.subjects && student.subjects.length > 0 
            ? student.subjects.map(sub => `<span class="bg-teal-100 text-teal-800 px-2 py-0.5 rounded text-xs font-medium mr-1">${sub.name}</span>`).join(' ') 
            : '<span class="text-gray-400 italic">None</span>';

        tr.innerHTML = `
            <td class="px-6 py-4 whitespace-nowrap font-medium text-gray-900">${student.name}</td>
            <td class="px-6 py-4 whitespace-nowrap text-gray-500">${student.email}</td>
            <td class="px-6 py-4 text-gray-500">${subjectsList}</td>
        `;
        tbody.appendChild(tr);
    });
}

function populateCourseStudentsTable(students) {
    const tbody = document.querySelector('#course-students-table tbody');
    if (!tbody) return;
    tbody.innerHTML = '';

    const courseMap = {}; 

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
        tbody.innerHTML = '<tr><td colspan="3" class="px-6 py-8 text-center text-gray-400 italic">No courses with enrolled students found.</td></tr>';
        return;
    }

    courses.forEach(item => {
        const tr = document.createElement('tr');
        tr.className = "hover:bg-gray-50 transition";
        
        const studentsList = item.students.join(', ');

        tr.innerHTML = `
            <td class="px-6 py-4 whitespace-nowrap font-mono text-xs font-bold text-teal-700">
                <span class="bg-teal-50 px-2 py-1 rounded border border-teal-100">${item.course.code}</span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap font-medium text-gray-900">${item.course.name}</td>
            <td class="px-6 py-4 text-gray-500">${studentsList}</td>
        `;
        tbody.appendChild(tr);
    });
}
