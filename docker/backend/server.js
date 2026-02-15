const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const path = require('path');
const db = require('./db');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// API Routes

// Get all employees
app.get('/api/employees', async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM employees ORDER BY created_at DESC');
        res.json(rows);
    } catch (error) {
        console.error('Error fetching employees:', error);
        res.status(500).json({ error: 'Failed to fetch employees' });
    }
});

// Get single employee
app.get('/api/employees/:id', async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM employees WHERE id = ?', [req.params.id]);
        if (rows.length === 0) {
            return res.status(404).json({ error: 'Employee not found' });
        }
        res.json(rows[0]);
    } catch (error) {
        console.error('Error fetching employee:', error);
        res.status(500).json({ error: 'Failed to fetch employee' });
    }
});

// Create new employee
app.post('/api/employees', async (req, res) => {
    const { name, email, phone, department, position } = req.body;

    if (!name || !email) {
        return res.status(400).json({ error: 'Name and email are required' });
    }

    try {
        const [result] = await db.query(
            'INSERT INTO employees (name, email, phone, department, position) VALUES (?, ?, ?, ?, ?)',
            [name, email, phone, department, position]
        );

        const [newEmployee] = await db.query('SELECT * FROM employees WHERE id = ?', [result.insertId]);
        res.status(201).json(newEmployee[0]);
    } catch (error) {
        console.error('Error creating employee:', error);
        if (error.code === 'ER_DUP_ENTRY') {
            res.status(400).json({ error: 'Email already exists' });
        } else {
            res.status(500).json({ error: 'Failed to create employee' });
        }
    }
});

// Update employee
app.put('/api/employees/:id', async (req, res) => {
    const { name, email, phone, department, position } = req.body;

    if (!name || !email) {
        return res.status(400).json({ error: 'Name and email are required' });
    }

    try {
        const [result] = await db.query(
            'UPDATE employees SET name = ?, email = ?, phone = ?, department = ?, position = ? WHERE id = ?',
            [name, email, phone, department, position, req.params.id]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Employee not found' });
        }

        const [updatedEmployee] = await db.query('SELECT * FROM employees WHERE id = ?', [req.params.id]);
        res.json(updatedEmployee[0]);
    } catch (error) {
        console.error('Error updating employee:', error);
        if (error.code === 'ER_DUP_ENTRY') {
            res.status(400).json({ error: 'Email already exists' });
        } else {
            res.status(500).json({ error: 'Failed to update employee' });
        }
    }
});

// Delete employee
app.delete('/api/employees/:id', async (req, res) => {
    try {
        const [result] = await db.query('DELETE FROM employees WHERE id = ?', [req.params.id]);

        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Employee not found' });
        }

        res.json({ message: 'Employee deleted successfully' });
    } catch (error) {
        console.error('Error deleting employee:', error);
        res.status(500).json({ error: 'Failed to delete employee' });
    }
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});
