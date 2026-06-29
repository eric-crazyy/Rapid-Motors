# Rapid Motors

**Rapid Motors** is a modern, streamlined full-stack web application developed for enthusiasts of luxury and classic cars. The platform allows users to browse vehicle listings efficiently, access detailed specifications, and view vehicles through interactive 3D models.

## 🚀 Key Features
* **Vehicle Listing Management:** Modern, card-based interface and intuitive data management for the administration panel.
* **Interactive 3D Display:** Vehicles can be inspected via rotatable 3D models.
* **Dynamic User Experience:** Built with the Vue.js framework, ensuring a fast, responsive, and application-like feel that reacts instantly to user input.
* **Secure Backend:** Robust data handling and authorization logic powered by the Laravel framework.

## 🛠 Technology Stack
* **Frontend:** Vue.js, Vue Router, Pinia, Axios
* **Backend:** Laravel (PHP), RESTful API
* **Database:** MySQL (InnoDB)
* **Development Tools:** VS Code, DBeaver, Trello, Wireframe.cc

## ⚡ Quick Start
To launch the project, execute the `start-dev.bat` file located in the root directory. This will open two command line windows—one for the frontend and one for the backend.
* If the database has not been initialized, the backend command window will prompt you to create it.
* Type `yes` and press Enter.

## 📂 Project Structure
```text
/app             # Laravel Controller, Model, and Middleware classes
/resources/js    # Vue.js components and views
/resources/views # Blade templates (SPA entry point)
/tests/Feature   # Functional tests (AuthControllerTest, CarControllerTest)
