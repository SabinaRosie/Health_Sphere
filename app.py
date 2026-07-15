import os
import sys
import subprocess
import threading
import time
import gradio as gr
from a2wsgi import WSGIMiddleware

# 1. Setup paths
base_dir = os.path.dirname(os.path.abspath(__file__))
backend_dir = os.path.join(base_dir, "HealthSphere_backend")
sys.path.append(backend_dir)

# 2. Setup Django Environment
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")
import django
django.setup()
from config.wsgi import application as django_app

def background_setup():
    """Perform heavy tasks in the background so the UI starts instantly"""
    try:
        print("[SYSTEM] Running migrations...", flush=True)
        subprocess.run([sys.executable, "manage.py", "migrate"], cwd=backend_dir)

        print("[SYSTEM] Checking Superuser...", flush=True)
        admin_email = os.getenv("DJANGO_ADMIN_EMAIL", "admin@example.com")
        admin_pass = os.getenv("DJANGO_ADMIN_PASSWORD", "admin123")
        script = f"from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.filter(email='{admin_email}').exists() or User.objects.create_superuser(email='{admin_email}', password='{admin_pass}', full_name='Admin')"
        subprocess.run([sys.executable, "manage.py", "shell", "-c", script], cwd=backend_dir)
        print("[SYSTEM] Background setup complete.", flush=True)
    except Exception as e:
        print(f"[ERROR] Background setup failed: {e}", flush=True)

# 3. Create Gradio Interface
with gr.Blocks(title="HealthSphere Backend") as demo:
    gr.Markdown("# 🏥 HealthSphere Backend")
    gr.Markdown("### ✅ Status: Online")
    gr.Markdown("---")
    gr.Markdown("The Django API and Admin panel are being initialized in the background.")
    gr.Markdown("- **Admin Panel:** [/admin/](/admin/)")
    gr.Markdown("- **API Root:** [/api/](/api/)")
    gr.Markdown("---")
    gr.Markdown("Connect your Flutter app to: `https://manikadahal-health-sphere.hf.space/api/`")

# 4. Mount Django onto Gradio
app = demo.app
app.mount("/api", WSGIMiddleware(django_app))
app.mount("/admin", WSGIMiddleware(django_app))
app.mount("/static", WSGIMiddleware(django_app))

if __name__ == "__main__":
    # Start the migrations in a separate thread
    threading.Thread(target=background_setup, daemon=True).start()

    # Launch Gradio immediately
    demo.launch(server_name="0.0.0.0", server_port=7860)
