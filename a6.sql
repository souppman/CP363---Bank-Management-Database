-- ===========================
-- BANKING SYSTEM DATABASE - ASSIGNMENT 6
-- ===========================

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
    ComplaintDate DATE NOT NULL DEFAULT (CURRENT_DATE()),
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
    StartDate DATE NOT NULL DEFAULT (CURRENT_DATE()),
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
    (4, 'RRSP'),
    (5, 'Saving'),
    (6, 'Chequing'),
    (7, 'TFSA');

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
-- VIEW CREATION
-- ===========================

/*== CustomerFinancialSummary View ==*/
CREATE OR REPLACE VIEW CustomerFinancialSummary AS
SELECT 
    C.CustomerID,
    C.Name,
    COUNT(DISTINCT A.AccountID) as TotalAccounts,
    SUM(A.Balance) as TotalBalance,
    COUNT(DISTINCT L.LoanID) as ActiveLoans,
    SUM(L.Amount) as TotalLoanAmount,
    COUNT(DISTINCT I.InsuranceID) as InsuranceProducts,
    SUM(I.Premium) as TotalInsurancePremiums
FROM Customer C
LEFT JOIN Account A ON C.CustomerID = A.CustomerID
LEFT JOIN Loan L ON C.CustomerID = L.CustomerID
LEFT JOIN Insurance I ON C.CustomerID = I.CustomerID
GROUP BY C.CustomerID, C.Name;

/*== AccountActivitySummary View ==*/
CREATE OR REPLACE VIEW AccountActivitySummary AS
SELECT 
    A.AccountID,
    C.Name as CustomerName,
    AT.Type as AccountType,
    A.Balance,
    COUNT(T.TransactionID) as TransactionCount,
    SUM(CASE WHEN T.TransactionType = 'Deposit' THEN T.Amount ELSE 0 END) as TotalDeposits,
    SUM(CASE WHEN T.TransactionType = 'Withdrawal' THEN T.Amount ELSE 0 END) as TotalWithdrawals,
    MAX(T.TransactionDate) as LastTransactionDate
FROM Account A
JOIN Customer C ON A.CustomerID = C.CustomerID
LEFT JOIN AccountType AT ON A.AccountID = AT.AccountID
LEFT JOIN Transactions T ON A.AccountID = T.AccountID
GROUP BY A.AccountID, C.Name, AT.Type, A.Balance;

/*== BranchPerformanceMetrics View ==*/
CREATE OR REPLACE VIEW BranchPerformanceMetrics AS
SELECT 
    B.BranchName,
    COUNT(DISTINCT E.EmployeeID) as EmployeeCount,
    COUNT(DISTINCT A.ATMID) as ATMCount,
    COUNT(DISTINCT C.CustomerID) as CustomerCount,
    SUM(T.Amount) as TotalDeposits,
    COUNT(DISTINCT L.LoanID) as ActiveLoans,
    SUM(L.Amount) as TotalLoanAmount
FROM Branch B
LEFT JOIN Employee E ON B.BranchID = E.BranchID
LEFT JOIN ATM A ON B.BranchID = A.BranchID
LEFT JOIN Card Cd ON B.BranchID = (
    SELECT BranchID FROM Employee WHERE EmployeeID = 1
)
LEFT JOIN Customer C ON Cd.CustomerID = C.CustomerID
LEFT JOIN Account Acc ON C.CustomerID = Acc.CustomerID
LEFT JOIN Transactions T ON Acc.AccountID = T.AccountID AND T.TransactionType = 'Deposit'
LEFT JOIN Loan L ON C.CustomerID = L.CustomerID AND L.Status = 'Active'
GROUP BY B.BranchName;

/*== CustomerRiskProfile View ==*/
CREATE OR REPLACE VIEW CustomerRiskProfile AS
SELECT 
    C.CustomerID,
    C.Name,
    (
        SELECT COUNT(*) 
        FROM Loan L 
        WHERE L.CustomerID = C.CustomerID AND L.Status = 'Active'
    ) as ActiveLoans,
    (
        SELECT SUM(Amount) 
        FROM Loan L 
        WHERE L.CustomerID = C.CustomerID
    ) as TotalLoanAmount,
    (
        SELECT COUNT(*) 
        FROM Complaint Comp 
        WHERE Comp.CustomerID = C.CustomerID AND Comp.Status = 'Open'
    ) as OpenComplaints,
    (
        SELECT AVG(Amount) 
        FROM Transactions T 
        JOIN Account A ON T.AccountID = A.AccountID 
        WHERE A.CustomerID = C.CustomerID
    ) as AvgTransactionAmount,
    CASE 
        WHEN (SELECT COUNT(*) FROM Loan L WHERE L.CustomerID = C.CustomerID) > 2 THEN 'High'
        WHEN (SELECT COUNT(*) FROM Complaint Comp WHERE Comp.CustomerID = C.CustomerID) > 1 THEN 'Medium'
        ELSE 'Low'
    END as RiskLevel
