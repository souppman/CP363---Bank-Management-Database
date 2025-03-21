-- ===========================
-- BANKING SYSTEM DATABASE - ASSIGNMENT 8: NORMALIZATION TO BCNF
-- ===========================

-- This script addresses Boyce-Codd Normal Form (BCNF) requirements for the banking database

USE BankingSystem4;

-- ===========================
-- BCNF ANALYSIS
-- ===========================

/*
BOYCE-CODD NORMAL FORM (BCNF) EXPLANATION:
A table is in BCNF if for every non-trivial functional dependency X → Y in the relation, 
X is a superkey (candidate key or superset of a candidate key).

In other words, every determinant must be a candidate key.
*/

-- ===========================
-- FUNCTIONAL DEPENDENCY ANALYSIS FOR EACH TABLE
-- ===========================

/*
1. Customer Table
   - Functional dependencies: CustomerID → Name, Address, Email, PhoneNumber
                             Email → CustomerID (due to UNIQUE constraint)
                             PhoneNumber → CustomerID (due to UNIQUE constraint)
   - Candidate keys: CustomerID, Email, PhoneNumber
   - Status: BCNF compliant (all determinants are candidate keys)

2. Account Table
   - Functional dependencies: AccountID → Balance, CustomerID
   - Candidate keys: AccountID
   - Status: BCNF compliant (all determinants are candidate keys)

3. AccountType Table
   - Functional dependencies: AccountTypeID → AccountID, Type
   - Candidate keys: AccountTypeID
   - Status: BCNF compliant (all determinants are candidate keys)

4. Transactions Table
   - Functional dependencies: TransactionID → Amount, TransactionDate, TransactionType, AccountID, Description
   - Candidate keys: TransactionID
   - Status: BCNF compliant (all determinants are candidate keys)

5. Card Table (after 3NF normalization)
   - Functional dependencies: CardID → ExpiryDate, CardStatus, AccountID
   - Candidate keys: CardID
   - Status: BCNF compliant (all determinants are candidate keys)

6. CardType Table
   - Functional dependencies: CardTypeID → CardID, Type
   - Candidate keys: CardTypeID
   - Status: BCNF compliant (all determinants are candidate keys)

7. Complaint Table
   - Functional dependencies: ComplaintID → ComplaintDate, Description, Status, CustomerID
   - Candidate keys: ComplaintID
   - Status: BCNF compliant (all determinants are candidate keys)

8. Insurance Table
   - Functional dependencies: InsuranceID → Premium, InsuranceType, StartDate, EndDate, CustomerID
   - Candidate keys: InsuranceID
   - Status: BCNF compliant (all determinants are candidate keys)

9. Loan Table (after 3NF normalization)
   - Functional dependencies: LoanID → CustomerID, LoanTypeID, InterestRate, Amount, StartDate, EndDate, Status
   - Candidate keys: LoanID
   - Status: BCNF compliant (all determinants are candidate keys)

10. LoanType Table
    - Functional dependencies: LoanTypeID → TypeName, StandardInterestRate
                              TypeName → LoanTypeID, StandardInterestRate (due to UNIQUE constraint)
    - Candidate keys: LoanTypeID, TypeName
    - Status: BCNF compliant (all determinants are candidate keys)

11. Branch Table
    - Functional dependencies: BranchID → BranchName, BranchAddress, Phone
    - Candidate keys: BranchID
    - Status: BCNF compliant (all determinants are candidate keys)

12. Employee Table
    - Functional dependencies: EmployeeID → Name, Position, Email, Phone, BranchID
                              Email → EmployeeID (due to UNIQUE constraint)
    - Candidate keys: EmployeeID, Email
    - Status: BCNF compliant (all determinants are candidate keys)

13. ATM Table
    - Functional dependencies: ATMID → Location, Status, BranchID
    - Candidate keys: ATMID
    - Status: BCNF compliant (all determinants are candidate keys)
*/

-- ===========================
-- MODIFICATION TO INTRODUCE BCNF VIOLATION
-- ===========================

/*
since all tables are already in BCNF after the 3NF normalization in Assignment 7,
we will modify the Employee table to introduce a BCNF violation, then normalize it back.

we'll add a Department attribute and create a situation where Position determines Department,
but Position is not a candidate key, thus violating BCNF.
*/

-- Safe mode disable
SET SQL_SAFE_UPDATES = 0;

-- Step 1: modify Employee table to add Department
-- check if Department column exists before adding it
SET @column_exists = (
    SELECT COUNT(*)
    FROM information_schema.columns
    WHERE table_name = 'Employee'
    AND column_name = 'Department'
    AND table_schema = DATABASE()
);

