# WSO2_V2
# Student Course Registration System
Author and Owner(s):
Tashinga Ryan Manunure and Team
## Project Overview

The **Student Course Registration System** is a web-based application designed to manage student course registrations. The system allows students to view the courses they are registered for, and it provides functionality to deregister from courses. The backend is built using Ballerina and integrated with MongoDB to persist data, while the frontend offers a user-friendly interface for students and faculty officers to interact with the system.

## Features

1. **Course Management**: 
   - Add new courses to the system through the backend API.
   - Retrieve and list all available courses from the database.
  
2. **Student Registration**:
   - Register a student for one or more courses.
   - Store student details and their registered courses in MongoDB.

3. **Deregister from Courses**:
   - Students can deregister from courses through the frontend.
   - The deregistration is reflected in the MongoDB database.

4. **View Registered Courses**:
   - Students can view all courses they are registered for.
   - The system retrieves full course details from the `courses` collection, even if the student record only stores the course ID.

5. **CORS Support**:
   - Cross-Origin Resource Sharing (CORS) is enabled to allow communication between the frontend (client-side) and backend (server-side) from different origins.

## Architecture

The system is based on a simple architecture comprising the following components:

- **Frontend**: Built using standard HTML, CSS, and JavaScript. It interacts with the backend APIs to display the student's registered courses and provides buttons to deregister from courses.
- **Backend**: Developed using Ballerina, a cloud-native programming language. The backend provides APIs for managing courses and students and integrates with MongoDB for data storage.
- **Database**: MongoDB is used to store both course and student data. The `courses` collection holds detailed course information, while the `students` collection contains student details and the course IDs of the courses they are registered for.

## API Endpoints

1. **POST /courses/addCourse**  
   - Add a new course to the system.  
   - **Request Body**:  
     ```json
     {
       "courseId": "C001",
       "courseName": "Software Engineering",
       "strand": "IT",
       "semester": 2
     }
     ```

2. **GET /courses/listCourses**  
   - List all available courses.

3. **POST /courses/registerStudent**  
   - Register a student for a course.  
   - **Request Body**:  
     ```json
     {
       "studentId": "222002905",
       "name": "John Doe",
       "registeredCourses": ["C001"]
     }
     ```

4. **GET /courses/studentCourses/{studentId}**  
   - Retrieve the registered courses for a student based on their student ID. This also returns full course details for each registered course.

5. **DELETE /courses/deregisterStudent/{studentId}/{courseId}**  
   - Deregister a student from a specific course.

## MongoDB Collections

- **Courses Collection**: Stores detailed information about each course, including course ID, name, strand, and semester.
  ```json
  {
    "courseId": "C001",
    "courseName": "Software Engineering",
    "strand": "IT",
    "semester": 2
  }

## Students Collection: Stores student information, including their student ID, name, and an array of course IDs they are registered for.
{
  "studentId": "222002905",
  "name": "John Doe",
  "registeredCourses": ["C001"]
}
## Technologies Used
Ballerina: Backend services are written in Ballerina, leveraging its powerful HTTP and MongoDB connectors.
MongoDB: A NoSQL database used to store both courses and student information.
HTML/CSS/JavaScript: The frontend is developed using standard web technologies to provide a simple interface for student interaction.

## Installation & Setup
Prerequisites:
Install Ballerina.
Install MongoDB and ensure it is running locally on port 27017.

## Steps:
1. Clone the repository:
git clone <repository-url>

2. Navigate to the backend directory and start the Ballerina service:
bal run

3. Open MongoDB and ensure the courseDB database is created. Create two collections: courses and students.

4. In the frontend folder, open index.html in a browser. The frontend will interact with the backend APIs to fetch and display course data.

## Usage
1. Add courses via the /courses/addCourse endpoint.

2. Register students for courses using the /courses/registerStudent endpoint.

3. Students can view their registered courses by accessing the frontend and can deregister from courses using the "Deregister" button next to each course.

## Future Improvements

1. Add authentication for student login.

2. Implement course search and filtering features.

3. Add functionality for students to register themselves for courses.
   Enhance error handling for API responses.