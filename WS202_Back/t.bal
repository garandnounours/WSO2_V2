import ballerina/http;

type Course record {
    string courseId;
    string courseName;
    string strand;
    int semester;
};

type Student record {
    string studentId;
    string name;
    string[] registeredCourses;
};

// In-memory store for demonstration purposes
map<Course> courseDB = {};
map<Student> studentDB = {};

// Enable CORS globally for this service
@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE"],
        allowHeaders: ["Content-Type"],
        allowCredentials: false
    }
}

service /courses on new http:Listener(8080) {

    // Handle OPTIONS request for all routes
    resource function options .() returns json {
        http:Response res = new;
        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type");
        return {}; // Return an empty JSON object
    }

    // Create a new course
    resource function post addCourse(Course newCourse) returns json {
        courseDB[newCourse.courseId] = newCourse;
        return { message: "Course added successfully" };
    }

    // Get all courses
    resource function get listCourses() returns json {
        json[] courses = [];
        // Iterate through courseDB and collect courses
        foreach string courseId in courseDB.keys() {
            Course course = <Course>courseDB[courseId];
            json courseJson = { 
                "courseId": course.courseId, 
                "courseName": course.courseName, 
                "strand": course.strand, 
                "semester": course.semester 
            };
            courses.push(courseJson);
        }
        return courses;
    }

    // Register a student for a course
    resource function post registerStudent(Student newStudent) returns json {
        // Ensure the student is registered first
        if (!studentDB.hasKey(newStudent.studentId)) {
            studentDB[newStudent.studentId] = newStudent;
        }

        // Retrieve the student record safely
        Student existingStudent = <Student>studentDB[newStudent.studentId];

        // Check if the course exists and register the student
        if (newStudent.registeredCourses.length() > 0 && 
            courseDB.hasKey(newStudent.registeredCourses[0])) {
            
            // Initialize registeredCourses if not already initialized
            if (existingStudent.registeredCourses.length() == 0) {
                existingStudent.registeredCourses = [newStudent.registeredCourses[0]];
            } else {
                // Push the new course to registeredCourses
                existingStudent.registeredCourses.push(newStudent.registeredCourses[0]);
            }
            
            // Update the student record in the studentDB
            studentDB[existingStudent.studentId] = existingStudent;
            return { message: "Student registered successfully" };
        }

        return { message: "Course not found" };
    }

    // Get registered students for a specific course
     //Get registered students for a course
  resource function get registeredStudents/[string courseId]() returns json[] {
    json[] registered = [];
    
    // Iterate over the keys of studentDB
    foreach string studentId in studentDB.keys() {
        Student student = studentDB[studentId] ?: {studentId: "", registeredCourses: [], name: ""}; // Retrieve the student record

        // Check if the student is registered for the course
        foreach string registeredCourse in student.registeredCourses {
            if (registeredCourse == courseId) {
                // Convert student record to json manually
                json studentJson = {
                    studentId: student.studentId,
                    name: student.name,
                    registeredCourses: student.registeredCourses
                };
                registered.push(studentJson); 
                break; // No need to check other courses once we find a match
            }
        }
    }
    
    return registered;
}

    // Deregister a student from a course
    resource function delete deregisterStudent/[string studentId]/[string courseId]() returns json {
        // Check if student exists in the database
        if (!studentDB.hasKey(studentId)) {
            return { message: "Student not found" }; // Student doesn't exist
        }

        // Check if course exists in the database
        if (!courseDB.hasKey(courseId)) {
            return { message: "Course not found" }; // Course doesn't exist
        }

        // Retrieve the student record
        Student student = <Student>studentDB[studentId];

        // Manually check if the student is registered for the course
        boolean isRegistered = false;
        foreach string course in student.registeredCourses {
            if (course == courseId) {
                isRegistered = true;
                break;
            }
        }

        if (!isRegistered) {
            return { message: "Student is not registered for this course" }; // Not registered for this course
        }

        // Remove the courseId from the student's registeredCourses
        string[] updatedCourses = [];
        foreach string course in student.registeredCourses {
            if (course != courseId) {
                updatedCourses.push(course); // Only add the courses that don't match courseId
            }
        }

        // Update the student's registeredCourses
        studentDB[studentId].registeredCourses = updatedCourses;

        return { message: "Student deregistered successfully" }; // Success
    }
}
