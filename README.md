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

### Flutter Components

The codebase in `/frontend_flutter/lib/` is organized logically by layer:

#### 1. Entry Point (`main.dart`)
- **`main.dart`**: Bootstraps the Flutter application. It initializes dependencies (like `provider`), configures app-wide theming, and acts as a router. It reads `shared_preferences` securely to determine if a `studentUser` exists—bypassing the login screen if already authenticated, mapping users directly to the `HomeScreen`.

#### 2. Screens (`screens/`)
- **`auth_screen.dart`**: Provides the UI for user login. It gathers credentials, communicates with the API service to authenticate, and sets the local session via SharedPreferences upon success.
- **`home_screen.dart`**: The main dashboard of the app. Responsible for rendering the list of students, subjects, and other logged-in user experiences. It uses the `Provider` package to watch state changes and redraws widgets efficiently when data updates.

#### 3. Services (`services/`)
- **`api_service.dart`**: The network layer of the app. It abstracts away raw HTTP requests, providing clean asynchronous methods (Futures) to fetch, create, and update students and subjects from the backend API running at `localhost:8080`.

#### 4. Models (`models/`)
- **`student.dart` & `subject.dart`**: Dart data classes. They contain JSON serialization logic (`fromJson` and `toJson`) to easily map standard API JSON payloads into strongly-typed Dart objects. 

---

## 3. Web Dashboard (`frontend-web`)

A minimalistic, static **HTML/CSS/JS** web application serving as an administrative portal or alternate dashboard.

- **Stack**: Vanilla HTML5, CSS3, JavaScript (No frontend frameworks).

### Web Components

The codebase in `/frontend-web/` is organized into static pages and their supporting assets:

#### 1. HTML Pages (Views)
- **`index.html`**: The main administrative dashboard. Provides the user interface containing forms and tables to perform CRUD operations (Add Student, Add Subject, Assign Subjects).
- **`login.html`**: The authentication view where administrators or users log in.
- **`analytics.html`**: A view dedicated to displaying reports or metrics related to students and subjects.

#### 2. JavaScript Logic (`js/`)
- **`auth.js`**: Handles session management and user access control. It writes the `studentUser` key to `localStorage` upon successful login and immediately intercepts unauthenticated users, redirecting them to `login.html` if they try to access protected pages.
- **`app.js`**: The core application logic. It implements the data fetching and DOM manipulation. Utilizing the `Fetch API`, it communicates with the Spring Boot backend (`http://localhost:8080/api`), handles form submissions, and dynamically injects rows into the HTML tables to display students and subjects.
- **`analytics.js`**: Contains isolated logic specific to the analytics dashboard, responsible for fetching analytical endpoints and generating visual metrics.

#### 3. Styling and Assets
- **`css/style.css`**: Contains all custom CSS rules applied across the HTML pages to ensure a consistent, responsive design.
- **`assets/images/`**: Stores static images and icons used within the user interface.
