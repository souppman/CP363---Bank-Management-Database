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
-- REQUIRED VIEWS
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

-- ===========================
-- ADVANCED QUERIES (A5)
-- ===========================

/*== 1. Complex Customer Financial Analysis ==*/
-- Join and set operations with statistical analysis
SELECT 
    C.CustomerID,
    C.Name,
    COUNT(DISTINCT A.AccountID) as TotalAccounts,
    SUM(A.Balance) as TotalBalance,
    (SELECT COUNT(*) FROM Loan L WHERE L.CustomerID = C.CustomerID) as ActiveLoans,
    (SELECT SUM(Amount) FROM Loan L WHERE L.CustomerID = C.CustomerID) as TotalLoanAmount,
    CASE 
        WHEN SUM(A.Balance) > 50000 THEN 'High Value'
        WHEN SUM(A.Balance) > 20000 THEN 'Medium Value'
        ELSE 'Standard'
    END as CustomerSegment
FROM Customer C
LEFT JOIN Account A ON C.CustomerID = A.CustomerID
GROUP BY C.CustomerID, C.Name
HAVING COUNT(DISTINCT A.AccountID) >= 1
ORDER BY TotalBalance DESC;

/*== 2. Transaction Trend Analysis with Moving Averages ==*/
-- Window functions for statistical analysis
SELECT 
    T.AccountID,
    T.TransactionDate,
    T.Amount,
    T.TransactionType,
    AVG(T.Amount) OVER (
        PARTITION BY T.AccountID 
        ORDER BY T.TransactionDate 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) as MovingAverage,
    RANK() OVER (
        PARTITION BY T.AccountID 
        ORDER BY T.Amount DESC
    ) as TransactionRank
FROM Transactions T
ORDER BY T.AccountID, T.TransactionDate;

/*== 3. Comprehensive Branch Performance Metrics ==*/
-- Complex joins and aggregations
SELECT 
    B.BranchName,
    COUNT(DISTINCT E.EmployeeID) as EmployeeCount,
    COUNT(DISTINCT A.ATMID) as ATMCount,
    (
        SELECT COUNT(DISTINCT C.CustomerID)
        FROM Customer C
        JOIN Account Acc ON C.CustomerID = Acc.CustomerID
        JOIN Card Cd ON Acc.AccountID = Cd.AccountID
        WHERE Cd.CardStatus = 'Active'
    ) as ActiveCustomers,
    COALESCE(SUM(T.Amount), 0) as TotalTransactions,
    DENSE_RANK() OVER (ORDER BY COUNT(DISTINCT E.EmployeeID) DESC) as BranchRank
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

/*== 4. Customer Risk Assessment ==*/
-- Statistical aggregation with complex joins
SELECT 
    C.CustomerID,
    C.Name,
    COUNT(DISTINCT L.LoanID) as TotalLoans,
    SUM(L.Amount) as TotalLoanAmount,
    AVG(L.InterestRate) as AvgInterestRate,
    (
        SELECT COUNT(*) 
        FROM Complaint Comp 
        WHERE Comp.CustomerID = C.CustomerID
    ) as ComplaintCount,
    NTILE(4) OVER (ORDER BY SUM(L.Amount) DESC) as RiskQuartile
FROM Customer C
LEFT JOIN Loan L ON C.CustomerID = L.CustomerID
GROUP BY C.CustomerID, C.Name
HAVING TotalLoans > 0;

/*== 5. Product Usage Patterns ==*/
-- Set operations and complex grouping
SELECT CardType, CustomerCount, 'Card' as ProductType
FROM (
    SELECT 
        CT.Type as CardType,
        COUNT(DISTINCT C.CustomerID) as CustomerCount
    FROM Card C
    JOIN CardType CT ON C.CardID = CT.CardID
    GROUP BY CT.Type
) as CardUsers
UNION ALL
SELECT AccountType, CustomerCount, 'Account' as ProductType
FROM (
    SELECT 
        AT.Type as AccountType,
        COUNT(DISTINCT A.CustomerID) as CustomerCount
    FROM Account A
    JOIN AccountType AT ON A.AccountID = AT.AccountID
    GROUP BY AT.Type
) as AccountUsers
ORDER BY CustomerCount DESC;

