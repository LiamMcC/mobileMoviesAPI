
const mysql = require('mysql');
var readlineSync = require('readline-sync')


// **********************************  Database Class Start **************************



class Database {
    constructor() {
        this.connection = mysql.createConnection({
            host: '127.0.0.1',
    user: 'root',
    port: '3306',
    password: 'Root',
    database: 'dreamhome',
    connectTimeout: 90000 // 10 seconds
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




// **********************************  Database Class Ends **************************


// **********************************  User Class Start **************************


class User extends Database {
    constructor() {
        super();
    }

    getAllUsers(callback) {
        this.connection.query('SELECT * FROM branch', (err, results) => {
            if (err) throw err;
            callback(results);
            // to understand callback I have explained this at the bottom of the file for you because
            // Liam is a nice guy
        });
    }

    getUserById(id, callback) {
        this.connection.query('SELECT * FROM branch WHERE branchNo = ?', [id], (err, results) => {
            if (err) throw err;
            callback(results);
        });
    }

    insertUser(branchNo, street, city, postcode, callback) {
        this.connection.query('INSERT INTO branch (branchNo, street, city, postcode) VALUES (?, ?, ?, ?)', [branchNo, street, city, postcode], (err, result) => {
            if (err) {
                callback(err);
            } else {
                callback(null);
            }
        });
    }

    


    // You can add more methods for CRUD operations here
}



const user = new User();

    user.getAllUsers((users) => {
        console.log(users) 
    });  

    // user.getUserById("B007", (users) => {
    //     console.log(users) 
    // });  


    var branchNo = readlineSync.question("What Is The branchNo: ")
      var street = readlineSync.question("What Is The street: ")
      var city = readlineSync.question("What Is The city: ")
      var postcode = readlineSync.question("What Is The postcode: ")
        // Assuming you have a method in your class (e.g., User) to insert a user into the database
        user.insertUser(branchNo, street, city, postcode, (err) => {
            if (err) {
                // Handle error, for example, send an error response
                console.log('Error occurred while adding user to the database');
            }
            
            // Redirect to the home page after the user is successfully inserted
            console.log("Done");
        });
       
      



// **********************************  User Class Ends **************************








// **********************************  Code from here **************************

// This route will read from the database
// app.get('/', function(req,res){
//     const user = new User();
//     user.getAllUsers((users) => {
//         res.render('home', { users });
//     });           
// })


// route will render the page to show the add form 
// app.get('/add-user', (req, res) => {
//     res.render('adduser');
   
//   });

// this route will add a user 
// app.post('/add-user', (req, res) => {
//     const user = new User();
//     //const { username, email } = req.body;
//   var username = req.body.username
//   var email = req.body.email
//     // Assuming you have a method in your class (e.g., User) to insert a user into the database
//     user.insertUser(username, email, (err) => {
//         if (err) {
//             // Handle error, for example, send an error response
//             return res.status(500).send('Error occurred while adding user to the database');
//         }
        
//         // Redirect to the home page after the user is successfully inserted
//         res.redirect('/');
//     });
//   });




// **********************************  Code to here **************************

