-- ===========================
-- BANKING SYSTEM DATABASE - ASSIGNMENT 7: NORMALIZATION TO 3NF
-- ===========================

-- This script addresses Third Normal Form (3NF) requirements for the banking database

USE BankingSystem4;

-- ===========================
-- 3NF ANALYSIS AND MODIFICATIONS
-- ===========================

/*
THIRD NORMAL FORM (3NF) EXPLANATION:
A table is in 3NF if it meets the following criteria:
1. It is in 2NF (all non-key attributes depend on the whole primary key)
2. No transitive dependencies (no non-key attribute depends on another non-key attribute)

Most tables in the database are already in 3NF. Below are modifications for tables 
that need adjustments to fully comply with 3NF.
*/

-- ===========================
-- ISSUE 1: Card Table Modification
-- ===========================

/*
The Card table has both CustomerID and AccountID, which creates a potential
transitive dependency since AccountID already links to CustomerID.
This violates 3NF because CustomerID depends on AccountID, not directly on CardID.

Solution: Remove CustomerID from the Card table since this relationship is already
established through the AccountID foreign key.
*/

-- Step 1: Create a temporary table to store card data
CREATE TABLE Card_Temp (
    CardID INT PRIMARY KEY,
    ExpiryDate DATE NOT NULL,
    CardStatus ENUM('Active', 'Inactive', 'Blocked') DEFAULT 'Active',
    AccountID INT NOT NULL,
    FOREIGN KEY (AccountID) REFERENCES Account(AccountID)
);

-- Step 2: Copy data to the temporary table
INSERT INTO Card_Temp (CardID, ExpiryDate, CardStatus, AccountID)
SELECT CardID, ExpiryDate, CardStatus, AccountID FROM Card;

-- Step 3: Drop the old table and constraints
DROP TABLE CardType; -- Drop dependent table first
DROP TABLE Card;

-- Step 4: Create the new Card table in 3NF
CREATE TABLE Card (
    CardID INT AUTO_INCREMENT PRIMARY KEY,
    ExpiryDate DATE NOT NULL,
    CardStatus ENUM('Active', 'Inactive', 'Blocked') DEFAULT 'Active',
    AccountID INT NOT NULL,
    FOREIGN KEY (AccountID) REFERENCES Account(AccountID)
);

-- Step 5: Restore the data
INSERT INTO Card (CardID, ExpiryDate, CardStatus, AccountID)
SELECT CardID, ExpiryDate, CardStatus, AccountID FROM Card_Temp;

-- Step 6: Drop the temporary table
DROP TABLE Card_Temp;

-- Step 7: Recreate the CardType table that depends on Card
CREATE TABLE CardType (
    CardTypeID INT AUTO_INCREMENT PRIMARY KEY,
    CardID INT NOT NULL,
    Type ENUM('Debit', 'Credit') NOT NULL,
    FOREIGN KEY (CardID) REFERENCES Card(CardID) ON DELETE CASCADE
);

-- Step 8: Restore CardType data
INSERT INTO CardType (CardID, Type)
VALUES 
    (1, 'Debit'),
    (2, 'Credit'),
    (3, 'Debit'),
    (4, 'Credit');


-- ===========================
-- ISSUE 2: Loan Table Modifications
-- ===========================

/*
The Loan table potentially has a transitive dependency where InterestRate may depend
on LoanType rather than directly on LoanID.

Solution: Extract loan types and their standard interest rates into a separate table
*/

-- Step 1: Create LoanType table
CREATE TABLE LoanType (
    LoanTypeID INT AUTO_INCREMENT PRIMARY KEY,
    TypeName VARCHAR(50) NOT NULL UNIQUE,
    StandardInterestRate DECIMAL(5,2) NOT NULL CHECK (StandardInterestRate >= 0)
);

-- Step 2: Insert standard loan types and their base interest rates
INSERT INTO LoanType (TypeName, StandardInterestRate)
VALUES 
    ('Home Loan', 3.5),
    ('Car Loan', 5.2),
    ('Personal Loan', 7.8);

-- Step 3: Modify the Loan table to reference LoanType
-- Create temporary table to store loan data
CREATE TABLE Loan_Temp (
    LoanID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    LoanTypeID INT NOT NULL,
    InterestRate DECIMAL(5,2) NOT NULL CHECK (InterestRate >= 0),
    Amount DECIMAL(10,2) NOT NULL CHECK (Amount > 0),
    StartDate DATE NOT NULL,
    EndDate DATE,
    Status ENUM('Pending', 'Approved', 'Active', 'Closed') DEFAULT 'Pending'
);

-- Step 4: Copy and transform data to the temporary table
INSERT INTO Loan_Temp (LoanID, CustomerID, LoanTypeID, InterestRate, Amount, StartDate, EndDate, Status)
SELECT L.LoanID, L.CustomerID, LT.LoanTypeID, L.InterestRate, L.Amount, L.StartDate, L.EndDate, L.Status
FROM Loan L
JOIN LoanType LT ON L.LoanType = LT.TypeName;

-- Step 5: Drop the old table
DROP TABLE Loan;

-- Step 6: Create the new Loan table in 3NF
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

-- Step 7: Restore the data
INSERT INTO Loan (LoanID, CustomerID, LoanTypeID, InterestRate, Amount, StartDate, EndDate, Status)
SELECT LoanID, CustomerID, LoanTypeID, InterestRate, Amount, StartDate, EndDate, Status FROM Loan_Temp;

-- Step 8: Drop the temporary table
DROP TABLE Loan_Temp;

-- ===========================
-- VERIFICATION OF 3NF COMPLIANCE
-- ===========================

/*
After these modifications:

1. The Card table is now in 3NF because:
   - All attributes depend directly on the primary key (CardID)
   - CustomerID is removed, eliminating the transitive dependency

2. The Loan system is now in 3NF because:
   - Loan types and their standard rates are in a separate table (LoanType)
   - The Loan table references LoanTypeID instead of storing LoanType as a string
   - This allows each loan to have a specific interest rate that might differ from
     the standard rate while maintaining proper dependencies

All other tables were already in 3NF as they had:
   - A primary key
   - All attributes dependent directly on the primary key
   - No transitive dependencies
*/
