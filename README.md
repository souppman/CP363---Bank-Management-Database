# CP363 Banking System Project

This repository contains my coursework for CP363 (Database Systems & Design) at Wilfrid Laurier University. The project implements a secure banking system with a GUI interface, building upon the database schemas and SQL code developed throughout the course assignments.

## Project Structure

The project is organized by assignments and components:

### Database Components
- `banking_schema_A4.1.sql`: Initial database schema with tables
- `banking_database_A5.sql`: Extended schema with additional functionality
- `a6.sql`: Assignment 6 database modifications
- `a7_tables.sql`: Assignment 7 table structures
- `a8.sql`: Assignment 8 final database implementation

### Application Components
- `banking_gui.py`: GUI implementation using Python/tkinter
- `security.py`: Security implementation and authentication
- `config.py`: Configuration management
- `requirements.txt`: Python package dependencies

## Features

- Customer Management
- Account Operations
- Transaction History
- Loan Management
- Financial Reports
- Secure Authentication

## Database Design

The database is designed following database normalization principles:
- Third Normal Form (3NF)
- Boyce-Codd Normal Form (BCNF)
- Proper foreign key relationships
- Index optimization

## Security Implementation

This implementation includes several security measures:
- Password hashing with salt
- Input sanitization to prevent SQL injection
- Session timeout
- Login attempt limiting
- Environment variable-based configuration
- Secure password requirements

## Setup Instructions

1. Clone the repository:
   ```bash
   git clone <your-repository-url>
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
   - Run the SQL scripts in order:
     1. `banking_schema_A4.1.sql`
     2. `banking_database_A5.sql`
     3. `a6.sql`
     4. `a7_tables.sql`
     5. `a8.sql`

6. Run the application:
   ```bash
   python banking_gui.py
   ```

## Development Notes

- Built with Python 3.8+
- Uses MySQL for database management
- Implements secure coding practices
- Follows object-oriented design principles

## Security Best Practices

1. Never commit the `.env` file to version control
2. Use strong passwords for database access
3. Regularly update the password salt in production
4. Keep Python packages up to date
5. Use HTTPS in production environments
6. Implement proper backup procedures

## Course Information

- Course: CP363 Database Systems & Design
- Institution: Wilfrid Laurier University
- Term: Winter 2024

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

Database schema design inspired by course materials and assignments from CP363 at Wilfrid Laurier University.

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
