-- ===========================
-- BANKING SYSTEM DATABASE - ASSIGNMENT 7: ALL TABLES WITH 3NF COMPLIANCE
-- ===========================

/*
Use these tables for the database. they are fixed to Third Normal Form (3NF).

THIRD NORMAL FORM (3NF) EXPLANATION:
A table is in 3NF if it meets the following criteria:
1. It is in 2NF (all non-key attributes depend on the whole primary key)
2. No transitive dependencies (no non-key attribute depends on another non-key attribute)
*/

USE BankingSystem4;

-- ===========================
-- CUSTOMER TABLE
-- ===========================

/*
The Customer table is in 3NF because:
- CustomerID is the primary key
- All attributes (Name, Address, Email, PhoneNumber) depend directly on CustomerID
- There are no transitive dependencies
*/

CREATE TABLE Customer (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Address TEXT NOT NULL, 
    Email VARCHAR(255) NOT NULL UNIQUE,
    PhoneNumber VARCHAR(20) NOT NULL UNIQUE 
);

-- ===========================
-- ACCOUNT TABLE
-- ===========================

/*
The Account table is in 3NF because:
- AccountID is the primary key
- All attributes (Balance, CustomerID) depend directly on AccountID
- There are no transitive dependencies
- CustomerID is a foreign key referencing Customer
*/

CREATE TABLE Account (
    AccountID INT AUTO_INCREMENT PRIMARY KEY,
    Balance DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    CustomerID INT NOT NULL, 
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID) ON DELETE CASCADE
);

-- ===========================
-- ACCOUNTTYPE TABLE
-- ===========================

/*
The AccountType table is in 3NF because:
- AccountTypeID is the primary key
- All attributes (AccountID, Type) depend directly on AccountTypeID
- There are no transitive dependencies
- AccountID is a foreign key referencing Account
*/

CREATE TABLE AccountType (
    AccountTypeID INT AUTO_INCREMENT PRIMARY KEY,
    AccountID INT NOT NULL,
    Type ENUM('Chequing', 'Saving', 'TFSA', 'RRSP', 'RESP', 'FHSA') NOT NULL,
    FOREIGN KEY (AccountID) REFERENCES Account(AccountID) ON DELETE CASCADE
);

-- ===========================
-- TRANSACTIONS TABLE
-- ===========================

/*
The Transactions table is in 3NF because:
- TransactionID is the primary key
- All attributes (Amount, TransactionDate, TransactionType, AccountID, Description) 
  depend directly on TransactionID
- There are no transitive dependencies
- AccountID is a foreign key referencing Account
*/

CREATE TABLE Transactions (
    TransactionID INT AUTO_INCREMENT PRIMARY KEY,
    Amount DECIMAL(10,2) NOT NULL CHECK (Amount > 0),
    TransactionDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    TransactionType ENUM('Deposit', 'Withdrawal', 'Transfer') NOT NULL, 
    AccountID INT NOT NULL,
    Description VARCHAR(255),
    FOREIGN KEY (AccountID) REFERENCES Account(AccountID) ON DELETE CASCADE
);

-- ===========================
-- CARD TABLE (MODIFIED FOR 3NF)
-- ===========================

/*
The card table was changed to comply with 3NF by removing CustomerID.
The og table had both CustomerID and AccountID, creating a transitive dependency
since AccountID already links to CustomerID.

The modified card table is in 3NF because:
- CardID is the primary key
- All attributes (ExpiryDate, CardStatus, AccountID) depend directly on CardID
- There are no transitive dependencies
- CustomerID is removed as it can be retrieved through AccountID when needed
- AccountID is a foreign key referencing Account
*/

CREATE TABLE Card (
    CardID INT AUTO_INCREMENT PRIMARY KEY,
    ExpiryDate DATE NOT NULL,
    CardStatus ENUM('Active', 'Inactive', 'Blocked') DEFAULT 'Active',
    AccountID INT NOT NULL,
    FOREIGN KEY (AccountID) REFERENCES Account(AccountID)
);

-- ===========================
-- CARDTYPE TABLE
-- ===========================

/*
The CardType table is in 3NF because:
- CardTypeID is the primary key
- All attributes (CardID, Type) depend directly on CardTypeID
- There are no transitive dependencies
- CardID is a foreign key referencing Card
*/

CREATE TABLE CardType (
    CardTypeID INT AUTO_INCREMENT PRIMARY KEY,
    CardID INT NOT NULL,
    Type ENUM('Debit', 'Credit') NOT NULL,
    FOREIGN KEY (CardID) REFERENCES Card(CardID) ON DELETE CASCADE
);

-- ===========================
-- COMPLAINT TABLE
-- ===========================

/*
The Complaint table is in 3NF because:
- ComplaintID is the primary key
- All attributes (ComplaintDate, Description, Status, CustomerID) depend directly on ComplaintID
- There are no transitive dependencies
- CustomerID is a foreign key referencing Customer
*/

CREATE TABLE Complaint (
    ComplaintID INT AUTO_INCREMENT PRIMARY KEY,
    ComplaintDate DATE NOT NULL DEFAULT (CURRENT_DATE()),
    Description TEXT NOT NULL,
    Status ENUM('Open', 'In Progress', 'Resolved', 'Closed') DEFAULT 'Open', 
    CustomerID INT NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID) ON DELETE CASCADE
);

