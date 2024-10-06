const baseUrl = "http://localhost:8080/courses";

// List Available Courses
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
        name: document.getElementById('studentName').value, // Add student name
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
