import mysql.connector  # for database connection
import os  
import sys  # for system exit
from datetime import datetime  
from tabulate import tabulate  # for formatting query results as tables

# database connection configuration
DB_CONFIG = {
    'host': 'localhost',  
    'user': 'root',  # replace with your MySQL username if different
    'password': '',  # replace with your MySQL password
    'database': 'BankingSystem4'  
}

def clear_screen():
    """clear the terminal screen"""
    # use appropriate command based on operating system
    os.system('cls' if os.name == 'nt' else 'clear')

def connect_to_database():
    """connect to the MySQL database"""
    try:
        # attempt to establish connection using config
        connection = mysql.connector.connect(**DB_CONFIG)
        return connection
    except mysql.connector.Error as err:
        # handle connection errors
        print(f"Error connecting to MySQL database: {err}")
        sys.exit(1)  # exit program if can't connect

def execute_query(connection, query, params=None, fetch=True):
    """execute a SQL query and return the results"""
    # create cursor with dictionary=True to get results as dictionaries
    cursor = connection.cursor(dictionary=True)
    try:
        # execute the query with parameters if provided
        cursor.execute(query, params or ())
        if fetch:
            # fetch and return results for SELECT queries
            results = cursor.fetchall()
            return results
        else:
            # commit changes for INSERT, UPDATE, DELETE queries
            connection.commit()
            return cursor.rowcount  # return number of affected rows
    except mysql.connector.Error as err:
        # handle query execution errors
        print(f"Error executing query: {err}")
        return None
    finally:
        # always close cursor to free resources
        cursor.close()

def display_results(results, title):
    """display query results in a formatted table"""
    if not results:
        print("No results found.")
        return
    
    # extract headers from the first result
    headers = results[0].keys()
    
    # extract values from all results
    table_data = [[row[col] for col in headers] for row in results]
    
    # print the table with a title
    print(f"\n{title}")
    print(tabulate(table_data, headers=headers, tablefmt="grid"))

def initialize_database(connection):
    """check if the database exists and initialize it if needed"""
    # check if tables exist
    query = """
    SELECT COUNT(*) as table_count 
    FROM information_schema.tables 
    WHERE table_schema = %s
    """
    result = execute_query(connection, query, (DB_CONFIG['database'],))
    
    if result[0]['table_count'] == 0:
        # database exists but has no tables, so initialize it
        print("Database tables not found. Initializing database...")
        try:
            # read SQL script from file
            with open('a6.sql', 'r') as file:
                sql_script = file.read()
                
            # execute the script
            cursor = connection.cursor()
            try:
                # split the script into individual statements
                statements = sql_script.split(';')
                
                # execute each statement separately
                for statement in statements:
                    statement = statement.strip()
                    if statement:
                        try:
                            cursor.execute(statement)
                            connection.commit()
                        except mysql.connector.Error:
                            pass  # ignore errors and continue
                
                print("Database initialized successfully!")
            finally:
                cursor.close()  # ensure cursor is closed even if errors occur
        except Exception as e:
            # handle file reading or other errors
            print(f"Error initializing database: {e}")
            sys.exit(1)

# menu functions - each function handles a specific menu option

def view_customer_information(connection):
    """view detailed customer information"""
    # query joins customer with accounts, loans, and insurance
    # and aggregates data to show summary information
    query = """
    SELECT 
        C.CustomerID,
        C.Name,
        C.Address,
        C.Email,
        C.PhoneNumber,
        COUNT(DISTINCT A.AccountID) as TotalAccounts,
        SUM(A.Balance) as TotalBalance,
        COUNT(DISTINCT L.LoanID) as ActiveLoans,
        COUNT(DISTINCT I.InsuranceID) as InsuranceProducts
    FROM Customer C
    LEFT JOIN Account A ON C.CustomerID = A.CustomerID
    LEFT JOIN Loan L ON C.CustomerID = L.CustomerID
    LEFT JOIN Insurance I ON C.CustomerID = I.CustomerID
    GROUP BY C.CustomerID, C.Name, C.Address, C.Email, C.PhoneNumber
    ORDER BY C.Name
    """
    results = execute_query(connection, query)
    display_results(results, "Customer Information")

