import hashlib
import jwt
import re
from datetime import datetime, timedelta
from config import SECURITY_CONFIG, APP_CONFIG

class SecurityManager:
    @staticmethod
    def hash_password(password: str) -> str:
        """Hash password using SHA-256 with salt"""
        salt = SECURITY_CONFIG['password_salt']
        return hashlib.sha256((password + salt).encode()).hexdigest()

    @staticmethod
    def validate_password(password: str) -> tuple[bool, str]:
        """Validate password strength"""
        if len(password) < APP_CONFIG['password_min_length']:
            return False, f"Password must be at least {APP_CONFIG['password_min_length']} characters long"
        
        if not re.search(r"[!@#$%^&*(),.?\":{}|<>]", password):
            return False, "Password must contain at least one special character"
        
        if not re.search(r"\d", password):
            return False, "Password must contain at least one number"
        
        if not re.search(r"[A-Z]", password):
            return False, "Password must contain at least one uppercase letter"
        
        return True, "Password is valid"

    @staticmethod
    def generate_token(user_id: int, role: str) -> str:
        """Generate JWT token"""
        payload = {
            'user_id': user_id,
            'role': role,
            'exp': datetime.utcnow() + timedelta(seconds=SECURITY_CONFIG['jwt_expiration'])
        }
        return jwt.encode(payload, SECURITY_CONFIG['jwt_secret'], algorithm='HS256')

    @staticmethod
    def verify_token(token: str) -> tuple[bool, dict]:
        """Verify JWT token"""
        try:
            payload = jwt.decode(token, SECURITY_CONFIG['jwt_secret'], algorithms=['HS256'])
            return True, payload
        except jwt.ExpiredSignatureError:
            return False, {'error': 'Token has expired'}
        except jwt.InvalidTokenError:
            return False, {'error': 'Invalid token'}

    @staticmethod
    def sanitize_input(input_str: str) -> str:
        """Sanitize user input to prevent SQL injection"""
        # Remove potentially dangerous characters
        sanitized = re.sub(r'[;\'\"\\]', '', input_str)
        return sanitized.strip()

    @staticmethod
    def validate_email(email: str) -> bool:
        """Validate email format"""
        pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        return bool(re.match(pattern, email))

    @staticmethod
    def validate_phone(phone: str) -> bool:
        """Validate phone number format"""
        pattern = r'^\+?1?\d{9,15}$'
        return bool(re.match(pattern, phone))

    @staticmethod
    def check_session_timeout(last_activity: datetime) -> bool:
        """Check if session has timed out"""
        timeout = timedelta(seconds=APP_CONFIG['session_timeout'])
        return datetime.now() - last_activity > timeout 