-- ===========================
-- INSURANCE TABLE
-- ===========================

/*
The Insurance table is in 3NF because:
- InsuranceID is the primary key
- All attributes (Premium, InsuranceType, StartDate, EndDate, CustomerID) depend directly on InsuranceID
- There are no transitive dependencies
- CustomerID is a foreign key referencing Customer
*/

CREATE TABLE Insurance (
    InsuranceID INT AUTO_INCREMENT PRIMARY KEY,
    Premium DECIMAL(10,2) NOT NULL CHECK (Premium > 0),
    InsuranceType VARCHAR(255) NOT NULL,
    StartDate DATE NOT NULL DEFAULT (CURRENT_TIMESTAMP()),
    EndDate DATE,
    CustomerID INT NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

-- ===========================
-- LOANTYPE TABLE (NEW TABLE FOR 3NF)
-- ===========================

/*
The LoanType table was created to comply with 3NF by extracting loan types and their
standard interest rates, which were previously embedded in the Loan table.

The LoanType table is in 3NF because:
- LoanTypeID is the primary key
- All attributes (TypeName, StandardInterestRate) depend directly on LoanTypeID
- There are no transitive dependencies
*/

CREATE TABLE LoanType (
    LoanTypeID INT AUTO_INCREMENT PRIMARY KEY,
    TypeName VARCHAR(50) NOT NULL UNIQUE,
    StandardInterestRate DECIMAL(5,2) NOT NULL CHECK (StandardInterestRate >= 0)
);

-- ===========================
-- LOAN TABLE (MODIFIED FOR 3NF)
-- ===========================

/*
The Loan table was modified to comply with 3NF by replacing the LoanType string with
a reference to the new LoanType table, eliminating the transitive dependency where
InterestRate might depend on LoanType rather than directly on LoanID.

The modified Loan table is in 3NF because:
- LoanID is the primary key
- All attributes (CustomerID, LoanTypeID, InterestRate, Amount, StartDate, EndDate, Status)
  depend directly on LoanID
- There are no transitive dependencies
- CustomerID is a foreign key referencing Customer
- LoanTypeID is a foreign key referencing the new LoanType table
*/

CREATE TABLE Loan (
    LoanID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT NOT NULL,
    LoanTypeID INT NOT NULL,
    InterestRate DECIMAL(5,2) NOT NULL CHECK (InterestRate >= 0),
    Amount DECIMAL(10,2) NOT NULL CHECK (Amount > 0),
    StartDate DATE NOT NULL DEFAULT (CURRENT_DATE()),
    EndDate DATE,
    Status ENUM('Pending', 'Approved', 'Active', 'Closed') DEFAULT 'Pending',
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY (LoanTypeID) REFERENCES LoanType(LoanTypeID)
);

-- ===========================
-- BRANCH TABLE
-- ===========================

/*
The Branch table is in 3NF because:
- BranchID is the primary key
- All attributes (BranchName, BranchAddress, Phone) depend directly on BranchID
- There are no transitive dependencies
*/

CREATE TABLE Branch (
    BranchID INT AUTO_INCREMENT PRIMARY KEY,
    BranchName VARCHAR(255) NOT NULL,
    BranchAddress TEXT NOT NULL,
    Phone VARCHAR(20) NOT NULL
);

-- ===========================
-- EMPLOYEE TABLE
-- ===========================

/*
The Employee table is in 3NF because:
- EmployeeID is the primary key
- All attributes (Name, Position, Email, Phone, BranchID) depend directly on EmployeeID
- There are no transitive dependencies
- BranchID is a foreign key referencing Branch
*/

CREATE TABLE Employee (
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Position VARCHAR(100) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    Phone VARCHAR(20) NOT NULL,
    BranchID INT NOT NULL,
    FOREIGN KEY (BranchID) REFERENCES Branch(BranchID)
);

-- ===========================
-- ATM TABLE
-- ===========================

/*
The ATM table is in 3NF because:
- ATMID is the primary key
- All attributes (Location, Status, BranchID) depend directly on ATMID
- There are no transitive dependencies
- BranchID is a foreign key referencing Branch
*/

CREATE TABLE ATM (
    ATMID INT AUTO_INCREMENT PRIMARY KEY,
    Location TEXT NOT NULL,
    Status ENUM('Active', 'Out of Service', 'Maintenance') DEFAULT 'Active',
    BranchID INT NOT NULL,
    FOREIGN KEY (BranchID) REFERENCES Branch(BranchID)
);

-- ===========================
-- SUMMARY OF 3NF COMPLIANCE
-- ===========================

/*
All tables are now in 3NF because:

1. All tables have a primary key that uniquely identifies each record
2. All non-key attributes in each table depend on the whole primary key
3. No non-key attribute depends on another non-key attribute (no transitive dependencies)

Changes we made:
1. Removing CustomerID from the Card table since this relationship is already
   established through the AccountID foreign key, which eliminated a transitive dependency
2. Creating a separate LoanType table to store loan types and their standard interest rates,
   which eliminated a potential transitive dependency in the Loan table

These changes are to ensure data integrity, reduce redundancy, and improve database performance
while maintaining all the functionality of the original schema.
*/ 