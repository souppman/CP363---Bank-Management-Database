-- Drop existing User table if it exists
DROP TABLE IF EXISTS User;

-- Create User table
CREATE TABLE User (
    UserID INT AUTO_INCREMENT PRIMARY KEY,
    Username VARCHAR(50) NOT NULL UNIQUE,
    Password VARCHAR(255) NOT NULL,
    Role ENUM('Admin', 'Teller', 'Customer') NOT NULL,
    CustomerID INT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID) ON DELETE SET NULL
);

-- Insert admin user (password: admin123)
INSERT INTO User (Username, Password, Role) 
VALUES ('admin', 'admin123', 'Admin'); 