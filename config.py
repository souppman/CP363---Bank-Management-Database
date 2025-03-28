import os
from dotenv import load_dotenv
import sys

# Load environment variables from .env file
load_dotenv()

def get_required_env_var(var_name: str) -> str:
    """Get a required environment variable or exit with error"""
    value = os.getenv(var_name)
    if not value:
        print(f"Error: Required environment variable {var_name} is not set.")
        print("Please copy .env.example to .env and fill in your credentials.")
        sys.exit(1)
    return value

# Database configuration
DB_CONFIG = {
    'host': get_required_env_var('DB_HOST'),
    'user': get_required_env_var('DB_USER'),
    'password': get_required_env_var('DB_PASSWORD'),
    'database': get_required_env_var('DB_NAME')
}

# Application configuration
APP_CONFIG = {
    'session_timeout': 30 * 60,  # 30 minutes in seconds
    'max_login_attempts': 3,
    'password_min_length': 8
}

# Security configuration
SECURITY_CONFIG = {
    'password_salt': get_required_env_var('PASSWORD_SALT')
} 