import os
import subprocess
import threading
import gradio as gr
import time
import sys

# Global log storage
execution_logs = []

def log(message):
    msg = f"[{time.strftime('%H:%M:%S')}] {message}"
    print(msg, flush=True)
    execution_logs.append(msg)

def start_backend():
    try:
        backend_dir = "HealthSphere_backend"

        # 1. Migrations
        log("Running migrations...")
        subprocess.run([sys.executable, "manage.py", "migrate"], cwd=backend_dir)

        # 2. Superuser (using EMAIL because your model doesn't have 'username')
        admin_email = os.getenv("DJANGO_ADMIN_EMAIL", "admin@example.com")
        admin_pass = os.getenv("DJANGO_ADMIN_PASSWORD", "admin123")
        admin_full_name = "System Admin"

        script = f"""
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(email='{admin_email}').exists():
    User.objects.create_superuser(email='{admin_email}', password='{admin_pass}', full_name='{admin_full_name}')
    print('Superuser created.')
else:
    print('Superuser already exists.')
"""
        subprocess.run([sys.executable, "manage.py", "shell", "-c", script], cwd=backend_dir)

        # 3. Start Gunicorn
        log("Starting Gunicorn on port 8000...")
        subprocess.Popen(
            ["gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:8000", "--timeout", "120"],
            cwd=backend_dir
        )
    except Exception as e:
        log(f"Error: {e}")

# Start backend in a thread
threading.Thread(target=start_backend, daemon=True).start()

# Tiny Gradio UI
with gr.Blocks() as demo:
    gr.Markdown("# 🏥 HealthSphere Backend")
    gr.Markdown("Server is active. Admin panel available at `/admin`.")
    gr.Markdown("Using email login: `admin@example.com` / `admin123` (or your secrets)")

if __name__ == "__main__":
    demo.launch(server_name="0.0.0.0", server_port=7860)
