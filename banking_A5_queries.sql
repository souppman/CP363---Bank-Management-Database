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
-- EXECUTION PLAN
-- ===========================

EXPLAIN ANALYZE
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

