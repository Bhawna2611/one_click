const mysql = require('mysql2');

// Create connection pool
const pool = mysql.createPool({
    host: process.env.DB_HOST || 'mysql-db',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || 'root123',
    database: process.env.DB_NAME || 'employee_db',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// Test connection
pool.getConnection((err, connection) => {
    if (err) {
        console.error('Error connecting to database:', err.message);
        console.log('Retrying in 5 seconds...');
        setTimeout(() => {
            pool.getConnection((err, connection) => {
                if (err) {
                    console.error('Database connection failed:', err.message);
                } else {
                    console.log('Connected to MySQL database successfully!');
                    connection.release();
                }
            });
        }, 5000);
    } else {
        console.log('Connected to MySQL database successfully!');
        connection.release();
    }
});

// Export promise-based pool
module.exports = pool.promise();
