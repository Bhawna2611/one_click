-- Create database
CREATE DATABASE IF NOT EXISTS employee_db;
USE employee_db;

-- Create employees table
CREATE TABLE IF NOT EXISTS employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    department VARCHAR(100),
    position VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO employees (name, email, phone, department, position) VALUES
('John Doe', 'john.doe@example.com', '+1-555-0101', 'Engineering', 'Software Engineer'),
('Jane Smith', 'jane.smith@example.com', '+1-555-0102', 'Marketing', 'Marketing Manager'),
('Bob Johnson', 'bob.johnson@example.com', '+1-555-0103', 'Sales', 'Sales Representative');
