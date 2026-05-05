# Student Management App - Project Overview

This documentation provides an overview of the Student Management System project, breaking down its primary components and architecture.

## Architecture

This project is a full-stack application featuring a centralized backend API and two separate client implementations: a cross-platform mobile app and a web-based dashboard. 

The project structure is divided into three main folders:
1. `backend/`
2. `frontend_flutter/`
3. `frontend-web/`

---

## 1. Backend API (`backend/student-server`)

The backend is a **Java Spring Boot application** that serves as the core REST API for data persistence and business logic. It follows a standard Layered Architecture pattern (Controller -> Service -> Repository).

- **Stack**: Java 21, Spring Boot, Maven
- **Database**: PostgreSQL
- **Key Dependencies**:
  - `spring-boot-starter-webmvc`: Provides RESTful web service capabilities.
  - `spring-boot-starter-data-jpa`: Handles data persistence and Object-Relational Mapping (ORM).
  - `postgresql`: JDBC driver for PostgreSQL.
  - `lombok`: Reduces boilerplate Java code (getters/setters, constructors).

### Backend Components

The backend codebase (`src/main/java/com/tamim/studentapp/student_server/`) is divided into several structural layers:

#### 1. Controllers (`controller/`)
- **`StudentController.java`**: Acts as the main entry point for client HTTP requests. It exposes REST API endpoints mapped to specific URIs. This component handles routing requests, mapping request body payloads, invoking business logic via Services, and returning structured HTTP responses (JSON) to the Flutter and web applications.

#### 2. Services (`service/`)
- **`StudentService.java`**: Contains the core business logic. It isolates business rules from the Controller and Database layers. It handles operations such as validating input data, orchestrating complex processes (like assigning a Subject to a Student), and calling the appropriate repository methods.

#### 3. Repositories (`repository/`)
- **`StudentRepository.java`** & **`SubjectRepository.java`**: Interfaces connecting the application to the PostgreSQL database. Extending Spring Data JPA interfaces (such as `JpaRepository`), they provide out-of-the-box implementations for standard database interactions (CRUD operations: Create, Read, Update, Delete) without writing raw SQL.

#### 4. Entities / Models (`entity/`)
- **`Student.java`**: The JPA Entity class representing the `students` table in the database. Contains properties such as ID, name, email, credentials, and relationship configurations (e.g., `@OneToMany` or `@ManyToMany`) linking to their enrolled subjects.
- **`Subject.java`**: The JPA Entity class linking to the `subjects` table. Represents the academic courses.

- **Functionality**: Continually runs on `http://localhost:8080`, exposing the complete unified data persistence layer required by all frontend clients.

---

## 2. Flutter Mobile Application (`frontend_flutter`)

A cross-platform mobile (and desktop/web) application built using **Dart / Flutter**. 

- **Stack**: Flutter, Dart SDK `^3.11.5`
- **Key Dependencies**:
  - `http`: For making REST API calls to the Spring Boot backend.
  - `provider`: For state management across widgets.
  - `shared_preferences`: To store local session/authentication state on the device.
- **Key Components**:
  - Entry Point (`lib/main.dart`): Checks `shared_preferences` for an existing user session (`studentUser`). Connects users to the `HomeScreen` if logged in, or the `AuthScreen` if not.
  - `screens/`: Contains the UI logic (`auth_screen.dart`, `home_screen.dart`).
  - `services/`: Contains `api_service.dart` for communicating with the backend.
  - `models/`: Data classes representing `Student` and `Subject`.

---

## 3. Web Dashboard (`frontend-web`)

A minimalistic, static **HTML/CSS/JS** web application serving as an administrative portal or alternate dashboard.

- **Stack**: Vanilla HTML5, CSS3, JavaScript (No frontend frameworks).
- **Structure**:
  - HTML pages (`index.html`, `login.html`, `analytics.html`).
  - JavaScript logic (`js/app.js`, `js/auth.js`, `js/analytics.js`).
- **Functionality**:
  - Uses the Fetch API to connect to the Spring Boot backend (`http://localhost:8080/api`).
  - Authentication: Reads a `studentUser` key out of `localStorage`. Redirects to `login.html` if the user is not authenticated.
  - Features: Forms to Add Student, Add Subject, and Assign Subject to Student. Dynamically renders tables of students and subjects by manipulating the DOM.
