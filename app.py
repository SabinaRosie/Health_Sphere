import os
import sys
import subprocess
import threading
import time
import gradio as gr
from fastapi import FastAPI
from fastapi.middleware.wsgi import WSGIMiddleware

# 1. Setup paths
base_dir = os.path.dirname(os.path.abspath(__file__))
backend_dir = os.path.join(base_dir, "HealthSphere_backend")
sys.path.append(backend_dir)

# 2. Prepare Django
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")
import django
django.setup()

from config.wsgi import application as django_app

def run_setup():
    print("[SYSTEM] Running migrations...", flush=True)
    subprocess.run([sys.executable, "manage.py", "migrate"], cwd=backend_dir)

    print("[SYSTEM] Checking Superuser...", flush=True)
    admin_email = os.getenv("DJANGO_ADMIN_EMAIL", "admin@example.com")
    admin_pass = os.getenv("DJANGO_ADMIN_PASSWORD", "admin123")
    script = f"from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.filter(email='{admin_email}').exists() or User.objects.create_superuser(email='{admin_email}', password='{admin_pass}', full_name='System Admin')"
    subprocess.run([sys.executable, "manage.py", "shell", "-c", script], cwd=backend_dir)

run_setup()

# 3. Create FastAPI app to host Django via WSGI
# This allows Django to run on the same port as Gradio
app = FastAPI()
app.mount("/api", WSGIMiddleware(django_app))
app.mount("/admin", WSGIMiddleware(django_app))
app.mount("/static", WSGIMiddleware(django_app))

# 4. Gradio Interface (Main UI)
with gr.Blocks() as demo:
    gr.Markdown("# 🏥 HealthSphere Backend")
    gr.Markdown("Status: **Online and Healthy**")
    gr.Markdown("### 🔗 Quick Links")
    gr.Markdown("- [Admin Panel](/admin/)")
    gr.Markdown("- [API Root](/api/)")
    gr.Markdown("---")
    gr.Markdown("Your Android app should connect to: `https://manikadahal-health-sphere.hf.space/api/`")

# 5. Launch Gradio with the FastAPI 'app' mounted
# This is the "Magic" that keeps everything on one port (7860)
if __name__ == "__main__":
    print("[SYSTEM] Launching combined server...", flush=True)
    demo.launch(server_name="0.0.0.0", server_port=7860)
