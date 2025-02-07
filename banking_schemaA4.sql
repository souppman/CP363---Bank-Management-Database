-- DROP existing database if it exists
DROP DATABASE IF EXISTS BankingSystem4;
CREATE DATABASE BankingSystem4;
USE BankingSystem4;

-- ===========================
-- TABLE CREATION
-- ===========================

-- Customer Table
CREATE TABLE Customer (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Address TEXT NOT NULL, 
    Email VARCHAR(255) NOT NULL UNIQUE,
    PhoneNumber VARCHAR(20) NOT NULL UNIQUE 
);

-- Account Table
CREATE TABLE Account (
    AccountID INT AUTO_INCREMENT PRIMARY KEY,
    Balance DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    CustomerID INT NOT NULL, 
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID) ON DELETE CASCADE
);

-- AccountType Table
CREATE TABLE AccountType (
    AccountTypeID INT AUTO_INCREMENT PRIMARY KEY,
    AccountID INT NOT NULL,
    Type ENUM('Chequing', 'Saving', 'TFSA', 'RRSP', 'RESP', 'FHSA') NOT NULL,
    FOREIGN KEY (AccountID) REFERENCES Account(AccountID) ON DELETE CASCADE
);

-- Transactions Table
CREATE TABLE Transactions (
    TransactionID INT AUTO_INCREMENT PRIMARY KEY,
    Amount DECIMAL(10,2) NOT NULL CHECK (Amount > 0),
    TransactionDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    TransactionType ENUM('Deposit', 'Withdrawal', 'Transfer') NOT NULL, 
    AccountID INT NOT NULL,
    Description VARCHAR(255),
    FOREIGN KEY (AccountID) REFERENCES Account(AccountID) ON DELETE CASCADE
);

-- Card Table
CREATE TABLE Card (
    CardID INT AUTO_INCREMENT PRIMARY KEY,
    ExpiryDate DATE NOT NULL,
    CardStatus ENUM('Active', 'Inactive', 'Blocked') DEFAULT 'Active', 
    CustomerID INT NOT NULL,
    AccountID INT NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY (AccountID) REFERENCES Account(AccountID)
);

-- CardType Table
CREATE TABLE CardType (
    CardTypeID INT AUTO_INCREMENT PRIMARY KEY,
    CardID INT NOT NULL,
    Type ENUM('Debit', 'Credit') NOT NULL,
    FOREIGN KEY (CardID) REFERENCES Card(CardID) ON DELETE CASCADE
);

-- Complaint Table
CREATE TABLE Complaint (
    ComplaintID INT AUTO_INCREMENT PRIMARY KEY,
    ComplaintDate DATE NOT NULL DEFAULT (CURRENT_TIMESTAMP()),
    Description TEXT NOT NULL,
    Status ENUM('Open', 'In Progress', 'Resolved', 'Closed') DEFAULT 'Open', 
    CustomerID INT NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID) ON DELETE CASCADE
);

