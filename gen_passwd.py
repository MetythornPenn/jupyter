from jupyter_server.auth import passwd
import sys

def generate_password_hash(password=None):
    """Generate a password hash for Jupyter authentication"""
    if not password:
        password = sys.argv[1] if len(sys.argv) > 1 else "metythorn"

    hashed = passwd(password)
    print(f"Password: {password}")
    print(f"Hash: {hashed}")
    print("\nAdd this to your Makefile in the run target:")
    print(f"--ServerApp.password='{hashed}'")

if __name__ == "__main__":
    generate_password_hash()
