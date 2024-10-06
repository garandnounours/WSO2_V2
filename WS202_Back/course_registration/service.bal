import ballerina/http;
import ballerinax/mongodb;

// MongoDB connection configuration
mongodb:ConnectionConfig mongoConfig = {
    connection: {
        host: "localhost",
        port: 27017,
        auth: {
            username: "",
            password: ""
        },
        options: {
            sslEnabled: false,
            serverSelectionTimeout: 5000
        }
    },
    databaseName: "courseDB"
};

// MongoDB client instance
mongodb:Client mongoClient = check new (mongoConfig);

// MongoDB collection names
configurable string courseCollection = "courses";
configurable string studentCollection = "students";

// Define the data models
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
    resource function post addCourse(Course newCourse) returns json|error {
        map<json> doc = <map<json>>newCourse.toJson();
        _ = check mongoClient->insert(doc, courseCollection, "");
        return {message: "Course added successfully"};
    }

    // Get all courses
    resource function get listCourses() returns Course[]|error {
        stream<Course, error?> coursesStream = check mongoClient->find(courseCollection, "courseDB", {}, {});
        Course[] courses = check from Course course in coursesStream
            select course;
        return courses;
    }

    // Register a student for a course
    resource function post registerStudent(Student newStudent) returns json|error {
        // Attempt to retrieve the student document from the database
        stream<map<json>, error?> studentDocResult = check mongoClient->find(studentCollection, "courseDB", {studentId: newStudent.studentId}, {});

        // Consume the stream to get the first document
        var studentDoc = studentDocResult.next(); // Fetch the next document from the stream

        // Check if we retrieved a student document
        if (studentDoc is record {|map<json> value;|}) {
            // Prepare the document to update registered courses
            map<json> updateDoc = {"$push": {"registeredCourses": newStudent.registeredCourses[0]}};

            // Update the student's record to add the new course
            _ = check mongoClient->update(updateDoc, studentCollection, "courseDB", {studentId: newStudent.studentId}, true, false);
        } else {
            // If the student does not exist, insert the new student record
            map<json> doc = <map<json>>newStudent.toJson();
            _ = check mongoClient->insert(doc, studentCollection, "");
        }

        return {message: "Student registered successfully"};
    }

    // Get registered students for a specific course
    resource function get registeredStudents/[string courseId]() returns json[]|error {
        map<json> query = { "registeredCourses": { "$in": [courseId] } };
        stream<map<json>, error?> studentsStream = check mongoClient->find(studentCollection, "courseDB", query, {});

        json[] registeredStudents = [];
        record {|map<json> value;|}|error? studentJson;

        while true {
            studentJson = studentsStream.next();
            if (studentJson is error) {
                return studentJson;
            } else if (studentJson is record {|map<json> value;|}) {
                map<json> studentData = studentJson.value;
                Student student = check studentData.cloneWithType(Student);

                registeredStudents.push({
                    studentId: student.studentId,
                    name: student.name,
                    registeredCourses: student.registeredCourses
                });
            } else {
                break;
            }
        }

        return registeredStudents;
    }

    // Deregister a student from a course
    resource function delete deregisterStudent/[string studentId]/[string courseId]() returns map<json>|error {
        stream<map<json>, error?> studentDocResult = check mongoClient->find(studentCollection, "courseDB", {studentId: studentId}, {});

        map<json> studentDoc = check studentDocResult.next() ?: {};
        if studentDoc.length() == 0 {
            return {message: "Student not found"};
        }

        stream<map<json>, error?> courseDocResult = check mongoClient->find(courseCollection, "courseDB", {courseId: courseId}, {});
        var cour = check courseDocResult.next();

        if (cour is record {| map<json> value; |}) {
            map<json> _ = cour.value;
        } else {
            return {message: "Course not found"};
        }

        map<json> updateDoc = {"$pull": {"registeredCourses": courseId}};
        _ = check mongoClient->update(updateDoc, studentCollection, "courseDB", {studentId: studentId}, true, false);

        return {message: "Student deregistered successfully"};
    }

    // NEW FUNCTION: Get registered courses for a student
  resource function get studentCourses/[string studentId]() returns json|error {
    // Step 1: Query MongoDB to find the student's registered courses
    stream<map<json>, error?> studentStream = check mongoClient->find(studentCollection, "courseDB", {studentId: studentId}, {});

    // Fetch the student document
    var studentDoc = studentStream.next();
    if (studentDoc is record {|map<json> value;|}) {
        // Convert the document to a Student record
        map<json> studentData = studentDoc.value;
        Student student = check studentData.cloneWithType(Student);

        // Step 2: Prepare an array to hold the full course details
        json[] courseDetails = [];

        // Step 3: Loop through the registered course codes and fetch full details from the course collection
        foreach var courseId in student.registeredCourses {
            map<json> courseQuery = {courseId: courseId}; // Query to find course by courseId
            stream<map<json>, error?> courseStream = check mongoClient->find(courseCollection, "courseDB", courseQuery, {});
            var courseDoc = courseStream.next();
            
            if (courseDoc is record {|map<json> value;|}) {
                courseDetails.push(courseDoc.value); // Add course details to the array
            }
        }

        // Step 4: Return the student details along with the full course details
        return {
            studentId: student.studentId,
            name: student.name,
            registeredCourses: courseDetails // Return the full course details
        };
    } else {
        return {message: "Student not found"};
    }
}

}
