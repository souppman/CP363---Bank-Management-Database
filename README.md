# Banking System GUI Application

This is a Python-based GUI application for managing a banking system. The application provides a user-friendly interface for managing customers, accounts, transactions, loans, and generating reports.

## Features

- Customer Management
- Account Operations
- Transaction History
- Loan Management
- Financial Reports

## Prerequisites

- Python 3.6 or higher
- MySQL Server
- MySQL Connector for Python

## Setup Instructions

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/banking-system.git
   cd banking-system
   ```

2. Create and activate a virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. Install required packages:
   ```bash
   pip install -r requirements.txt
   ```

4. Set up environment variables:
   ```bash
   cp .env.example .env
   ```
   Edit the `.env` file with your database credentials and security settings.

5. Set up the database:
   - Create a MySQL database named `BankingSystem4`
   - Run the provided SQL scripts to create the required tables

6. Run the application:
   ```bash
   python banking_gui.py
   ```

## Security Best Practices

1. Never commit the `.env` file to version control
2. Use strong passwords for database access
3. Regularly update the password salt in production
4. Keep your Python packages up to date
5. Use HTTPS in production environments
6. Implement proper backup procedures for the database

## Development

- The application uses Python 3.8+
- Dependencies are managed through `requirements.txt`
- Environment variables are managed through `.env`
- Database credentials are never stored in the code

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Database Normalization

The database is normalized to Boyce-Codd Normal Form (BCNF), ensuring:
- No redundant data
- Data integrity
- Efficient storage
- Proper relationships between tables

## Special Cases and Advanced Reports

The application includes several advanced features:

1. Customer Financial Summary:
   - Shows total balance across all accounts
   - Displays active loans
   - Lists insurance products
   - Sorted by total balance

2. Transaction History:
   - Chronological view of all transactions
   - Includes transaction type, amount, and description
   - Links transactions to customer accounts

3. Loan Management:
   - Shows loan status and interest rates
   - Displays loan types and amounts
   - Tracks active vs. closed loans

4. Account Operations:
   - Displays account types (Chequing, Saving, TFSA, etc.)
   - Shows current balances
   - Links accounts to customers

## Error Handling

The application includes comprehensive error handling for:
- Database connection issues
- Query execution errors
- Invalid data entry
- Missing records

## Security Considerations

- Database credentials should be stored securely
- User input is validated before processing
- SQL injection prevention through parameterized queries
- Proper error messages without exposing sensitive information
