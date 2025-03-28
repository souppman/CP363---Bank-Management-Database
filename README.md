# CP363 - Bank Management Database

This repository contains the database schemas, SQL code, and GUI implementation for the CP363 Banking System project, organized by assignments.

## Repository Structure

### Database Components
* `banking_schemaA4.sql`: Assignment 4 - Initial database schema with tables, sample data, and queries
* `banking_schema_A4.1.sql`: Assignment 4.1 - Extended schema with additional test data and complex queries
* `banking_database_A5.sql`: Assignment 5 - Extended schema with additional functionality
* `a6.sql`: Assignment 6 - Database modifications and queries
* `a7_tables.sql`: Assignment 7 - Table structures and relationships
* `a8.sql`: Assignment 8 - Final database implementation

### GUI Components
* `banking_gui.py`: GUI implementation using Python/tkinter
* `security.py`: Security implementation and authentication
* `config.py`: Configuration management
* `requirements.txt`: Python package dependencies

## Getting Started

### Prerequisites

* Git installed on your computer
* MySQL or compatible database management system
* Python 3.8 or higher
* A code editor (e.g., VSCode, MySQL Workbench)

### Cloning the Repository

1. Open your terminal
2. Navigate to where you want to store the project
3. Run the following command:

git clone https://github.com/souppman/CP363---Bank-Management-Database.git

### Setting Up the Environment

1. Create and activate a virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. Install required packages:
```bash
pip install -r requirements.txt
```

3. Set up environment variables:
```bash
cp .env.example .env
```
Edit the `.env` file with your database credentials and security settings.

4. Set up the database:
   - Create a MySQL database named `BankingSystem4`
   - Run the SQL scripts in order:
     1. `banking_schema_A4.1.sql`
     2. `banking_database_A5.sql`
     3. `a6.sql`
     4. `a7_tables.sql`
     5. `a8.sql`

5. Run the application:
```bash
python banking_gui.py
```

### Basic Git Commands

Here are some essential Git commands you'll need:

1. Get the latest updates:

git pull origin main

1. Check status of your changes:

git status

1. Add your changes:

git add filename.sql    # For a specific file
git add .              # For all changes

1. Commit your changes:

git commit -m "Description of your changes"

1. Push your changes:

git push origin main

### Working on Assignments

1. Always pull the latest changes before starting work:

git pull origin main

1. Create/edit the appropriate SQL file for your assignment
2. Test your SQL code locally
3. Commit and push your changes using the commands above

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

## Best Practices

1. Always pull before starting new work
2. Test SQL code locally before committing
3. Use clear commit messages describing your changes
4. Push your changes regularly to avoid conflicts
5. Never commit the `.env` file to version control
6. Use strong passwords for database access
7. Keep Python packages up to date

## Need Help?

If you encounter any issues:

1. Check your Git commands
2. Make sure you have the latest version (`git pull`)
3. Verify database connection settings in `.env`
4. Ensure all SQL scripts are run in the correct order

## About

Bank Management Database Project for CP363