SET @sql = IF(@column_exists = 0,
    'ALTER TABLE Employee ADD Department VARCHAR(100)',
    'SELECT "Department column already exists" AS Message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Step 2: update with sample data to create functional dependency Position → Department
UPDATE Employee SET Department = 'Management' WHERE Position = 'Manager';
UPDATE Employee SET Department = 'Operations' WHERE Position = 'Teller';
UPDATE Employee SET Department = 'Customer Service' WHERE Position = 'Customer Service Representative';
UPDATE Employee SET Department = 'Operations' WHERE Position = 'Loan Officer';
UPDATE Employee SET Department = 'Management' WHERE Position = 'Branch Supervisor';

-- add more sample employees to demonstrate the functional dependency
INSERT INTO Employee (Name, Position, Email, Phone, BranchID, Department)
VALUES 
    ('Robert Johnson', 'Manager', 'robert@bank.com', '111-2223', 2, 'Management'),
    ('Sarah Wilson', 'Teller', 'sarah@bank.com', '333-4445', 1, 'Operations'),
    ('Thomas Lee', 'Customer Service Representative', 'thomas@bank.com', '555-6667', 2, 'Customer Service'),
    ('Jessica Parker', 'Loan Officer', 'jessica@bank.com', '777-8889', 1, 'Operations'),
    ('William Davis', 'Branch Supervisor', 'william@bank.com', '999-0001', 2, 'Management');

/*
now the Employee table has the following functional dependencies:
- EmployeeID → Name, Position, Email, Phone, BranchID, Department
- Email → EmployeeID, Name, Position, Phone, BranchID, Department (due to UNIQUE constraint)
- Position → Department (new dependency)

since Position is not a candidate key, this violates BCNF.
*/

-- ===========================
-- NORMALIZING TO BCNF
-- ===========================

-- Step 1: create a new PositionDepartment table to capture the Position → Department dependency
CREATE TABLE PositionDepartment (
    PositionID INT AUTO_INCREMENT PRIMARY KEY,
    PositionName VARCHAR(100) NOT NULL UNIQUE,
    Department VARCHAR(100) NOT NULL
);

-- Step 2: insert distinct positions and their corresponding departments
INSERT INTO PositionDepartment (PositionName, Department)
SELECT DISTINCT Position, Department FROM Employee;

-- Step 3: modify the Employee table to reference PositionDepartment
-- first, create a temporary table
CREATE TABLE Employee_Temp (
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    PositionID INT NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    Phone VARCHAR(20) NOT NULL,
    BranchID INT NOT NULL,
    FOREIGN KEY (PositionID) REFERENCES PositionDepartment(PositionID),
    FOREIGN KEY (BranchID) REFERENCES Branch(BranchID)
);

-- Step 4: copy and transform data to the temporary table
INSERT INTO Employee_Temp (EmployeeID, Name, PositionID, Email, Phone, BranchID)
SELECT E.EmployeeID, E.Name, PD.PositionID, E.Email, E.Phone, E.BranchID
FROM Employee E
JOIN PositionDepartment PD ON E.Position = PD.PositionName;

-- Step 5: drop the old table
DROP TABLE Employee;

-- Step 6: create the new Employee table in BCNF
CREATE TABLE Employee (
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    PositionID INT NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    Phone VARCHAR(20) NOT NULL,
    BranchID INT NOT NULL,
    FOREIGN KEY (PositionID) REFERENCES PositionDepartment(PositionID),
    FOREIGN KEY (BranchID) REFERENCES Branch(BranchID)
);

-- Step 7: restore the data
INSERT INTO Employee (EmployeeID, Name, PositionID, Email, Phone, BranchID)
SELECT EmployeeID, Name, PositionID, Email, Phone, BranchID FROM Employee_Temp;

-- Step 8: drop the temporary table
DROP TABLE Employee_Temp;

-- ===========================
-- VERIFICATION OF BCNF COMPLIANCE
-- ===========================

/*
After these modifications:

1. the original Employee table was in BCNF, but we introduced a violation by adding
   the Department field with Position → Department dependency.

2. We resolved this by decomposing into two tables:
   - PositionDepartment table:
     * Functional dependencies: PositionID → PositionName, Department
                               PositionName → PositionID, Department (due to UNIQUE constraint)
     * Candidate keys: PositionID, PositionName
     * Status: BCNF compliant (all determinants are candidate keys)
   
   - New Employee table:
     * Functional dependencies: EmployeeID → Name, PositionID, Email, Phone, BranchID
                               Email → EmployeeID, Name, PositionID, Phone, BranchID (due to UNIQUE constraint)
     * Candidate keys: EmployeeID, Email
     * Status: BCNF compliant (all determinants are candidate keys)

The database is now fully in BCNF.
*/

-- ===========================
-- QUERY TO VIEW THE REORGANIZED DATA
-- ===========================

-- this query joins the Employee table with PositionDepartment to show the complete employee information
SELECT 
    E.EmployeeID,
    E.Name,
    PD.PositionName AS Position,
    PD.Department,
    E.Email,
    E.Phone,
    B.BranchName
FROM Employee E
JOIN PositionDepartment PD ON E.PositionID = PD.PositionID
JOIN Branch B ON E.BranchID = B.BranchID
ORDER BY E.EmployeeID;

-- reactivate safe mode
SET SQL_SAFE_UPDATES = 1;