/*== 6. Transaction Pattern Analysis ==*/
-- Time-based analysis with window functions
SELECT 
    DATE_FORMAT(TransactionDate, '%Y-%m') as Month,
    TransactionType,
    COUNT(*) as TransactionCount,
    SUM(Amount) as TotalAmount,
    AVG(Amount) as AvgAmount,
    SUM(SUM(Amount)) OVER (
        PARTITION BY TransactionType 
        ORDER BY DATE_FORMAT(TransactionDate, '%Y-%m')
    ) as RunningTotal
FROM Transactions
GROUP BY DATE_FORMAT(TransactionDate, '%Y-%m'), TransactionType
ORDER BY Month, TransactionType;

/*== 7. Customer Service Performance ==*/
-- Complex aggregation with recursive elements
WITH RECURSIVE MonthSequence AS (
    SELECT MIN(ComplaintDate) as Date
    FROM Complaint
    UNION ALL
    SELECT DATE_ADD(Date, INTERVAL 1 MONTH)
    FROM MonthSequence
    WHERE Date < (SELECT MAX(ComplaintDate) FROM Complaint)
)
SELECT 
    DATE_FORMAT(MS.Date, '%Y-%m') as Month,
    COUNT(C.ComplaintID) as ComplaintCount,
    AVG(CASE 
        WHEN C.Status = 'Resolved' THEN 1
        ELSE 0
    END) * 100 as ResolutionRate
FROM MonthSequence MS
LEFT JOIN Complaint C ON DATE_FORMAT(MS.Date, '%Y-%m') = DATE_FORMAT(C.ComplaintDate, '%Y-%m')
GROUP BY DATE_FORMAT(MS.Date, '%Y-%m')
ORDER BY Month;

-- ===========================
-- ADVANCED VIEWS (A5)
-- ===========================

/*== View 1: CustomerRiskProfile ==*/
-- Using subquery in columns
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

/*== View 2: BranchPerformanceAnalytics ==*/
-- Using subquery in FROM clause
CREATE OR REPLACE VIEW BranchPerformanceAnalytics AS
SELECT 
    BranchStats.*,
    RANK() OVER (ORDER BY TotalTransactions DESC) as TransactionRank,
    RANK() OVER (ORDER BY CustomerCount DESC) as CustomerRank
FROM (
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
        COALESCE(SUM(T.Amount), 0) as TotalTransactions
    FROM Branch B
    LEFT JOIN Employee E ON B.BranchID = E.BranchID
    LEFT JOIN ATM A ON B.BranchID = A.BranchID
    LEFT JOIN Card C ON B.BranchID = (
        SELECT Card.CardID FROM Card 
        WHERE Card.CustomerID IN (
            SELECT Account.CustomerID FROM Account 
            WHERE Account.AccountID IN (
                SELECT Transactions.AccountID FROM Transactions
            )
        )
    )
    LEFT JOIN Transactions T ON C.CardID = (
        SELECT Card.CardID FROM Card 
        WHERE Card.AccountID = T.AccountID
    )
    GROUP BY B.BranchID, B.BranchName
) as BranchStats;

/*== View 3: CustomerSegmentation ==*/
-- Using subquery in WHERE clause
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
WHERE C.CustomerID IN (
    SELECT DISTINCT CustomerID
    FROM Account
    WHERE Balance > (
        SELECT AVG(Balance) * 0.5
        FROM Account
    )
)
GROUP BY C.CustomerID, C.Name
HAVING TotalBalance > 0
ORDER BY TotalBalance DESC;

-- ===========================
-- EXECUTION PLAN ANALYSIS
-- ===========================

-- To analyze the execution plan for the Complex Customer Financial Analysis query:
-- EXPLAIN ANALYZE
SELECT 
    C.CustomerID,
    C.Name,
    COUNT(DISTINCT A.AccountID) as TotalAccounts,
    SUM(A.Balance) as TotalBalance,
    (SELECT COUNT(*) FROM Loan L WHERE L.CustomerID = C.CustomerID) as ActiveLoans,
    (SELECT SUM(Amount) FROM Loan L WHERE L.CustomerID = C.CustomerID) as TotalLoanAmount
FROM Customer C
LEFT JOIN Account A ON C.CustomerID = A.CustomerID
GROUP BY C.CustomerID, C.Name
HAVING COUNT(DISTINCT A.AccountID) >= 1
ORDER BY TotalBalance DESC;





