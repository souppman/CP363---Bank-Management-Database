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
    ComplaintDate DATE NOT NULL DEFAULT (CURRENT_DATE()),  -- Changed from CURRENT_TIMESTAMP
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
    StartDate DATE NOT NULL DEFAULT (CURRENT_DATE()),  -- Changed from CURRENT_TIMESTAMP
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
-- 1. First, insert Customers (no dependencies)
INSERT INTO Customer (Name, Address, Email, PhoneNumber)
VALUES 
    ('John Doe', '123 Main St', 'johndoe@email.com', '555-1234'),
    ('Jane Smith', '456 Elm St', 'janesmith@email.com', '555-5678'),
    ('Alice Johnson', '789 Maple Ave', 'alice@email.com', '555-9101'),
    ('Bob Williams', '101 Oak St', 'bob@email.com', '555-1213');

-- 2. Then Accounts (depends on Customer)
INSERT INTO Account (Balance, CustomerID)
VALUES 
    (5000.00, 1), 
    (12000.00, 2),
    (1500.00, 3),
    (7000.00, 4),
    (3000.00, 1),  -- Additional account for John Doe
    (8000.00, 2),  -- Additional account for Jane Smith
    (2000.00, 1);  -- Third account for John Doe

-- 3. Then AccountTypes (depends on Account)
INSERT INTO AccountType (AccountID, Type)
VALUES 
    (1, 'Chequing'),
    (2, 'Saving'),
    (3, 'TFSA'),
    (4, 'RRSP');

-- 4. Then Branches (no dependencies)
INSERT INTO Branch (BranchName, BranchAddress, Phone)
VALUES 
    ('Downtown Branch', '555 Financial St', '111-2222'),
    ('Uptown Branch', '789 Wealth Ave', '333-4444');

-- 5. Then Employees (depends on Branch)
INSERT INTO Employee (Name, Position, Email, Phone, BranchID)
VALUES 
    ('Emily Davis', 'Manager', 'emily@bank.com', '666-7777', 1),
    ('Michael Brown', 'Teller', 'michael@bank.com', '888-9999', 2);

-- 6. Then Cards (depends on Customer and Account)
INSERT INTO Card (ExpiryDate, CardStatus, CustomerID, AccountID)
VALUES 
    ('2026-12-31', 'Active', 1, 1),
    ('2025-06-30', 'Blocked', 2, 2),
    ('2027-03-15', 'Active', 3, 3),
    ('2025-11-22', 'Inactive', 4, 4);

-- 7. Then CardTypes (depends on Card)
INSERT INTO CardType (CardID, Type)
VALUES 
    (1, 'Debit'),
    (2, 'Credit'),
    (3, 'Debit'),
    (4, 'Credit');

-- 8. Then Transactions (depends on Account)
INSERT INTO Transactions (Amount, TransactionType, AccountID, Description)
VALUES 
    (1000.00, 'Deposit', 1, 'Salary Deposit'),
    (200.00, 'Withdrawal', 1, 'ATM Cash Withdrawal'),
    (500.00, 'Transfer', 2, 'Rent Payment'),
    (2500.00, 'Deposit', 3, 'Investment Return'),
    (800.00, 'Deposit', 4, 'Tax Refund');

-- 9. Then Complaints (depends on Customer)
INSERT INTO Complaint (Description, Status, CustomerID, ComplaintDate)
VALUES 
    ('Unauthorized transaction on account', 'Open', 1, CURRENT_DATE()),
    ('ATM swallowed my card', 'Resolved', 2, CURRENT_DATE()),
    ('Loan application taking too long', 'In Progress', 3, CURRENT_DATE()),
    ('Incorrect account balance', 'Closed', 4, CURRENT_DATE());

-- 10. Then Insurance (depends on Customer)
INSERT INTO Insurance (Premium, InsuranceType, StartDate, EndDate, CustomerID)
VALUES 
    (150.00, 'Life', '2024-01-01', '2034-01-01', 1),
    (200.00, 'Health', '2023-06-15', '2033-06-15', 2),
    (300.00, 'Home', '2022-09-10', '2032-09-10', 3);

-- 11. Then Loans (depends on Customer)
INSERT INTO Loan (CustomerID, LoanType, InterestRate, Amount, Status, StartDate)
VALUES 
    (1, 'Home Loan', 3.5, 250000, 'Approved', CURRENT_DATE()),
    (2, 'Car Loan', 5.2, 30000, 'Active', CURRENT_DATE()),
    (3, 'Personal Loan', 7.8, 10000, 'Pending', CURRENT_DATE());

-- 12. Finally ATMs (depends on Branch)
INSERT INTO ATM (Location, Status, BranchID)
VALUES 
    ('Mall Entrance', 'Active', 1),
    ('Downtown Plaza', 'Maintenance', 2);

-- ===========================
-- ESSENTIAL TEST QUERIES
-- ===========================

/*== Customer Card Details Analysis ==*/
SELECT DISTINCT 
    C.Name AS CustomerName,
    A.Balance AS AccountBalance,
    CT.Type AS CardType,
    CD.CardStatus,
    CD.ExpiryDate
FROM Customer C
JOIN Account A ON C.CustomerID = A.CustomerID
JOIN Card CD ON C.CustomerID = CD.CustomerID
JOIN CardType CT ON CD.CardID = CT.CardID
ORDER BY C.Name;

