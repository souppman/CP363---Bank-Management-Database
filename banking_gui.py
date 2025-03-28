import tkinter as tk
from tkinter import ttk, messagebox
import mysql.connector
from datetime import datetime
import sys
from config import DB_CONFIG, APP_CONFIG
from security import SecurityManager

class BankingSystemGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("Banking System")
        self.root.geometry("1000x700")
        
        # Configure style
        self.style = ttk.Style()
        self.style.configure('TButton', padding=5, font=('Helvetica', 10))
        self.style.configure('TLabel', font=('Helvetica', 10))
        self.style.configure('TEntry', padding=5)
        self.style.configure('Treeview', rowheight=25)
        self.style.configure('Treeview.Heading', font=('Helvetica', 10, 'bold'))
        
        # Initialize security manager
        self.security = SecurityManager()
        
        # Session management
        self.current_user = None
        self.last_activity = datetime.now()
        self.login_attempts = 0
        
        # Database connection
        try:
            self.conn = mysql.connector.connect(**DB_CONFIG)
            self.cursor = self.conn.cursor()
        except mysql.connector.Error as err:
            messagebox.showerror("Database Error", f"Failed to connect to database: {err}")
            sys.exit(1)
        
        # Show login screen first
        self.show_login()
        
    def create_back_button(self, parent, command):
        """Create a styled back button"""
        back_btn = ttk.Button(parent, text="← Back", command=command, style='Back.TButton')
        back_btn.pack(side=tk.LEFT, padx=5, pady=5)
        return back_btn
    
    def create_header(self, parent, title):
        """Create a styled header with title"""
        header_frame = ttk.Frame(parent)
        header_frame.pack(fill=tk.X, padx=10, pady=5)
        
        title_label = ttk.Label(header_frame, text=title, font=('Helvetica', 16, 'bold'))
        title_label.pack(side=tk.LEFT, padx=5)
        
        return header_frame
    
    def create_treeview(self, parent, columns, height=20):
        """Create a styled treeview with scrollbars"""
        # Create frame for treeview and scrollbars
        tree_frame = ttk.Frame(parent)
        tree_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=5)
        
        # Create treeview
        tree = ttk.Treeview(tree_frame, columns=columns, show='headings', height=height)
        
        # Set column headings and widths
        for col in columns:
            tree.heading(col, text=col)
            tree.column(col, width=100, anchor=tk.CENTER)
        
        # Add scrollbars
        y_scrollbar = ttk.Scrollbar(tree_frame, orient=tk.VERTICAL, command=tree.yview)
        x_scrollbar = ttk.Scrollbar(tree_frame, orient=tk.HORIZONTAL, command=tree.xview)
        tree.configure(yscrollcommand=y_scrollbar.set, xscrollcommand=x_scrollbar.set)
        
        # Grid layout
        tree.grid(row=0, column=0, sticky='nsew')
        y_scrollbar.grid(row=0, column=1, sticky='ns')
        x_scrollbar.grid(row=1, column=0, sticky='ew')
        
        # Configure grid weights
        tree_frame.grid_columnconfigure(0, weight=1)
        tree_frame.grid_rowconfigure(0, weight=1)
        
        return tree
    
    def create_button_frame(self, parent):
        """Create a styled frame for buttons"""
        button_frame = ttk.Frame(parent)
        button_frame.pack(fill=tk.X, padx=10, pady=5)
        return button_frame
    
    def show_login(self):
        # Clear existing widgets
        for widget in self.root.winfo_children():
            widget.destroy()
        
        # Create main frame with padding
        main_frame = ttk.Frame(self.root, padding="40")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # Configure grid weights
        self.root.grid_columnconfigure(0, weight=1)
        self.root.grid_rowconfigure(0, weight=1)
        
        # Title with larger font
        title_label = ttk.Label(main_frame, text="Banking System Login", font=('Helvetica', 24, 'bold'))
        title_label.grid(row=0, column=0, columnspan=2, pady=(0, 30))
        
        # Login frame with border
        login_frame = ttk.Frame(main_frame, padding="20", relief="solid", borderwidth=1)
        login_frame.grid(row=1, column=0, columnspan=2, sticky=(tk.W, tk.E))
        
        # Username
        ttk.Label(login_frame, text="Username:", font=('Helvetica', 12)).grid(row=0, column=0, pady=10, padx=5)
        self.username_var = tk.StringVar()
        username_entry = ttk.Entry(login_frame, textvariable=self.username_var, width=30)
        username_entry.grid(row=0, column=1, pady=10, padx=5)
        
        # Password
        ttk.Label(login_frame, text="Password:", font=('Helvetica', 12)).grid(row=1, column=0, pady=10, padx=5)
        self.password_var = tk.StringVar()
        password_entry = ttk.Entry(login_frame, textvariable=self.password_var, show="*", width=30)
        password_entry.grid(row=1, column=1, pady=10, padx=5)
        
        # Login button
        login_btn = ttk.Button(login_frame, text="Login", command=self.login, width=20)
        login_btn.grid(row=2, column=0, columnspan=2, pady=20)
        
        # Bind Enter key to login
        self.root.bind('<Return>', lambda e: self.login())
    
    def login(self):
        username = self.security.sanitize_input(self.username_var.get())
        password = self.password_var.get()
        
        if not username or not password:
            messagebox.showerror("Error", "Please enter both username and password")
            return
        
        try:
            # Check login attempts
            if self.login_attempts >= APP_CONFIG['max_login_attempts']:
                messagebox.showerror("Error", "Too many login attempts. Please try again later.")
                return
            
            # Verify credentials
            if self.verify_credentials(username, password):
                self.last_activity = datetime.now()
                self.login_attempts = 0
                self.create_main_menu()
            else:
                self.login_attempts += 1
                messagebox.showerror("Error", "Invalid username or password")
        except Exception as e:
            messagebox.showerror("Error", f"Login failed: {str(e)}")
    
    def verify_credentials(self, username: str, password: str) -> bool:
        """Verify user credentials against database"""
        try:
            query = """
                SELECT UserID, Password, Role 
                FROM User 
                WHERE Username = %s
            """
            self.cursor.execute(query, (username,))
            result = self.cursor.fetchone()
            
            if result and result[1] == self.security.hash_password(password):
                self.current_user = {
                    'id': result[0],
                    'username': username,
                    'role': result[2]
                }
                return True
            return False
        except mysql.connector.Error as err:
            messagebox.showerror("Database Error", f"Failed to verify credentials: {err}")
            return False
    
    def check_session(self):
        """Check if session has timed out"""
        if self.security.check_session_timeout(self.last_activity):
            messagebox.showwarning("Session Expired", "Your session has expired. Please login again.")
            self.show_login()
            return False
        self.last_activity = datetime.now()
        return True
    
    def create_main_menu(self):
        # Clear existing widgets
        for widget in self.root.winfo_children():
            widget.destroy()
        
        # Create main frame
        main_frame = ttk.Frame(self.root, padding="20")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # Configure grid weights
        self.root.grid_columnconfigure(0, weight=1)
        self.root.grid_rowconfigure(0, weight=1)
        
        # Header with user info
        header_frame = ttk.Frame(main_frame)
        header_frame.grid(row=0, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=(0, 20))
        
        title_label = ttk.Label(header_frame, text="Banking System", font=('Helvetica', 24, 'bold'))
        title_label.pack(side=tk.LEFT)
        
        user_label = ttk.Label(header_frame, text=f"Welcome, {self.current_user['username']} ({self.current_user['role']})", 
                             font=('Helvetica', 12))
        user_label.pack(side=tk.RIGHT)
        
        # Create menu frame with border
        menu_frame = ttk.Frame(main_frame, padding="20", relief="solid", borderwidth=1)
        menu_frame.grid(row=1, column=0, columnspan=2, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # Menu buttons with icons (using Unicode characters as icons)
        buttons = [
            ("👥 Customer Management", self.show_customer_management),
            ("💳 Account Operations", self.show_account_operations),
            ("📊 Transaction History", self.show_transaction_history),
            ("💰 Loan Management", self.show_loan_management),
            ("📈 Reports", self.show_reports),
            ("🚪 Logout", self.logout)
        ]
        
        for i, (text, command) in enumerate(buttons):
            btn = ttk.Button(menu_frame, text=text, command=command, width=30)
            btn.grid(row=i, column=0, pady=10, padx=20)
        
        # Start session check timer
        self.root.after(60000, self.check_session)  # Check every minute
    
    def logout(self):
        """Handle user logout"""
        self.current_user = None
        self.last_activity = datetime.now()
        self.show_login()
    
    def show_customer_management(self):
        if not self.check_session():
            return
            
        # Create new window for customer management
        customer_window = tk.Toplevel(self.root)
        customer_window.title("Customer Management")
        customer_window.geometry("1000x700")
        
        # Create main frame
        main_frame = ttk.Frame(customer_window, padding="10")
        main_frame.pack(fill=tk.BOTH, expand=True)
        
        # Header with back button
        header_frame = ttk.Frame(main_frame)
        header_frame.pack(fill=tk.X, pady=(0, 10))
        
        self.create_back_button(header_frame, customer_window.destroy)
        self.create_header(header_frame, "Customer Management")
        
        # Create treeview
        columns = ('ID', 'Name', 'Email', 'Phone')
        tree = self.create_treeview(main_frame, columns)
        
        # Button frame
        button_frame = self.create_button_frame(main_frame)
        
        # Add CRUD buttons
        ttk.Button(button_frame, text="Add Customer", command=lambda: self.add_customer(tree)).pack(side=tk.LEFT, padx=5)
        ttk.Button(button_frame, text="Edit Customer", command=lambda: self.edit_customer(tree)).pack(side=tk.LEFT, padx=5)
        ttk.Button(button_frame, text="Delete Customer", command=lambda: self.delete_customer(tree)).pack(side=tk.LEFT, padx=5)
        
        # Fetch and display customers
        self.refresh_customer_list(tree)
    
    def refresh_customer_list(self, tree):
        """Refresh the customer list in the treeview"""
        # Clear existing items
        for item in tree.get_children():
            tree.delete(item)
        
        # Fetch and display customers
        try:
            query = "SELECT CustomerID, Name, Email, PhoneNumber FROM Customer"
            self.cursor.execute(query)
            for row in self.cursor.fetchall():
                tree.insert('', 'end', values=row)
        except mysql.connector.Error as err:
            messagebox.showerror("Error", f"Failed to fetch customers: {err}")
    
    def add_customer(self, tree):
        """Add a new customer"""
        # Create dialog window
        dialog = tk.Toplevel(self.root)
        dialog.title("Add Customer")
        dialog.geometry("400x300")
        
        # Create input fields
        ttk.Label(dialog, text="Name:").pack(pady=5)
        name_var = tk.StringVar()
        ttk.Entry(dialog, textvariable=name_var).pack(pady=5)
        
        ttk.Label(dialog, text="Email:").pack(pady=5)
        email_var = tk.StringVar()
        ttk.Entry(dialog, textvariable=email_var).pack(pady=5)
        
        ttk.Label(dialog, text="Phone:").pack(pady=5)
        phone_var = tk.StringVar()
        ttk.Entry(dialog, textvariable=phone_var).pack(pady=5)
        
        def save():
            # Validate inputs
            if not name_var.get() or not email_var.get() or not phone_var.get():
                messagebox.showerror("Error", "All fields are required")
                return
            
            if not self.security.validate_email(email_var.get()):
                messagebox.showerror("Error", "Invalid email format")
                return
            
            if not self.security.validate_phone(phone_var.get()):
                messagebox.showerror("Error", "Invalid phone number format")
                return
            
            try:
                # Insert new customer
                query = """
                    INSERT INTO Customer (Name, Email, PhoneNumber)
                    VALUES (%s, %s, %s)
                """
                self.cursor.execute(query, (
                    self.security.sanitize_input(name_var.get()),
                    self.security.sanitize_input(email_var.get()),
                    self.security.sanitize_input(phone_var.get())
                ))
                self.conn.commit()
                
                # Refresh the list
                self.refresh_customer_list(tree)
                dialog.destroy()
                messagebox.showinfo("Success", "Customer added successfully")
            except mysql.connector.Error as err:
                messagebox.showerror("Error", f"Failed to add customer: {err}")
        
        ttk.Button(dialog, text="Save", command=save).pack(pady=20)
    
    def edit_customer(self, tree):
        """Edit selected customer"""
        selected = tree.selection()
        if not selected:
            messagebox.showwarning("Warning", "Please select a customer to edit")
            return
        
        # Get customer data
        customer_id = tree.item(selected[0])['values'][0]
        
        # Create dialog window
        dialog = tk.Toplevel(self.root)
        dialog.title("Edit Customer")
        dialog.geometry("400x300")
        
        # Fetch current customer data
        try:
            query = "SELECT Name, Email, PhoneNumber FROM Customer WHERE CustomerID = %s"
            self.cursor.execute(query, (customer_id,))
            customer = self.cursor.fetchone()
            
            if not customer:
                messagebox.showerror("Error", "Customer not found")
                dialog.destroy()
                return
            
            # Create input fields with current values
            ttk.Label(dialog, text="Name:").pack(pady=5)
            name_var = tk.StringVar(value=customer[0])
            ttk.Entry(dialog, textvariable=name_var).pack(pady=5)
            
            ttk.Label(dialog, text="Email:").pack(pady=5)
            email_var = tk.StringVar(value=customer[1])
            ttk.Entry(dialog, textvariable=email_var).pack(pady=5)
            
            ttk.Label(dialog, text="Phone:").pack(pady=5)
            phone_var = tk.StringVar(value=customer[2])
            ttk.Entry(dialog, textvariable=phone_var).pack(pady=5)
            
            def save():
                # Validate inputs
                if not name_var.get() or not email_var.get() or not phone_var.get():
                    messagebox.showerror("Error", "All fields are required")
                    return
                
                if not self.security.validate_email(email_var.get()):
                    messagebox.showerror("Error", "Invalid email format")
                    return
                
                if not self.security.validate_phone(phone_var.get()):
                    messagebox.showerror("Error", "Invalid phone number format")
                    return
                
                try:
                    # Update customer
                    query = """
                        UPDATE Customer 
                        SET Name = %s, Email = %s, PhoneNumber = %s
                        WHERE CustomerID = %s
                    """
                    self.cursor.execute(query, (
                        self.security.sanitize_input(name_var.get()),
                        self.security.sanitize_input(email_var.get()),
                        self.security.sanitize_input(phone_var.get()),
                        customer_id
                    ))
                    self.conn.commit()
                    
                    # Refresh the list
                    self.refresh_customer_list(tree)
                    dialog.destroy()
                    messagebox.showinfo("Success", "Customer updated successfully")
                except mysql.connector.Error as err:
                    messagebox.showerror("Error", f"Failed to update customer: {err}")
            
            ttk.Button(dialog, text="Save", command=save).pack(pady=20)
        except mysql.connector.Error as err:
            messagebox.showerror("Error", f"Failed to fetch customer data: {err}")
            dialog.destroy()
    
    def delete_customer(self, tree):
        """Delete selected customer"""
        selected = tree.selection()
        if not selected:
            messagebox.showwarning("Warning", "Please select a customer to delete")
            return
        
        # Get customer data
        customer_id = tree.item(selected[0])['values'][0]
        customer_name = tree.item(selected[0])['values'][1]
        
        # Confirm deletion
        if not messagebox.askyesno("Confirm Delete", f"Are you sure you want to delete {customer_name}?"):
            return
        
        try:
            # Delete customer (cascade will handle related records)
            query = "DELETE FROM Customer WHERE CustomerID = %s"
            self.cursor.execute(query, (customer_id,))
            self.conn.commit()
            
            # Refresh the list
            self.refresh_customer_list(tree)
            messagebox.showinfo("Success", "Customer deleted successfully")
        except mysql.connector.Error as err:
            messagebox.showerror("Error", f"Failed to delete customer: {err}")
    
    def show_account_operations(self):
        if not self.check_session():
            return
            
        # Create new window for account operations
        account_window = tk.Toplevel(self.root)
        account_window.title("Account Operations")
        account_window.geometry("1000x700")
        
        # Create main frame
        main_frame = ttk.Frame(account_window, padding="10")
        main_frame.pack(fill=tk.BOTH, expand=True)
        
        # Header with back button
        header_frame = ttk.Frame(main_frame)
        header_frame.pack(fill=tk.X, pady=(0, 10))
        
        self.create_back_button(header_frame, account_window.destroy)
        self.create_header(header_frame, "Account Operations")
        
        # Create treeview
        columns = ('AccountID', 'Customer', 'Type', 'Balance')
        tree = self.create_treeview(main_frame, columns)
        
        # Button frame
        button_frame = self.create_button_frame(main_frame)
        
        # Add CRUD buttons
        ttk.Button(button_frame, text="Add Account", command=lambda: self.add_account(tree)).pack(side=tk.LEFT, padx=5)
        ttk.Button(button_frame, text="Edit Account", command=lambda: self.edit_account(tree)).pack(side=tk.LEFT, padx=5)
        ttk.Button(button_frame, text="Delete Account", command=lambda: self.delete_account(tree)).pack(side=tk.LEFT, padx=5)
        
        # Fetch and display accounts
        self.refresh_account_list(tree)
    
    def refresh_account_list(self, tree):
        """Refresh the account list in the treeview"""
        # Clear existing items
        for item in tree.get_children():
            tree.delete(item)
        
        # Fetch and display accounts
        try:
            query = """
                SELECT a.AccountID, c.Name, at.Type, a.Balance
                FROM Account a
                JOIN Customer c ON a.CustomerID = c.CustomerID
                JOIN AccountType at ON a.AccountID = at.AccountID
            """
            self.cursor.execute(query)
            for row in self.cursor.fetchall():
                tree.insert('', 'end', values=row)
        except mysql.connector.Error as err:
            messagebox.showerror("Error", f"Failed to fetch accounts: {err}")
    
    def add_account(self, tree):
        """Add a new account"""
        # Create dialog window
        dialog = tk.Toplevel(self.root)
        dialog.title("Add Account")
        dialog.geometry("400x300")
        
        # Get list of customers
        try:
            self.cursor.execute("SELECT CustomerID, Name FROM Customer")
            customers = self.cursor.fetchall()
        except mysql.connector.Error as err:
            messagebox.showerror("Error", f"Failed to fetch customers: {err}")
            dialog.destroy()
            return
        
        # Create input fields
        ttk.Label(dialog, text="Customer:").pack(pady=5)
        customer_var = tk.StringVar()
        customer_combo = ttk.Combobox(dialog, textvariable=customer_var)
        customer_combo['values'] = [f"{c[1]} ({c[0]})" for c in customers]
        customer_combo.pack(pady=5)
        
        ttk.Label(dialog, text="Account Type:").pack(pady=5)
        type_var = tk.StringVar()
        type_combo = ttk.Combobox(dialog, textvariable=type_var)
        type_combo['values'] = ['Chequing', 'Saving', 'TFSA', 'RRSP', 'RESP', 'FHSA']
        type_combo.pack(pady=5)
        
        ttk.Label(dialog, text="Initial Balance:").pack(pady=5)
        balance_var = tk.StringVar(value="0.00")
        ttk.Entry(dialog, textvariable=balance_var).pack(pady=5)
        
        def save():
            # Validate inputs
            if not customer_var.get() or not type_var.get() or not balance_var.get():
                messagebox.showerror("Error", "All fields are required")
                return
            
            try:
                # Get customer ID from selection
                customer_id = int(customer_var.get().split('(')[1].rstrip(')'))
                
                # Insert new account
                query = "INSERT INTO Account (CustomerID, Balance) VALUES (%s, %s)"
                self.cursor.execute(query, (customer_id, float(balance_var.get())))
                account_id = self.cursor.lastrowid
                
                # Insert account type
                query = "INSERT INTO AccountType (AccountID, Type) VALUES (%s, %s)"
                self.cursor.execute(query, (account_id, type_var.get()))
                
                self.conn.commit()
                
                # Refresh the list
                self.refresh_account_list(tree)
                dialog.destroy()
                messagebox.showinfo("Success", "Account added successfully")
            except (ValueError, mysql.connector.Error) as err:
                messagebox.showerror("Error", f"Failed to add account: {err}")
        
        ttk.Button(dialog, text="Save", command=save).pack(pady=20)
    
    def edit_account(self, tree):
        """Edit selected account"""
        selected = tree.selection()
        if not selected:
            messagebox.showwarning("Warning", "Please select an account to edit")
            return
        
        # Get account data
        account_id = tree.item(selected[0])['values'][0]
        
        # Create dialog window
        dialog = tk.Toplevel(self.root)
        dialog.title("Edit Account")
        dialog.geometry("400x300")
        
        # Fetch current account data
        try:
            query = """
                SELECT a.Balance, at.Type
                FROM Account a
                JOIN AccountType at ON a.AccountID = at.AccountID
                WHERE a.AccountID = %s
            """
            self.cursor.execute(query, (account_id,))
            account = self.cursor.fetchone()
            
            if not account:
                messagebox.showerror("Error", "Account not found")
                dialog.destroy()
                return
            
            # Create input fields with current values
            ttk.Label(dialog, text="Account Type:").pack(pady=5)
            type_var = tk.StringVar(value=account[1])
            type_combo = ttk.Combobox(dialog, textvariable=type_var)
            type_combo['values'] = ['Chequing', 'Saving', 'TFSA', 'RRSP', 'RESP', 'FHSA']
            type_combo.pack(pady=5)
            
            ttk.Label(dialog, text="Balance:").pack(pady=5)
            balance_var = tk.StringVar(value=str(account[0]))
            ttk.Entry(dialog, textvariable=balance_var).pack(pady=5)
            
            def save():
                # Validate inputs
                if not type_var.get() or not balance_var.get():
                    messagebox.showerror("Error", "All fields are required")
                    return
                
                try:
                    # Update account type
                    query = "UPDATE AccountType SET Type = %s WHERE AccountID = %s"
                    self.cursor.execute(query, (type_var.get(), account_id))
                    
                    # Update balance
                    query = "UPDATE Account SET Balance = %s WHERE AccountID = %s"
                    self.cursor.execute(query, (float(balance_var.get()), account_id))
                    
                    self.conn.commit()
                    
                    # Refresh the list
                    self.refresh_account_list(tree)
                    dialog.destroy()
                    messagebox.showinfo("Success", "Account updated successfully")
                except (ValueError, mysql.connector.Error) as err:
                    messagebox.showerror("Error", f"Failed to update account: {err}")
            
            ttk.Button(dialog, text="Save", command=save).pack(pady=20)
        except mysql.connector.Error as err:
            messagebox.showerror("Error", f"Failed to fetch account data: {err}")
            dialog.destroy()
    
    def delete_account(self, tree):
        """Delete selected account"""
        selected = tree.selection()
        if not selected:
            messagebox.showwarning("Warning", "Please select an account to delete")
            return
        
        # Get account data
        account_id = tree.item(selected[0])['values'][0]
        customer_name = tree.item(selected[0])['values'][1]
        
        # Confirm deletion
        if not messagebox.askyesno("Confirm Delete", f"Are you sure you want to delete the account for {customer_name}?"):
            return
        
        try:
            # Delete account (cascade will handle related records)
            query = "DELETE FROM Account WHERE AccountID = %s"
            self.cursor.execute(query, (account_id,))
            self.conn.commit()
            
            # Refresh the list
            self.refresh_account_list(tree)
            messagebox.showinfo("Success", "Account deleted successfully")
        except mysql.connector.Error as err:
            messagebox.showerror("Error", f"Failed to delete account: {err}")
    
    def show_transaction_history(self):
        if not self.check_session():
            return
            
        # Create new window for transaction history
        transaction_window = tk.Toplevel(self.root)
        transaction_window.title("Transaction History")
        transaction_window.geometry("1000x700")
        
        # Create main frame
        main_frame = ttk.Frame(transaction_window, padding="10")
        main_frame.pack(fill=tk.BOTH, expand=True)
        
        # Header with back button
        header_frame = ttk.Frame(main_frame)
        header_frame.pack(fill=tk.X, pady=(0, 10))
        
        self.create_back_button(header_frame, transaction_window.destroy)
        self.create_header(header_frame, "Transaction History")
        
        # Create treeview
        columns = ('TransactionID', 'Date', 'Type', 'Amount', 'Account', 'Description')
        tree = self.create_treeview(main_frame, columns)
        
        # Fetch and display transactions
        try:
            query = """
                SELECT t.TransactionID, t.TransactionDate, t.TransactionType, 
                       t.Amount, c.Name, t.Description
                FROM Transactions t
                JOIN Account a ON t.AccountID = a.AccountID
                JOIN Customer c ON a.CustomerID = c.CustomerID
                ORDER BY t.TransactionDate DESC
            """
            self.cursor.execute(query)
            for row in self.cursor.fetchall():
                tree.insert('', 'end', values=row)
        except mysql.connector.Error as err:
            messagebox.showerror("Error", f"Failed to fetch transactions: {err}")
    
    def show_loan_management(self):
        if not self.check_session():
            return
            
        # Create new window for loan management
        loan_window = tk.Toplevel(self.root)
        loan_window.title("Loan Management")
        loan_window.geometry("1000x700")
        
        # Create main frame
        main_frame = ttk.Frame(loan_window, padding="10")
        main_frame.pack(fill=tk.BOTH, expand=True)
        
        # Header with back button
        header_frame = ttk.Frame(main_frame)
        header_frame.pack(fill=tk.X, pady=(0, 10))
        
        self.create_back_button(header_frame, loan_window.destroy)
        self.create_header(header_frame, "Loan Management")
        
        # Create treeview
        columns = ('LoanID', 'Customer', 'Type', 'Amount', 'InterestRate', 'Status')
        tree = self.create_treeview(main_frame, columns)
        
        # Fetch and display loans
        try:
            query = """
                SELECT l.LoanID, c.Name, l.LoanType, l.Amount, 
                       l.InterestRate, l.Status
                FROM Loan l
                JOIN Customer c ON l.CustomerID = c.CustomerID
                ORDER BY l.LoanID
            """
            self.cursor.execute(query)
            for row in self.cursor.fetchall():
                tree.insert('', 'end', values=row)
        except mysql.connector.Error as err:
            messagebox.showerror("Error", f"Failed to fetch loans: {err}")
    
    def show_reports(self):
        if not self.check_session():
            return
            
        # Create new window for reports
        report_window = tk.Toplevel(self.root)
        report_window.title("Banking Reports")
        report_window.geometry("1000x700")
        
        # Create main frame
        main_frame = ttk.Frame(report_window, padding="10")
        main_frame.pack(fill=tk.BOTH, expand=True)
        
        # Header with back button
        header_frame = ttk.Frame(main_frame)
        header_frame.pack(fill=tk.X, pady=(0, 10))
        
        self.create_back_button(header_frame, report_window.destroy)
        self.create_header(header_frame, "Banking Reports")
        
        # Create notebook for different reports
        notebook = ttk.Notebook(main_frame)
        notebook.pack(fill=tk.BOTH, expand=True, padx=10, pady=5)
        
        # Customer Financial Summary Report
        summary_frame = ttk.Frame(notebook)
        notebook.add(summary_frame, text='Customer Summary')
        
        # Create treeview for summary
        columns = ('CustomerID', 'Name', 'TotalBalance', 'ActiveLoans', 'InsuranceProducts')
        tree = self.create_treeview(summary_frame, columns)
        
        # Fetch and display summary
        try:
            query = """
                SELECT 
                    c.CustomerID,
                    c.Name,
                    COALESCE(SUM(a.Balance), 0) as TotalBalance,
                    COUNT(DISTINCT l.LoanID) as ActiveLoans,
                    COUNT(DISTINCT i.InsuranceID) as InsuranceProducts
                FROM Customer c
                LEFT JOIN Account a ON c.CustomerID = a.CustomerID
                LEFT JOIN Loan l ON c.CustomerID = l.CustomerID AND l.Status = 'Active'
                LEFT JOIN Insurance i ON c.CustomerID = i.CustomerID
                GROUP BY c.CustomerID, c.Name
                ORDER BY TotalBalance DESC
            """
            self.cursor.execute(query)
            for row in self.cursor.fetchall():
                tree.insert('', 'end', values=row)
        except mysql.connector.Error as err:
            messagebox.showerror("Error", f"Failed to fetch summary: {err}")

if __name__ == "__main__":
    root = tk.Tk()
    app = BankingSystemGUI(root)
    root.mainloop() 