const baseUrl = "http://localhost:8080/courses";

// Add Course
document.getElementById('addCourseForm').addEventListener('submit', function(e) {
    e.preventDefault();
    const courseData = {
        courseId: document.getElementById('courseId').value,
        courseName: document.getElementById('courseName').value,
        strand: document.getElementById('strand').value,
        semester: parseInt(document.getElementById('semester').value, 10) // Convert semester to integer
    };
    
    fetch(`${baseUrl}/addCourse`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(courseData)
    })
    .then(response => {
        if (!response.ok) {
            throw new Error('Network response was not ok');
        }
        return response.json();
    })
    .then(data => {
        document.getElementById('addCourseResponse').innerText = data.message;
        document.getElementById('addCourseForm').reset(); // Clear form fields
    })
    .catch(error => {
        document.getElementById('addCourseResponse').innerText = "Error: " + error.message;
    });
});

// List Courses
document.getElementById('fetchCourses').addEventListener('click', function() {
    fetch(`${baseUrl}/listCourses`)
        .then(response => {
            if (!response.ok) {
                throw new Error('Network response was not ok');
            }
            return response.json();
        })
        .then(data => {
            const courseList = document.getElementById('courseList');
            courseList.innerHTML = '';
            if (data.length === 0) {
                courseList.innerHTML = '<li>No courses available</li>';
            } else {
                data.forEach(course => {
                    const listItem = document.createElement('li');
                    listItem.textContent = `${course.courseId}: ${course.courseName}`;
                    courseList.appendChild(listItem);
                });
            }
        })
        .catch(error => {
            console.error("Error fetching courses: ", error);
        });
});

// Register Student
document.getElementById('registerStudentForm').addEventListener('submit', function(e) {
    e.preventDefault();
    const studentData = {
        studentId: document.getElementById('studentId').value,
        name: document.getElementById('studentName').value,
        registeredCourses: [document.getElementById('registeredCourse').value]
    };
    
    fetch(`${baseUrl}/registerStudent`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(studentData)
    })
    .then(response => {
        if (!response.ok) {
            throw new Error('Network response was not ok');
        }
        return response.json();
    })
    .then(data => {
        document.getElementById('registerResponse').innerText = data.message;
        document.getElementById('registerStudentForm').reset(); // Clear form fields
    })
    .catch(error => {
        document.getElementById('registerResponse').innerText = "Error: " + error.message;
    });
});

// Get Registered Students
document.getElementById('fetchRegisteredStudents').addEventListener('click', function() {
    const courseId = document.getElementById('courseIdForStudents').value;
    
    fetch(`${baseUrl}/registeredStudents/${courseId}`)
        .then(response => {
            if (!response.ok) {
                throw new Error('Network response was not ok');
            }
            return response.json();
        })
        .then(data => {
            const registeredStudentsList = document.getElementById('registeredStudentsList');
            registeredStudentsList.innerHTML = '';
            if (data.length === 0) {
                registeredStudentsList.innerHTML = '<li>No students registered for this course</li>';
            } else {
                data.forEach(student => {
                    const listItem = document.createElement('li');
                    listItem.textContent = `${student.studentId}: ${student.name}`;
                    registeredStudentsList.appendChild(listItem);
                });
            }
        })
        .catch(error => {
            console.error("Error fetching registered students: ", error);
        });
});

// Deregister Student
document.getElementById('deregisterStudentForm').addEventListener('submit', function(e) {
    e.preventDefault();
    const studentId = document.getElementById('deregisterStudentId').value;
    const courseId = document.getElementById('deregisterCourseId').value;
    
    fetch(`${baseUrl}/deregisterStudent/${studentId}/${courseId}`, {
        method: 'DELETE'
    })
    .then(response => {
        if (!response.ok) {
            throw new Error('Network response was not ok');
        }
        return response.json();
    })
    .then(data => {
        document.getElementById('deregisterResponse').innerText = data.message;
        document.getElementById('deregisterStudentForm').reset(); // Clear form fields
    })
    .catch(error => {
        document.getElementById('deregisterResponse').innerText = "Error: " + error.message;
    });
});
