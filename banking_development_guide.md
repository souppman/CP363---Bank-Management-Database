# Banking System Application Development Guide

This document serves as a development guide for the Banking System Application created for Assignment 6 in the CP363 Database Management course. It documents the steps taken during development, explains key concepts, and provides practice examples to help understand the SQL queries used in the application.

The Banking System Application is a menu-driven interface that interacts with a MySQL database to perform various banking operations. It demonstrates advanced SQL queries, views, and functional dependencies as required by the assignment.

## Table of Contents
1. [Project Overview](#project-overview)
2. [Database Schema](#database-schema)
3. [Functional Dependencies](#functional-dependencies)
4. [Application Development Process](#application-development-process)
5. [Advanced SQL Queries](#advanced-sql-queries)
6. [Practice Examples](#practice-examples)
7. [Troubleshooting](#troubleshooting)

## Project Overview

The Banking System Application is designed to meet the requirements of Assignment 6, which include:

1. Demonstrating advanced queries through a menu-driven interface
2. Using Python to create and populate the database and display query results
3. Presenting well-formatted query results
4. Documenting functional dependencies for all tables
5. Discussing the impact of these dependencies on query performance and normalization decisions

The application allows users to perform various banking operations such as viewing customer information, account details, transaction history, and generating reports.

## Database Schema

Our banking system database consists of the following tables:

1. **Customer** - Stores customer personal information
2. **Account** - Contains account information linked to customers
3. **AccountType** - Specifies the type of each account
4. **Transactions** - Records all financial transactions
5. **Card** - Stores information about cards issued to customers
6. **CardType** - Specifies the type of each card
7. **Complaint** - Records customer complaints
8. **Insurance** - Contains information about insurance policies
9. **Loan** - Stores loan information
10. **Branch** - Contains information about bank branches
11. **Employee** - Stores employee information
12. **ATM** - Contains information about ATM machines

The database also includes several views that provide aggregated information:

1. **CustomerFinancialSummary** - Summarizes customer financial information
2. **AccountActivitySummary** - Provides account activity metrics
3. **BranchPerformanceMetrics** - Shows branch performance statistics
4. **CustomerRiskProfile** - Assesses customer risk levels
5. **BranchPerformanceAnalytics** - Provides detailed branch performance analytics
6. **CustomerSegmentation** - Segments customers based on financial behavior

### Database Indexes

To optimize query performance, we've implemented several indexes in our database:

1. **Foreign Key Indexes**: These indexes improve JOIN operations between tables:
   - `idx_account_customer` on Account(CustomerID)
   - `idx_transaction_account` on Transactions(AccountID)
   - `idx_card_customer` on Card(CustomerID)
   - `idx_card_account` on Card(AccountID)
   - `idx_loan_customer` on Loan(CustomerID)
   - `idx_insurance_customer` on Insurance(CustomerID)
   - `idx_complaint_customer` on Complaint(CustomerID)
   - `idx_employee_branch` on Employee(BranchID)
   - `idx_atm_branch` on ATM(BranchID)

2. **Filter Column Indexes**: These indexes improve WHERE clause performance:
   - `idx_transaction_type` on Transactions(TransactionType)
   - `idx_transaction_date` on Transactions(TransactionDate)
   - `idx_card_status` on Card(CardStatus)
   - `idx_loan_status` on Loan(Status)
   - `idx_complaint_status` on Complaint(Status)
   - `idx_atm_status` on ATM(Status)

Indexes provide several benefits:
- They speed up data retrieval operations by allowing the database to find data without scanning entire tables
- They improve the performance of JOIN operations by making it faster to find matching rows
- They optimize WHERE clause filtering by creating efficient paths to the requested data
- They help enforce uniqueness and support foreign key constraints

However, indexes also have trade-offs:
- They require additional storage space
- They can slow down INSERT, UPDATE, and DELETE operations as the indexes must be updated
- Too many indexes can lead to the database optimizer making suboptimal choices

Our indexing strategy focuses on columns that are frequently used in JOIN operations and WHERE clauses to achieve the best balance between read and write performance.

## Functional Dependencies

Functional dependencies are relationships between attributes in a database table where the value of one attribute (or a set of attributes) determines the value of another attribute. Understanding these dependencies is crucial for proper database design and normalization.

### Customer Table
- CustomerID → Name, Address, Email, PhoneNumber
  - The CustomerID uniquely determines all other attributes in the Customer table.

### Account Table
- AccountID → Balance, CustomerID
  - The AccountID uniquely determines the Balance and which Customer owns the account.

### AccountType Table
- AccountTypeID → AccountID, Type
  - The AccountTypeID uniquely determines which Account it belongs to and what type it is.
- AccountID → Type
  - Each Account has only one Type.

### Transactions Table
- TransactionID → Amount, TransactionDate, TransactionType, AccountID, Description
  - The TransactionID uniquely determines all transaction details.

### Card Table
- CardID → ExpiryDate, CardStatus, CustomerID, AccountID
  - The CardID uniquely determines all card details.

### CardType Table
- CardTypeID → CardID, Type
  - The CardTypeID uniquely determines which Card it belongs to and what type it is.
- CardID → Type
  - Each Card has only one Type.

### Complaint Table
- ComplaintID → ComplaintDate, Description, Status, CustomerID
  - The ComplaintID uniquely determines all complaint details.

### Insurance Table
- InsuranceID → Premium, InsuranceType, StartDate, EndDate, CustomerID
  - The InsuranceID uniquely determines all insurance policy details.

### Loan Table
- LoanID → CustomerID, LoanType, InterestRate, Amount, StartDate, EndDate, Status
  - The LoanID uniquely determines all loan details.

### Branch Table
- BranchID → BranchName, BranchAddress, Phone
  - The BranchID uniquely determines all branch details.

### Employee Table
- EmployeeID → Name, Position, Email, Phone, BranchID
  - The EmployeeID uniquely determines all employee details.

### ATM Table
- ATMID → Location, Status, BranchID
  - The ATMID uniquely determines all ATM details.

### Impact on Query Performance and Normalization

Understanding functional dependencies has several impacts on our database design and query performance:

1. **Normalization Level**: Our database is in 3NF (Third Normal Form) as all non-key attributes are dependent only on the primary key, not on other non-key attributes. This reduces data redundancy and anomalies.

2. **Query Performance**: 
   - Properly normalized tables can sometimes require more joins, which might impact query performance for complex queries.
   - However, our design balances normalization with performance by creating appropriate views that pre-join related tables for common queries.
   - Indexes on foreign keys improve join performance significantly. Since our functional dependencies identify the key attributes in each table, we know exactly which columns should be indexed to optimize queries.
   - For example, the dependency CustomerID → Name, Address, Email, PhoneNumber in the Customer table tells us that CustomerID is a key attribute, making it an ideal candidate for indexing in tables that reference Customer.

3. **Data Integrity**: 
   - Functional dependencies help enforce data integrity through primary and foreign key constraints.
   - This ensures that relationships between entities are maintained correctly.
   - For instance, the dependency AccountID → Balance, CustomerID ensures that each account has exactly one balance and belongs to exactly one customer.

4. **Query Optimization**:
   - Understanding dependencies helps in creating efficient query execution plans.
   - The database optimizer can use these dependencies to determine the best join order and methods.
   - For example, knowing that AccountID functionally determines CustomerID allows the optimizer to use this relationship when joining the Account and Customer tables.

5. **Index Selection**:
   - Functional dependencies guide our index creation strategy.
   - Primary keys (determinants in functional dependencies) are automatically indexed.
   - Foreign keys (attributes that depend on primary keys in other tables) are ideal candidates for indexing.
   - Our indexing strategy focuses on these key relationships identified through functional dependencies.

6. **View Design**:
   - Views like CustomerFinancialSummary and AccountActivitySummary are designed based on the functional dependencies between tables.
   - These views pre-join tables based on their functional relationships, improving query performance while maintaining the benefits of normalization in the base tables.

By understanding and properly implementing functional dependencies, we've created a database that balances normalization (to reduce redundancy and maintain data integrity) with performance optimization (through strategic indexing and view creation).

## Application Development Process

The development of the Banking System Application followed these steps:

1. **Database Design and Creation**:
   - Analyzed requirements and identified entities and relationships
   - Created tables with appropriate constraints
   - Established functional dependencies

2. **Data Population**:
   - Inserted sample data into all tables
   - Ensured data integrity and relationships

3. **View Creation**:
   - Developed views to simplify complex queries
   - Created views for common reporting needs

4. **Application Development**:
   - Designed a menu-driven interface using Python
   - Implemented database connection and query execution
   - Created formatted output for query results

5. **Testing and Refinement**:
   - Tested all functionality
   - Refined queries for better performance
   - Improved user interface

## Advanced SQL Queries

The application demonstrates several advanced SQL concepts:

### 1. Joins and Aggregations

```sql
-- Example: Customer financial summary with multiple joins and aggregations
SELECT 
    C.CustomerID,
    C.Name,
    COUNT(DISTINCT A.AccountID) as TotalAccounts,
    SUM(A.Balance) as TotalBalance,
    COUNT(DISTINCT L.LoanID) as ActiveLoans,
    SUM(L.Amount) as TotalLoanAmount
FROM Customer C
LEFT JOIN Account A ON C.CustomerID = A.CustomerID
LEFT JOIN Loan L ON C.CustomerID = L.CustomerID
GROUP BY C.CustomerID, C.Name;
```

### 2. Subqueries

```sql
-- Example: Finding customers with above-average account balances
SELECT 
    C.CustomerID,
    C.Name,
    A.Balance
FROM Customer C
JOIN Account A ON C.CustomerID = A.CustomerID
WHERE A.Balance > (
    SELECT AVG(Balance) 
    FROM Account
);
```

### 3. Window Functions

```sql
-- Example: Ranking customers by total balance
SELECT 
    C.CustomerID,
    C.Name,
    SUM(A.Balance) as TotalBalance,
    RANK() OVER (ORDER BY SUM(A.Balance) DESC) as BalanceRank
FROM Customer C
JOIN Account A ON C.CustomerID = A.CustomerID
GROUP BY C.CustomerID, C.Name;
```

### 4. Case Statements

```sql
-- Example: Categorizing customers by balance
SELECT 
    C.CustomerID,
    C.Name,
    SUM(A.Balance) as TotalBalance,
    CASE 
        WHEN SUM(A.Balance) > 50000 THEN 'High Value'
        WHEN SUM(A.Balance) > 20000 THEN 'Medium Value'
        ELSE 'Standard'
    END as CustomerSegment
FROM Customer C
JOIN Account A ON C.CustomerID = A.CustomerID
GROUP BY C.CustomerID, C.Name;
```

### 5. Common Table Expressions (CTEs)

```sql
-- Example: Finding customers with both loans and insurance
WITH CustomerLoans AS (
    SELECT CustomerID
    FROM Loan
),
CustomerInsurance AS (
    SELECT CustomerID
    FROM Insurance
)
SELECT 
    C.CustomerID,
    C.Name
FROM Customer C
WHERE C.CustomerID IN (SELECT CustomerID FROM CustomerLoans)
AND C.CustomerID IN (SELECT CustomerID FROM CustomerInsurance);
```

## Practice Examples

Here are some practice examples to help you understand the SQL concepts used in the application:

### Practice 1: Basic Joins and Aggregations

**Problem**: Find the total balance for each customer and count how many accounts they have.

**Solution**:
```sql
SELECT 
    C.CustomerID,
    C.Name,
    COUNT(A.AccountID) as AccountCount,
    SUM(A.Balance) as TotalBalance
FROM Customer C
LEFT JOIN Account A ON C.CustomerID = A.CustomerID
GROUP BY C.CustomerID, C.Name;
```

**Explanation**: This query joins the Customer and Account tables on CustomerID, then groups the results by customer and counts the accounts while summing the balances.

### Practice 2: Subqueries

**Problem**: Find all customers who have made transactions larger than the average transaction amount.

**Solution**:
```sql
SELECT DISTINCT
    C.CustomerID,
    C.Name
FROM Customer C
JOIN Account A ON C.CustomerID = A.CustomerID
JOIN Transactions T ON A.AccountID = T.AccountID
WHERE T.Amount > (
    SELECT AVG(Amount)
    FROM Transactions
);
```

**Explanation**: This query uses a subquery to calculate the average transaction amount, then finds customers with transactions exceeding that average.

### Practice 3: Window Functions

**Problem**: Rank branches by the number of employees they have.

**Solution**:
```sql
SELECT 
    B.BranchID,
    B.BranchName,
    COUNT(E.EmployeeID) as EmployeeCount,
    RANK() OVER (ORDER BY COUNT(E.EmployeeID) DESC) as EmployeeRank
FROM Branch B
LEFT JOIN Employee E ON B.BranchID = E.BranchID
GROUP BY B.BranchID, B.BranchName;
```

**Explanation**: This query counts employees per branch and uses the RANK() window function to assign a rank based on the employee count.

### Practice 4: Case Statements

**Problem**: Categorize accounts based on their balance.

**Solution**:
```sql
SELECT 
    A.AccountID,
    A.Balance,
    CASE 
        WHEN A.Balance > 10000 THEN 'High Balance'
        WHEN A.Balance > 5000 THEN 'Medium Balance'
        WHEN A.Balance > 1000 THEN 'Low Balance'
        ELSE 'Minimal Balance'
    END as BalanceCategory
FROM Account A;
```

**Explanation**: This query uses a CASE statement to categorize accounts into different balance categories based on their current balance.

### Practice 5: Common Table Expressions (CTEs)

**Problem**: Find customers who have both a loan and a complaint.

**Solution**:
```sql
WITH LoanCustomers AS (
    SELECT DISTINCT CustomerID
    FROM Loan
),
ComplaintCustomers AS (
    SELECT DISTINCT CustomerID
    FROM Complaint
)
SELECT 
    C.CustomerID,
    C.Name
FROM Customer C
WHERE C.CustomerID IN (SELECT CustomerID FROM LoanCustomers)
AND C.CustomerID IN (SELECT CustomerID FROM ComplaintCustomers);
```

**Explanation**: This query uses two CTEs to identify customers with loans and customers with complaints, then finds the intersection of these two sets.

## Troubleshooting

Common issues and their solutions:

1. **Database Connection Issues**:
   - Ensure MySQL server is running
   - Verify connection credentials
   - Check network connectivity

2. **Query Performance Problems**:
   - Add appropriate indexes to frequently joined columns
   - Optimize complex queries by breaking them down
   - Use EXPLAIN to analyze query execution plans

3. **Data Integrity Issues**:
   - Ensure foreign key constraints are properly defined
   - Validate data before insertion
   - Use transactions for multi-step operations

4. **Python Interface Errors**:
   - Install required Python packages (mysql-connector-python)
   - Handle exceptions properly
   - Close database connections after use