-- Insurance Table
CREATE TABLE Insurance (
    InsuranceID INT AUTO_INCREMENT PRIMARY KEY,
    Premium DECIMAL(10,2) NOT NULL CHECK (Premium > 0),
    InsuranceType VARCHAR(255) NOT NULL,
    StartDate DATE NOT NULL DEFAULT (CURRENT_TIMESTAMP()),
    EndDate DATE,
    CustomerID INT NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

-- Loan Table
CREATE TABLE Loan (
    LoanID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT NOT NULL,
    LoanType VARCHAR(50) NOT NULL,
    InterestRate DECIMAL(5,2) NOT NULL CHECK (InterestRate >= 0),
    Amount DECIMAL(10,2) NOT NULL CHECK (Amount > 0),
    StartDate DATE NOT NULL DEFAULT (CURRENT_TIMESTAMP()),
    EndDate DATE,
    Status ENUM('Pending', 'Approved', 'Active', 'Closed') DEFAULT 'Pending',
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

-- Branch Table
CREATE TABLE Branch (
    BranchID INT AUTO_INCREMENT PRIMARY KEY,
    BranchName VARCHAR(255) NOT NULL,
    BranchAddress TEXT NOT NULL,
    Phone VARCHAR(20) NOT NULL
);

-- Employee Table
CREATE TABLE Employee (
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Position VARCHAR(100) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    Phone VARCHAR(20) NOT NULL,
    BranchID INT NOT NULL,
    FOREIGN KEY (BranchID) REFERENCES Branch(BranchID)
);

-- ATM Table
CREATE TABLE ATM (
    ATMID INT AUTO_INCREMENT PRIMARY KEY,
    Location TEXT NOT NULL,
    Status ENUM('Active', 'Out of Service', 'Maintenance') DEFAULT 'Active',
    BranchID INT NOT NULL,
    FOREIGN KEY (BranchID) REFERENCES Branch(BranchID)
);

-- ===========================
-- DATA INSERTION
-- ===========================

-- Insert Customers
INSERT INTO Customer (Name, Address, Email, PhoneNumber)
VALUES ('John Doe', '123 Main St', 'johndoe@email.com', '555-1234'),
       ('Jane Smith', '456 Elm St', 'janesmith@email.com', '555-5678');

-- Insert Accounts
INSERT INTO Account (Balance, CustomerID)
VALUES (5000.00, 1),
       (12000.00, 2);

-- Insert Loans
INSERT INTO Loan (CustomerID, LoanType, InterestRate, Amount, Status)
VALUES (1, 'Home Loan', 3.5, 250000, 'Approved'),
       (2, 'Car Loan', 5.2, 30000, 'Active');

-- ===========================
-- QUERIES
-- ===========================

-- 1. Subquery: Find customers who have taken a loan greater than $100,000
SELECT Name FROM Customer 
WHERE CustomerID IN (SELECT CustomerID FROM Loan WHERE Amount > 100000);

-- 2. Correlated Subquery: Find customers who have more than $10,000 in their account
SELECT Name FROM Customer C
WHERE EXISTS (
    SELECT 1 FROM Account A 
    WHERE A.CustomerID = C.CustomerID AND A.Balance > 10000
);

-- 3. Window Function: Rank loans by amount
SELECT CustomerID, LoanType, Amount,
       RANK() OVER (ORDER BY Amount DESC) AS LoanRank
FROM Loan;

-- 4. List all customers with at least one account
SELECT DISTINCT C.Name FROM Customer C
JOIN Account A ON C.CustomerID = A.CustomerID;

-- 5. Find accounts with transactions above $500
SELECT AccountID FROM Transactions WHERE Amount > 500;

-- 6. Retrieve total loan amount per customer
SELECT CustomerID, SUM(Amount) AS TotalLoanAmount 
FROM Loan GROUP BY CustomerID;

-- 7. Retrieve transactions sorted by date
SELECT * FROM Transactions ORDER BY TransactionDate DESC;

-- 8. Retrieve active customers with a credit card
SELECT DISTINCT C.Name FROM Customer C
JOIN CardType CT ON CT.Type = 'Credit'
JOIN Card CA ON CA.CustomerID = C.CustomerID;

-- 9. Retrieve the total loan amount per loan type
SELECT LoanType, SUM(Amount) FROM Loan GROUP BY LoanType;

-- 10. Retrieve the average interest rate per loan type
SELECT LoanType, AVG(InterestRate) FROM Loan GROUP BY LoanType;

-- ===========================
-- VIEWS
-- ===========================

-- 1. View: Total loans per customer
CREATE VIEW CustomerLoanSummary AS
SELECT C.CustomerID, C.Name, SUM(L.Amount) AS TotalLoanAmount
FROM Customer C
JOIN Loan L ON C.CustomerID = L.CustomerID
GROUP BY C.CustomerID, C.Name;

-- 2. View: Active accounts
CREATE VIEW ActiveAccounts AS
SELECT A.AccountID, C.Name, A.Balance
FROM Account A
JOIN Customer C ON A.CustomerID = C.CustomerID
WHERE A.Balance > 0;

-- 3. View: Transaction summary
CREATE VIEW TransactionSummary AS
SELECT AccountID, SUM(Amount) AS TotalTransactions
FROM Transactions
GROUP BY AccountID;

-- ===========================
-- ADDITIONAL DATA INSERTION
-- ===========================

-- Insert additional Customers (only new, unique entries)
INSERT INTO Customer (Name, Address, Email, PhoneNumber)
VALUES 
    ('Alice Johnson', '789 Maple Ave', 'alice@email.com', '555-9101'),
    ('Bob Williams', '101 Oak St', 'bob@email.com', '555-1213');

-- Insert additional Accounts
INSERT INTO Account (Balance, CustomerID)
VALUES 
    (5000.00, 1), 
    (12000.00, 2),
    (1500.00, 3),
    (7000.00, 4);

-- Insert Account Types
INSERT INTO AccountType (AccountID, Type)
VALUES 
    (1, 'Chequing'),
    (2, 'Saving'),
    (3, 'TFSA'),
    (4, 'RRSP');

-- Insert Transactions
INSERT INTO Transactions (Amount, TransactionType, AccountID, Description)
VALUES 
    (1000.00, 'Deposit', 1, 'Salary Deposit'),
    (200.00, 'Withdrawal', 1, 'ATM Cash Withdrawal'),
    (500.00, 'Transfer', 2, 'Rent Payment'),
    (2500.00, 'Deposit', 3, 'Investment Return'),
    (800.00, 'Deposit', 4, 'Tax Refund');

-- Insert Cards
INSERT INTO Card (ExpiryDate, CardStatus, CustomerID, AccountID)
VALUES 
    ('2026-12-31', 'Active', 1, 1),
    ('2025-06-30', 'Blocked', 2, 2),
    ('2027-03-15', 'Active', 3, 3),
    ('2025-11-22', 'Inactive', 4, 4);

-- Insert Card Types
INSERT INTO CardType (CardID, Type)
VALUES 
    (1, 'Debit'),
    (2, 'Credit'),
    (3, 'Debit'),
    (4, 'Credit');

-- Insert Complaints
INSERT INTO Complaint (Description, Status, CustomerID)
VALUES 
    ('Unauthorized transaction on account', 'Open', 1),
    ('ATM swallowed my card', 'Resolved', 2),
    ('Loan application taking too long', 'In Progress', 3),
    ('Incorrect account balance', 'Closed', 4);

-- Insert Insurance
INSERT INTO Insurance (Premium, InsuranceType, StartDate, EndDate, CustomerID)
VALUES 
    (150.00, 'Life', '2024-01-01', '2034-01-01', 1),
    (200.00, 'Health', '2023-06-15', '2033-06-15', 2),
    (300.00, 'Home', '2022-09-10', '2032-09-10', 3);

-- Insert additional Loans
INSERT INTO Loan (CustomerID, LoanType, InterestRate, Amount, Status)
VALUES 
    (1, 'Home Loan', 3.5, 250000, 'Approved'),
    (2, 'Car Loan', 5.2, 30000, 'Active'),
    (3, 'Personal Loan', 7.8, 10000, 'Pending');

-- Insert Branches
INSERT INTO Branch (BranchName, BranchAddress, Phone)
VALUES 
    ('Downtown Branch', '555 Financial St', '111-2222'),
    ('Uptown Branch', '789 Wealth Ave', '333-4444');

-- Insert Employees
INSERT INTO Employee (Name, Position, Email, Phone, BranchID)
VALUES 
    ('Emily Davis', 'Manager', 'emily@bank.com', '666-7777', 1),
    ('Michael Brown', 'Teller', 'michael@bank.com', '888-9999', 2);

-- Insert ATMs
INSERT INTO ATM (Location, Status, BranchID)
VALUES 
    ('Mall Entrance', 'Active', 1),
    ('Downtown Plaza', 'Maintenance', 2);

-- ===========================
-- TEST FILE 1
-- ===========================

SELECT * FROM Customer;
SELECT * FROM Account;
SELECT * FROM Transactions;
SELECT * FROM Loan;
SELECT B.BranchName, E.Name AS EmployeeName, E.Position
FROM Branch B
JOIN Employee E ON B.BranchID = E.BranchID;

-- ===========================
-- TEST FILE 2
-- ===========================

SELECT Name FROM Customer 
WHERE CustomerID IN (SELECT CustomerID FROM Loan WHERE Amount > 100000);

SELECT Name FROM Customer C
WHERE EXISTS (
    SELECT 1 FROM Account A 
    WHERE A.CustomerID = C.CustomerID AND A.Balance > 10000
);

SELECT CustomerID, LoanType, Amount,
       RANK() OVER (ORDER BY Amount DESC) AS LoanRank
FROM Loan;

SELECT DISTINCT C.Name FROM Customer C
JOIN Account A ON C.CustomerID = A.CustomerID;

SELECT AccountID FROM Transactions WHERE Amount > 500;

SELECT CustomerID, SUM(Amount) AS TotalLoanAmount 
FROM Loan GROUP BY CustomerID;

SELECT * FROM Transactions ORDER BY TransactionDate DESC;

SELECT DISTINCT C.Name FROM Customer C
JOIN CardType CT ON CT.Type = 'Credit'
JOIN Card CA ON CA.CustomerID = C.CustomerID;

SELECT LoanType, SUM(Amount) FROM Loan GROUP BY LoanType;

SELECT LoanType, AVG(InterestRate) FROM Loan GROUP BY LoanType;
