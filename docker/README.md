# Employee Management System

A full-stack employee management application with CRUD operations, built with Node.js, MySQL, and Docker.

## Features

- ✨ Modern, responsive UI with gradient design
- 👥 Complete employee management (Create, Read, Update, Delete)
- 🔄 Real-time synchronization between UI and database
- 🐳 Fully containerized with Docker Compose
- 💾 MySQL database with persistent storage
- 🎨 Beautiful animations and smooth transitions

## Tech Stack

- **Frontend**: HTML, CSS, Vanilla JavaScript
- **Backend**: Node.js, Express.js
- **Database**: MySQL 8.0
- **Containerization**: Docker & Docker Compose

## Prerequisites

- Docker
- Docker Compose

## Quick Start

1. **Clone or navigate to the project directory**
   ```bash
   cd small_project
   ```

2. **Start the application**
   ```bash
   docker-compose up --build
   ```

3. **Access the application**
   - Open your browser and go to: `http://localhost:3000`
   - The database will be automatically initialized with sample data

4. **Stop the application**
   ```bash
   docker-compose down
   ```

## Project Structure

```
small_project/
├── backend/               # Node.js API server
│   ├── server.js          # REST API logic
│   ├── db.js              # Database connection
│   ├── package.json       # Dependencies
│   └── Dockerfile         # API container
├── nginx/                 # Nginx Web Server
│   ├── default.conf       # Nginx config
│   └── public/            # Frontend files (HTML, CSS, JS)
├── database/
│   └── init.sql           # Database initialization
├── docker-compose.yml     # Container orchestration
└── README.md
```

## API Endpoints

- `GET /api/employees` - Get all employees
- `GET /api/employees/:id` - Get single employee
- `POST /api/employees` - Create new employee
- `PUT /api/employees/:id` - Update employee
- `DELETE /api/employees/:id` - Delete employee

## Database Schema

**employees** table:
- `id` - Primary key (auto-increment)
- `name` - Employee name (required)
- `email` - Email address (required, unique)
- `phone` - Phone number
- `department` - Department name
- `position` - Job position
- `created_at` - Timestamp

## Usage

### Adding an Employee
1. Click "Add New Employee" button
2. Fill in the employee details
3. Click "Save Employee"
4. Employee will appear in the list immediately

### Editing an Employee
1. Click "Edit" button next to an employee
2. Modify the details
3. Click "Update Employee"

### Deleting an Employee
1. Click "Delete" button next to an employee
2. Confirm the deletion
3. Employee will be removed from the list

## Development

To make changes to the application:

1. Modify the source files
2. Rebuild and restart containers:
   ```bash
   docker-compose up --build
   ```

## Troubleshooting

**Database connection issues:**
- Wait a few seconds for MySQL to fully initialize
- Check logs: `docker-compose logs mysql-db`

**Port already in use:**
- Change the port mapping in `docker-compose.yml`
- Example: `"3001:3000"` instead of `"3000:3000"`

**Clear all data and restart:**
```bash
docker-compose down -v
docker-compose up --build
```

## License

MIT
