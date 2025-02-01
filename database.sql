CREATE TABLE students (
    id INTEGER PRIMARY KEY,
    name TEXT,
    email TEXT,
    ssn TEXT,
    gpa REAL,
    courses TEXT
);

CREATE TABLE financials (
    id INTEGER PRIMARY KEY,
    partner_name TEXT,
    amount REAL,
    transaction_date TEXT,
    purpose TEXT
);

CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    username TEXT,
    password TEXT
);

INSERT INTO students (name, email, ssn, gpa, courses) VALUES 
('Alice Smith', 'alice@watermelon.poly', '123-45-6789', 3.8, 'Math,CS,Physics'),
('Bob Johnson', 'bob@watermelon.poly', '987-65-4321', 3.2, 'Engineering,Chemistry');

INSERT INTO financials (partner_name, amount, transaction_date, purpose) VALUES
('Tech Corp', 150000.00, '2023-01-15', 'Research Grant'),
('Builders LLC', -25000.50, '2023-02-20', 'Facility Maintenance');

INSERT INTO users (username, password) VALUES
('admin', '49a14e33385e7d5bd971d803cb708bc1');
