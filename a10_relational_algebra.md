# Relational Algebra Translations for Banking System Queries from assignment 5
    

## Complex Customer Financial Analysis

### SQL Query:
```sql
SELECT 
    C.CustomerID,
    C.Name,
    COUNT(DISTINCT A.AccountID) as TotalAccounts,
    SUM(A.Balance) as TotalBalance,
    (SELECT COUNT(*) FROM Loan L WHERE L.CustomerID = C.CustomerID) as ActiveLoans
FROM Customer C
LEFT JOIN Account A ON C.CustomerID = A.CustomerID
GROUP BY C.CustomerID, C.Name
HAVING COUNT(DISTINCT A.AccountID) >= 1
```

### Relational Algebra:
```
π CustomerID, Name, TotalAccounts, TotalBalance, ActiveLoans (
  γ CustomerID, Name; 
    COUNT(DISTINCT AccountID)→TotalAccounts, 
    SUM(Balance)→TotalBalance (
      Customer ⟕ Account
  ) ⟕ (
    γ CustomerID; COUNT(*)→ActiveLoans (Loan)
  )
)
```

## Transaction Trend Analysis

### SQL Query:
```sql
SELECT 
    T.AccountID,
    T.TransactionDate,
    T.Amount,
    T.TransactionType,
    AVG(T.Amount) OVER (
        PARTITION BY T.AccountID 
        ORDER BY T.TransactionDate 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) as MovingAverage
FROM Transactions T
```

### Relational Algebra:
```
π AccountID, TransactionDate, Amount, TransactionType, MovingAverage (
  ω PARTITION BY AccountID ORDER BY TransactionDate 
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW; 
    AVG(Amount)→MovingAverage (
      Transactions
  )
)
```

## Branch Performance Metrics

### SQL Query:
```sql
SELECT 
    B.BranchName,
    COUNT(DISTINCT E.EmployeeID) as EmployeeCount,
    COUNT(DISTINCT A.ATMID) as ATMCount,
    COUNT(DISTINCT C.CustomerID) as ActiveCustomers
FROM Branch B
LEFT JOIN Employee E ON B.BranchID = E.BranchID
LEFT JOIN ATM A ON B.BranchID = A.BranchID
LEFT JOIN Card C ON C.CardStatus = 'Active'
GROUP BY B.BranchName
```

### Relational Algebra:
```
π BranchName, EmployeeCount, ATMCount, ActiveCustomers (
  γ BranchName; 
    COUNT(DISTINCT EmployeeID)→EmployeeCount,
    COUNT(DISTINCT ATMID)→ATMCount,
    COUNT(DISTINCT CustomerID)→ActiveCustomers (
      Branch ⟕ Employee ⟕ ATM ⟕ (σ CardStatus='Active' (Card))
  )
)
```

## Customer Risk Assessment

### SQL Query:
```sql
SELECT 
    C.CustomerID,
    C.Name,
    COUNT(DISTINCT L.LoanID) as TotalLoans,
    SUM(L.Amount) as TotalLoanAmount,
    AVG(L.InterestRate) as AvgInterestRate,
    COUNT(Comp.ComplaintID) as ComplaintCount
FROM Customer C
LEFT JOIN Loan L ON C.CustomerID = L.CustomerID
LEFT JOIN Complaint Comp ON C.CustomerID = Comp.CustomerID
GROUP BY C.CustomerID, C.Name
```

### Relational Algebra:
```
π CustomerID, Name, TotalLoans, TotalLoanAmount, AvgInterestRate, ComplaintCount (
  γ CustomerID, Name;
    COUNT(DISTINCT LoanID)→TotalLoans,
    SUM(Amount)→TotalLoanAmount,
    AVG(InterestRate)→AvgInterestRate,
    COUNT(ComplaintID)→ComplaintCount (
      Customer ⟕ Loan ⟕ Complaint
  )
)
```

## Product Usage Patterns

### SQL Query:
```sql
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
```

### Relational Algebra:
```
(
  π Type→CardType, CustomerCount, 'Card'→ProductType (
    γ Type; COUNT(DISTINCT CustomerID)→CustomerCount (
      Card ⟗ CardType
    )
  )
) ∪ (
  π Type→AccountType, CustomerCount, 'Account'→ProductType (
    γ Type; COUNT(DISTINCT CustomerID)→CustomerCount (
      Account ⟗ AccountType
    )
  )
)
```

## Transaction Pattern Analysis

### SQL Query:
```sql
SELECT 
    TransactionType,
    COUNT(*) as TransactionCount,
    AVG(Amount) as AvgAmount,
    MAX(Amount) as LargestTransaction
FROM Transactions
GROUP BY TransactionType
```

### Relational Algebra:
```
π TransactionType, TransactionCount, AvgAmount, LargestTransaction (
  γ TransactionType;
    COUNT(*)→TransactionCount,
    AVG(Amount)→AvgAmount,
    MAX(Amount)→LargestTransaction (
      Transactions
  )
)
``` 