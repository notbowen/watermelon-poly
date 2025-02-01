const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const bodyParser = require('body-parser');
const app = express();

const { fork } = require('child_process')

// Setup database
const db = new sqlite3.Database('./watermelon.db');

// Vulnerable merge function
const merge = (target, source) => {
    for (let key in source) {
        if (typeof target[key] === 'object' && typeof source[key] === 'object') {
            merge(target[key], source[key]);
        } else {
            target[key] = source[key];
        }
    }
    return target;
};

// Middleware
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.static('public'));
app.set('view engine', 'ejs');

// Routes
app.get('/', (req, res) => res.render('home'));

app.get('/login', (req, res) => res.render('login'));

app.post('/login', (req, res) => {
    const userInput = req.body;
    let user = {};

    merge(user, userInput);

    const logProcess = fork('./logAuth.js')
    logProcess.send({ username: user.username, ipAddress: req.ip })

    db.get(
        'SELECT * FROM users WHERE username = ? AND password = ?',
        [user.username, user.password],
        (err, row) => {
            if (row) {
                res.redirect('/dashboard');
            } else {
                res.send('Invalid credentials');
            }
        }
    );
});

app.get('/dashboard', (req, res) => {
    db.all('SELECT * FROM students', (err, students) => {
        db.all('SELECT * FROM financials', (err, financials) => {
            res.render('dashboard', { students, financials });
        });
    });
});

app.listen(3000, () => console.log('Server running on port 3000'));