/*== Branch Performance Overview ==*/
SELECT 
    B.BranchName,
    COUNT(E.EmployeeID) AS EmployeeCount,
    COUNT(ATM.ATMID) AS ATMCount
FROM Branch B
LEFT JOIN Employee E ON B.BranchID = E.BranchID
LEFT JOIN ATM ON B.BranchID = ATM.BranchID
GROUP BY B.BranchName;

/*== High Value Customer Analysis ==*/
SELECT 
    C.Name,
    (SELECT COUNT(*) FROM Account A WHERE A.CustomerID = C.CustomerID) AS AccountCount,
    (SELECT COUNT(*) FROM Loan L WHERE L.CustomerID = C.CustomerID) AS LoanCount
FROM Customer C
WHERE C.CustomerID IN (
    SELECT CustomerID 
    FROM Account 
    WHERE Balance > 10000
);

/*== Customer Financial Summary Report ==*/
SELECT 
    CustomerID,
    Name,
    CONCAT(TotalAccounts, ' accounts') as AccountInfo,
    CONCAT('$', FORMAT(TotalBalance, 2)) as TotalBalance,
    CONCAT(ActiveLoans, ' loans') as LoanInfo,
    CONCAT('$', FORMAT(TotalLoanAmount, 2)) as LoanAmount,
    CONCAT(InsuranceProducts, ' policies') as InsuranceInfo,
    CONCAT('$', FORMAT(TotalInsurancePremiums, 2)) as InsurancePremiums
FROM CustomerFinancialSummary
ORDER BY TotalBalance DESC;

/*== Account Activity Metrics ==*/
SELECT 
    AccountID,
    CustomerName,
    AccountType,
    CONCAT('$', FORMAT(Balance, 2)) as CurrentBalance,
    TransactionCount as TotalTransactions,
    CONCAT('$', FORMAT(TotalDeposits, 2)) as Deposits,
    CONCAT('$', FORMAT(TotalWithdrawals, 2)) as Withdrawals,
    DATE_FORMAT(LastTransactionDate, '%Y-%m-%d %H:%i') as LastActivity
FROM AccountActivitySummary
WHERE TransactionCount > 0
ORDER BY Balance DESC;

/*== Branch Performance Summary ==*/
SELECT 
    BranchName,
    EmployeeCount as Staff,
    ATMCount as ATMs,
    CustomerCount as Customers,
    CONCAT('$', FORMAT(TotalDeposits, 2)) as Deposits,
    CONCAT(ActiveLoans, ' (', CONCAT('$', FORMAT(TotalLoanAmount, 2)), ')') as LoanPortfolio
FROM BranchPerformanceMetrics
ORDER BY TotalDeposits DESC;

/*== Account Type Distribution ==*/
SELECT DISTINCT 
    Type AS AccountType,
    COUNT(*) AS TotalAccounts
FROM AccountType
GROUP BY Type
ORDER BY TotalAccounts DESC;

/*== Loan Portfolio Analysis ==*/
SELECT 
    Status AS LoanStatus,
    FORMAT(AVG(Amount), 2) AS AverageLoanAmount,
    COUNT(*) AS LoanCount
FROM Loan
GROUP BY Status
ORDER BY AVG(Amount) DESC;

/*== Multi-Account Customer Report ==*/
SELECT 
    C.Name AS CustomerName,
    COUNT(A.AccountID) AS NumberOfAccounts,
    FORMAT(SUM(A.Balance), 2) AS TotalBalance
FROM Customer C
JOIN Account A ON C.CustomerID = A.CustomerID
GROUP BY C.CustomerID, C.Name
HAVING COUNT(A.AccountID) > 1
ORDER BY COUNT(A.AccountID) DESC;

/*== Transaction Pattern Analysis ==*/
SELECT DISTINCT
    TransactionType,
    COUNT(*) AS TransactionCount,
    FORMAT(AVG(Amount), 2) AS AverageAmount,
    FORMAT(MAX(Amount), 2) AS LargestTransaction
FROM Transactions
GROUP BY TransactionType
ORDER BY TransactionCount DESC;

/*== Card Distribution Summary ==*/
SELECT 
    CT.Type AS CardType,
    C.CardStatus,
    COUNT(DISTINCT C.CustomerID) AS UniqueCustomers
FROM Card C
JOIN CardType CT ON C.CardID = CT.CardID
GROUP BY CT.Type, C.CardStatus
ORDER BY UniqueCustomers DESC;

/*== Database Record Count Summary ==*/
SELECT 'Customers' as Table_Name, COUNT(*) as Record_Count FROM Customer
UNION ALL
SELECT 'Accounts', COUNT(*) FROM Account
UNION ALL
SELECT 'AccountTypes', COUNT(*) FROM AccountType
UNION ALL
SELECT 'Branches', COUNT(*) FROM Branch
UNION ALL
SELECT 'Employees', COUNT(*) FROM Employee
UNION ALL
SELECT 'Cards', COUNT(*) FROM Card
UNION ALL
SELECT 'CardTypes', COUNT(*) FROM CardType
UNION ALL
SELECT 'Transactions', COUNT(*) FROM Transactions
UNION ALL
SELECT 'Complaints', COUNT(*) FROM Complaint
UNION ALL
SELECT 'Insurance', COUNT(*) FROM Insurance
UNION ALL
SELECT 'Loans', COUNT(*) FROM Loan
UNION ALL
SELECT 'ATMs', COUNT(*) FROM ATM;



