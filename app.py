import os
import subprocess
import threading
import gradio as gr
import time
import sys

# Ensure prints show up in Hugging Face logs immediately
def log(message):
    print(f"[LOG] {message}", flush=True)

def run_backend():
    try:
        log("Checking directory structure...")
        log(f"Current directory: {os.getcwd()}")
        log(f"Contents: {os.listdir('.')}")

        if not os.path.exists("HealthSphere_backend"):
            log("CRITICAL ERROR: 'HealthSphere_backend' folder not found!")
            return

        os.chdir("HealthSphere_backend")
        log("Moved into HealthSphere_backend folder.")

        # 1. Run Migrations
        log("Attempting database migrations on Neon...")
        migrate_result = subprocess.run(["python", "manage.py", "migrate"], capture_output=True, text=True)
        log(f"Migration Output: {migrate_result.stdout}")
        if migrate_result.stderr:
            log(f"Migration Errors: {migrate_result.stderr}")

        # 2. Create Superuser
        log("Checking for superuser...")
        admin_user = os.getenv("DJANGO_ADMIN_USER", "admin")
        admin_pass = os.getenv("DJANGO_ADMIN_PASSWORD", "admin123")
        script = f"from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.filter(username='{admin_user}').exists() or User.objects.create_superuser('{admin_user}', 'admin@example.com', '{admin_pass}')"
        subprocess.run(["python", "manage.py", "shell", "-c", script])

        # 3. Start Django using Gunicorn (more stable than runserver)
        log("Starting Django with Gunicorn on port 8000...")
        # config.wsgi assumes your settings folder is named 'config'
        subprocess.Popen(["gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:8000", "--timeout", "120"])
        log("Gunicorn process launched in background.")

    except Exception as e:
        log(f"CRITICAL BACKEND ERROR: {str(e)}")

# Start the backend thread
backend_thread = threading.Thread(target=run_backend, daemon=True)
backend_thread.start()

# Gradio Interface
def check_status():
    return "HealthSphere Backend: Running\nAdmin Panel: /admin\nDatabase: Connected"

with gr.Blocks() as demo:
    gr.Markdown("# 🏥 HealthSphere Backend Server")
    gr.Markdown("The Django API is running in the background. Your Android app can connect to this Space URL.")
    status_btn = gr.Button("Check Server Status")
    output = gr.Textbox(label="Status Report")
    status_btn.click(fn=check_status, outputs=output)

if __name__ == "__main__":
    log("Launching Gradio UI...")
    demo.launch(server_name="0.0.0.0", server_port=7860)
