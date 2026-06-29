<p align="center">
  <img src="https://github.com/user-attachments/assets/70c942a4-dd9a-4424-bc23-573b320f9526" alt="Rapid Motors Mockups" width="100%">
</p>

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

## 📋 Prerequisites
Before running the application, ensure you have the following installed on your machine:
* **PHP** (with Composer for Laravel dependencies)
* **Node.js** (for Vue.js and frontend asset management)
* **Database Management System** (e.g., MySQL, MariaDB, or XAMPP)

## ⚡ Quick Start (Automated Setup)
I made setting up the environment as easy as possible. You don't need to manually configure everything—the script handles the heavy lifting.

1. **Launch the development environment:**
   Simply run the `start-dev.bat` file in the root directory.

### What the `start-dev.bat` script does:
* **System Check:** Automatically verifies if **PHP, Composer, and Node.js** are installed. If missing, it provides direct download links to help you get started.
* **Environment Setup:** Creates and configures your `.env` file automatically, prompting you for database credentials (with sensible defaults).
* **Dependency Management:** Automatically installs Laravel (`vendor`) and Frontend (`node_modules`) dependencies.
* **Security & Optimization:** Runs `npm audit fix` for frontend security and generates the `APP_KEY` for Laravel.
* **Database Automation:** Checks your MySQL connection and automatically creates the `rapid_motors` database if it doesn't exist.
* **Server Orchestration:** Opens two dedicated terminals to start the Laravel backend and the Vite frontend simultaneously.

## 📂 Project Structure
```text
/app             # Laravel Controller, Model, and Middleware classes
/resources/js    # Vue.js components and views
/resources/views # Blade templates (SPA entry point)
/tests/Feature   # Functional tests (AuthControllerTest, CarControllerTest)
```

## 🧪 Testing
The project includes comprehensive functional testing via classes located in the Laravel `tests/Feature` directory, which verify authentication processes and CRUD operations.

*Developed as a graduation project for the Software Developer and Tester program at Nagykanizsai SZC Zsigmondy Vilmos Technikum by Nagy Erik (2026)*