FROM Customer C;

/*== BranchPerformanceAnalytics View ==*/
CREATE OR REPLACE VIEW BranchPerformanceAnalytics AS
SELECT 
    B.BranchID,
    B.BranchName,
    COUNT(DISTINCT E.EmployeeID) as EmployeeCount,
    COUNT(DISTINCT A.ATMID) as ATMCount,
    (
        SELECT COUNT(DISTINCT C.CustomerID) 
        FROM Customer C
        JOIN Account Acc ON C.CustomerID = Acc.CustomerID
        JOIN Card Cd ON Acc.AccountID = Cd.AccountID
        WHERE Cd.CardStatus = 'Active'
    ) as CustomerCount,
    COALESCE(SUM(T.Amount), 0) as TotalTransactions,
    (SELECT COUNT(*) + 1 FROM (
        SELECT COUNT(DISTINCT E2.EmployeeID) as EmpCount
        FROM Branch B2
        LEFT JOIN Employee E2 ON B2.BranchID = E2.BranchID
        GROUP BY B2.BranchID
        HAVING EmpCount > COUNT(DISTINCT E.EmployeeID)
    ) as RankTable) as EmployeeRank
FROM Branch B
LEFT JOIN Employee E ON B.BranchID = E.BranchID
LEFT JOIN ATM A ON B.BranchID = A.BranchID
LEFT JOIN Card C ON C.CustomerID IN (
    SELECT DISTINCT CustomerID 
    FROM Account 
    WHERE AccountID IN (
        SELECT AccountID 
        FROM Transactions
    )
)
LEFT JOIN Transactions T ON T.AccountID IN (
    SELECT AccountID 
    FROM Card 
    WHERE CardID = C.CardID
)
GROUP BY B.BranchID, B.BranchName;

/*== CustomerSegmentation View ==*/
CREATE OR REPLACE VIEW CustomerSegmentation AS
SELECT 
    C.CustomerID,
    C.Name,
    SUM(A.Balance) as TotalBalance,
    COUNT(DISTINCT A.AccountID) as AccountCount,
    COUNT(DISTINCT L.LoanID) as LoanCount,
    COUNT(DISTINCT I.InsuranceID) as InsuranceCount
FROM Customer C
LEFT JOIN Account A ON C.CustomerID = A.CustomerID
LEFT JOIN Loan L ON C.CustomerID = L.CustomerID
LEFT JOIN Insurance I ON C.CustomerID = I.CustomerID
GROUP BY C.CustomerID, C.Name
ORDER BY TotalBalance DESC;

-- ===========================
-- INDEXES FOR PERFORMANCE
-- ===========================

-- Indexes for frequently joined columns
CREATE INDEX idx_account_customer ON Account(CustomerID);
CREATE INDEX idx_transaction_account ON Transactions(AccountID);
CREATE INDEX idx_card_customer ON Card(CustomerID);
CREATE INDEX idx_card_account ON Card(AccountID);
CREATE INDEX idx_loan_customer ON Loan(CustomerID);
CREATE INDEX idx_insurance_customer ON Insurance(CustomerID);
CREATE INDEX idx_complaint_customer ON Complaint(CustomerID);
CREATE INDEX idx_employee_branch ON Employee(BranchID);
CREATE INDEX idx_atm_branch ON ATM(BranchID);

-- Indexes for frequently filtered columns
CREATE INDEX idx_transaction_type ON Transactions(TransactionType);
CREATE INDEX idx_transaction_date ON Transactions(TransactionDate);
CREATE INDEX idx_card_status ON Card(CardStatus);
CREATE INDEX idx_loan_status ON Loan(Status);
CREATE INDEX idx_complaint_status ON Complaint(Status);
CREATE INDEX idx_atm_status ON ATM(Status);

-- ===========================
-- SAMPLE QUERIES FOR TESTING
-- ===========================

-- 1. Customer Financial Summary
-- SELECT * FROM CustomerFinancialSummary;

-- 2. Account Activity Summary
-- SELECT * FROM AccountActivitySummary;

-- 3. Branch Performance Metrics
-- SELECT * FROM BranchPerformanceMetrics;

-- 4. Customer Risk Profile
-- SELECT * FROM CustomerRiskProfile;

-- 5. Branch Performance Analytics
-- SELECT * FROM BranchPerformanceAnalytics;

-- 6. Customer Segmentation
-- SELECT * FROM CustomerSegmentation; 