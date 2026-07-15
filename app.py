import os
import subprocess
import threading
import gradio as gr
import time
import sys

def log(message):
    print(f"[LOG] {message}", flush=True)

def start_django():
    try:
        # Give Gradio a 2-second head start to satisfy HF health checks
        time.sleep(2)

        backend_dir = "HealthSphere_backend"
        if not os.path.exists(backend_dir):
            log("Backend folder missing!")
            return

        log("Running migrations...")
        subprocess.run([sys.executable, "manage.py", "migrate"], cwd=backend_dir)

        log("Setting up superuser...")
        admin_email = os.getenv("DJANGO_ADMIN_EMAIL", "admin@example.com")
        admin_pass = os.getenv("DJANGO_ADMIN_PASSWORD", "admin123")

        script = f"""
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(email='{admin_email}').exists():
    User.objects.create_superuser(email='{admin_email}', password='{admin_pass}', full_name='System Admin')
    print('Superuser created.')
else:
    print('Superuser exists.')
"""
        subprocess.run([sys.executable, "manage.py", "shell", "-c", script], cwd=backend_dir)

        log("Starting Django Server...")
        # We use runserver for now as it's easier to debug in the logs
        os.system(f"cd {backend_dir} && python manage.py runserver 0.0.0.0:8000")

    except Exception as e:
        log(f"Error: {e}")

# Start backend in a background thread
threading.Thread(target=start_django, daemon=True).start()

# Launch Gradio (Main Thread)
with gr.Blocks() as demo:
    gr.Markdown("# 🏥 HealthSphere Backend")
    gr.Markdown("Status: **Online**")
    gr.Markdown("The Django API is running on port 8000.")
    gr.Markdown("Admin: `/admin` (admin@example.com / admin123)")

if __name__ == "__main__":
    # Launch Gradio on 7860
    demo.launch(server_name="0.0.0.0", server_port=7860)
