import os
import mysql.connector
from dotenv import load_dotenv

load_dotenv()

class DatabaseConnection:
    """Context Manager for Database connection"""

    def __init__(self):
        self.config = {
            'host': os.getenv('DB_HOST', 'localhost'),
            'user': os.getenv('DB_USER', 'root'),
            'password': os.getenv('DB_PASSWORD', ''),
            'database': os.getenv('DB_NAME', 'school_db')
        }

    def __enter__(self):
        self.conn = mysql.connector.connect(**self.config)
        self.cursor = self.conn.cursor()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.cursor.close()
        self.conn.close()

    def execute_query(self, query, params=None):
        """Execute a query and return results with column names"""
        if not params:
            params = ()
        self.cursor.execute(query, params)
        return self.cursor.fetchall(), [desc[0] for desc in self.cursor.description]