def view_account_details(connection):
    """view account details with transaction summary"""
    # query joins account with customer and account type
    # and aggregates transaction data to show summary
    query = """
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
    GROUP BY A.AccountID, C.Name, AT.Type, A.Balance
    ORDER BY A.AccountID
    """
    results = execute_query(connection, query)
    display_results(results, "Account Details")

def view_transaction_history(connection):
    """view transaction history with filtering options"""
    # show submenu for transaction history options
    print("\nTransaction History Options:")
    print("1. View all transactions")
    print("2. View transactions by account")
    print("3. View transactions by type")
    print("4. View transactions by date range")
    
    choice = input("\nEnter your choice (1-4): ")
    
    if choice == '1':
        # option 1: show all transactions
        query = """
        SELECT 
            T.TransactionID,
            T.AccountID,
            C.Name as CustomerName,
            T.Amount,
            T.TransactionType,
            T.TransactionDate,
            T.Description
        FROM Transactions T
        JOIN Account A ON T.AccountID = A.AccountID
        JOIN Customer C ON A.CustomerID = C.CustomerID
        ORDER BY T.TransactionDate DESC
        """
        results = execute_query(connection, query)
        display_results(results, "All Transactions")
    
    elif choice == '2':
        # option 2: filter transactions by account ID
        account_id = input("Enter Account ID: ")
        try:
            # validate account ID is a number
            account_id = int(account_id)
            query = """
            SELECT 
                T.TransactionID,
                T.Amount,
                T.TransactionType,
                T.TransactionDate,
                T.Description
            FROM Transactions T
            WHERE T.AccountID = %s
            ORDER BY T.TransactionDate DESC
            """
            results = execute_query(connection, query, (account_id,))
            display_results(results, f"Transactions for Account {account_id}")
        except ValueError:
            print("Error: Account ID must be a number.")
    
    elif choice == '3':
        # option 3: filter transactions by type
        print("\nTransaction Types:")
        print("1. Deposit")
        print("2. Withdrawal")
        print("3. Transfer")
        
        type_choice = input("\nEnter your choice (1-3): ")
        
        # map user choice to transaction type
        transaction_types = {
            '1': 'Deposit',
            '2': 'Withdrawal',
            '3': 'Transfer'
        }
        
        if type_choice in transaction_types:
            query = """
            SELECT 
                T.TransactionID,
                T.AccountID,
                C.Name as CustomerName,
                T.Amount,
                T.TransactionDate,
                T.Description
            FROM Transactions T
            JOIN Account A ON T.AccountID = A.AccountID
            JOIN Customer C ON A.CustomerID = C.CustomerID
            WHERE T.TransactionType = %s
            ORDER BY T.TransactionDate DESC
            """
            results = execute_query(connection, query, (transaction_types[type_choice],))
            display_results(results, f"{transaction_types[type_choice]} Transactions")
        else:
            print("Invalid choice.")
    
    elif choice == '4':
        # option 4: filter transactions by date range
        start_date = input("Enter start date (YYYY-MM-DD): ")
        end_date = input("Enter end date (YYYY-MM-DD): ")
        
        try:
            # validate date format
            datetime.strptime(start_date, '%Y-%m-%d')
            datetime.strptime(end_date, '%Y-%m-%d')
            
            query = """
            SELECT 
                T.TransactionID,
                T.AccountID,
                C.Name as CustomerName,
                T.Amount,
                T.TransactionType,
                T.TransactionDate,
                T.Description
            FROM Transactions T
            JOIN Account A ON T.AccountID = A.AccountID
            JOIN Customer C ON A.CustomerID = C.CustomerID
            WHERE T.TransactionDate BETWEEN %s AND %s
            ORDER BY T.TransactionDate DESC
            """
            results = execute_query(connection, query, (start_date, end_date))
            display_results(results, f"Transactions from {start_date} to {end_date}")
        except ValueError:
            print("Error: Invalid date format. Please use YYYY-MM-DD format.")
    
    else:
        print("Invalid choice.")

