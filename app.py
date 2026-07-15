import os
import sys
import subprocess
import time

def log(msg):
    print(f"[SYSTEM] {msg}", flush=True)

# 1. Setup Environment
base_dir = os.path.dirname(os.path.abspath(__file__))
backend_dir = os.path.join(base_dir, "HealthSphere_backend")

log("Starting deployment sequence...")
log(f"Backend directory: {backend_dir}")

try:
    # 2. Run Migrations
    log("Running Django Migrations...")
    subprocess.run([sys.executable, "manage.py", "migrate"], cwd=backend_dir, check=True)

    # 3. Create Superuser (Email-based)
    log("Checking Superuser account...")
    admin_email = os.getenv("DJANGO_ADMIN_EMAIL", "admin@example.com")
    admin_pass = os.getenv("DJANGO_ADMIN_PASSWORD", "admin123")

    script = f"""
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(email='{admin_email}').exists():
    User.objects.create_superuser(email='{admin_email}', password='{admin_pass}', full_name='System Admin')
    print('Superuser created successfully.')
else:
    print('Superuser already exists.')
"""
    subprocess.run([sys.executable, "manage.py", "shell", "-c", script], cwd=backend_dir)

    # 4. Start Server on 7860
    log("Launching Gunicorn on port 7860...")
    # Add backend_dir to sys.path so gunicorn can find the config module
    os.environ['PYTHONPATH'] = backend_dir

    # Execute Gunicorn
    # We use os.execvp to replace the current process with gunicorn
    # This ensures the process stays alive as the main container process
    os.chdir(backend_dir)
    os.execvp("gunicorn", ["gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:7860", "--timeout", "600", "--log-level", "info"])

except Exception as e:
    log(f"CRITICAL ERROR during deployment: {e}")
    # Keep the process alive for an hour so logs can be inspected
    time.sleep(3600)
