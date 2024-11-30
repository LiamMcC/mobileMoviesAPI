const express = require('express');
const mysql = require('mysql');
const bodyParser = require('body-parser');

// Database Class
class Database {
    constructor() {
        this.connection = mysql.createConnection({
            host: '127.0.0.1',
            user: 'root',
            port: '3306',
            password: 'Root',
            database: 'dreamhome',
            connectTimeout: 90000, // 90 seconds
        });
    }

    connect() {
        this.connection.connect((err) => {
            if (err) throw err;
            console.log('Connected to MySQL database');
        });
    }

    disconnect() {
        this.connection.end((err) => {
            if (err) throw err;
            console.log('Disconnected from MySQL database');
        });
    }
}

// User Class (Inherits from Database)
class User extends Database {
    constructor() {
        super();
    }

    getAllBranches(callback) {
        this.connection.query('SELECT * FROM branch', (err, results) => {
            if (err) throw err;
            callback(results);
        });
    }

    getBranchById(branchNo, callback) {
        this.connection.query('SELECT * FROM branch WHERE branchNo = ?', [branchNo], (err, results) => {
            if (err) throw err;
            callback(results);
        });
    }

    insertBranch(branchNo, street, city, postcode, callback) {
        this.connection.query(
            'INSERT INTO branch (branchNo, street, city, postcode) VALUES (?, ?, ?, ?)',
            [branchNo, street, city, postcode],
            (err, result) => {
                callback(err, result);
            }
        );
    }

    updateBranch(branchNo, street, city, postcode, callback) {
        this.connection.query(
            'UPDATE branch SET street = ?, city = ?, postcode = ? WHERE branchNo = ?',
            [street, city, postcode, branchNo],
            (err, result) => {
                callback(err, result);
            }
        );
    }

    deleteBranch(branchNo, callback) {
        this.connection.query(
            'DELETE FROM branch WHERE branchNo = ?',
            [branchNo],
            (err, result) => {
                callback(err, result);
            }
        );
    }
}

// Initialize User and Connect to Database
const user = new User();
user.connect();

// Express App Setup
const app = express();
const port = 3000;

// Middleware
app.use(bodyParser.json());

// Routes
// Get all branches
app.get('/branches', (req, res) => {
    user.getAllBranches((branches) => {
        res.json({ success: true, branches });
        
    });
    console.log("Boo")
});

// Get a branch by ID
app.get('/branch/:branchNo', (req, res) => {
    const branchNo = req.params.branchNo;
    user.getBranchById(branchNo, (branch) => {
        if (branch.length === 0) {
            res.status(404).json({ success: false, message: 'Branch not found.' });
        } else {
            res.json({ success: true, branch });
        }
    });
});

// Add a new branch
app.post('/branch', (req, res) => {
    const { branchNo, street, city, postcode } = req.body;

    if (!branchNo || !street || !city || !postcode) {
        return res.status(400).json({ success: false, message: 'All fields are required.' });
    }

    user.insertBranch(branchNo, street, city, postcode, (err) => {
        if (err) {
            return res.status(500).json({ success: false, message: 'Error adding branch.' });
        }
        res.status(201).json({ success: true, message: 'Branch added successfully.' });
    });
});

// Update an existing branch
app.put('/branch/:branchNo', (req, res) => {
    const branchNo = req.params.branchNo;
    const { street, city, postcode } = req.body;

    if (!street || !city || !postcode) {
        return res.status(400).json({ success: false, message: 'All fields are required for update.' });
    }

    user.updateBranch(branchNo, street, city, postcode, (err) => {
        if (err) {
            return res.status(500).json({ success: false, message: 'Error updating branch.' });
        }
        res.json({ success: true, message: 'Branch updated successfully.' });
    });
    console.log("I Put")
});

// Delete a branch
app.delete('/branch/:branchNo', (req, res) => {
    const branchNo = req.params.branchNo;

    user.deleteBranch(branchNo, (err) => {
        if (err) {
            return res.status(500).json({ success: false, message: 'Error deleting branch.' });
        }
        res.json({ success: true, message: 'Branch deleted successfully.' });
    });
});

// Start the Server
app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
});