def view_branch_performance(connection):
    """view branch performance metrics"""
    # use the BranchPerformanceMetrics view to show branch statistics
    query = """
    SELECT * FROM BranchPerformanceMetrics
    """
    results = execute_query(connection, query)
    display_results(results, "Branch Performance Metrics")

def view_customer_risk_profile(connection):
    """view customer risk profiles"""
    # use the CustomerRiskProfile view to show risk assessment
    query = """
    SELECT * FROM CustomerRiskProfile
    """
    results = execute_query(connection, query)
    display_results(results, "Customer Risk Profiles")

def view_customer_segmentation(connection):
    """view customer segmentation based on financial behavior"""
    # use the CustomerSegmentation view to show customer segments
    query = """
    SELECT * FROM CustomerSegmentation
    """
    results = execute_query(connection, query)
    display_results(results, "Customer Segmentation")

def view_account_activity(connection):
    """view account activity summary"""
    # use the AccountActivitySummary view to show account activity
    query = """
    SELECT * FROM AccountActivitySummary
    """
    results = execute_query(connection, query)
    display_results(results, "Account Activity Summary")

def view_branch_analytics(connection):
    """view branch performance analytics"""
    # use the BranchPerformanceAnalytics view to show detailed analytics
    query = """
    SELECT * FROM BranchPerformanceAnalytics
    """
    results = execute_query(connection, query)
    display_results(results, "Branch Performance Analytics")

def view_database_statistics(connection):
    """view database statistics"""
    # query counts records in each table using UNION ALL
    query = """
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
    SELECT 'ATMs', COUNT(*) FROM ATM
    """
    results = execute_query(connection, query)
    display_results(results, "Database Statistics")

def main_menu():
    """display the main menu and handle user input"""
    try:
        # connect to database and initialize if needed
        connection = connect_to_database()
        initialize_database(connection)
        
        # main application loop
        while True:
            clear_screen()
            # display menu options
            print("\n===== Banking System Application =====")
            print("1. View Customer Information")
            print("2. View Account Details")
            print("3. View Transaction History")
            print("4. View Branch Performance Metrics")
            print("5. View Customer Risk Profiles")
            print("6. View Customer Segmentation")
            print("7. View Account Activity Summary")
            print("8. View Branch Performance Analytics")
            print("9. View Database Statistics")
            print("0. Exit")
            
            # get user choice
            choice = input("\nEnter your choice (0-9): ")
            
            # handle user choice
            if choice == '1':
                view_customer_information(connection)
            elif choice == '2':
                view_account_details(connection)
            elif choice == '3':
                view_transaction_history(connection)
            elif choice == '4':
                view_branch_performance(connection)
            elif choice == '5':
                view_customer_risk_profile(connection)
            elif choice == '6':
                view_customer_segmentation(connection)
            elif choice == '7':
                view_account_activity(connection)
            elif choice == '8':
                view_branch_analytics(connection)
            elif choice == '9':
                view_database_statistics(connection)
            elif choice == '0':
                # exit the application
                print("\nThank you for using the Banking System Application!")
                connection.close()  # close database connection
                sys.exit(0)
            else:
                print("Invalid choice. Please try again.")
            
            # pause before returning to menu
            input("\nPress Enter to continue...")
    except KeyboardInterrupt:
        # handle Ctrl+C gracefully
        print("\n\nProgram interrupted by user. Exiting...")
        try:
            connection.close()  # try to close connection
        except:
            pass
        sys.exit(0)
    except Exception as e:
        # catch any other unexpected errors
        print(f"\nAn unexpected error occurred: {e}")
        sys.exit(1)

# program entry point
if __name__ == "__main__":
    main_menu()
