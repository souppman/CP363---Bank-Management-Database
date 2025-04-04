# CP363 Banking Database System

All our work for CP363 Database course - A banking system implementation from schema design through to GUI development.

## Setup Instructions

### Prerequisites
- Python 3.x
- MySQL Server
- Required Python packages:
  ```bash
  pip install mysql-connector-python
  pip install tkinter
  ```

### Database Setup
1. Start MySQL server
2. Create database:
   ```sql
   CREATE DATABASE BankingSystem4;
   ```
3. Import schema:
   ```bash
   mysql -u root -p BankingSystem4 < banking_schema_A4.1.sql
   ```

### Running the Application
```bash
python banking_gui.py
```

## Git Commands Cheat Sheet

### First Time Setup
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Basic Commands
```bash
# Check status
git status

# Add files
git add .                    # Add all files
git add filename.txt         # Add specific file

# Commit changes
git commit -m "Your message"

# Push changes
git push origin main

# Pull updates
git pull origin main

# Create new branch
git checkout -b branch-name

# Switch branches
git checkout branch-name
```

### Common Scenarios
```bash
# Undo last commit (keep changes)
git reset --soft HEAD~1

# Discard local changes
git checkout -- filename.txt

# Update branch with main
git checkout main
git pull
git checkout your-branch
git merge main
```

### Fixing Mistakes
```bash
# Undo staged changes
git reset filename.txt

# Undo commits
git reset --hard HEAD~1      # Last commit
git reset --hard commit-hash # Specific commit
```