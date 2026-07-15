import os
import sys
import subprocess
import uvicorn
import gradio as gr
from fastapi import FastAPI
from a2wsgi import WSGIMiddleware

# 1. Setup paths
base_dir = os.path.dirname(os.path.abspath(__file__))
backend_dir = os.path.join(base_dir, "HealthSphere_backend")
sys.path.append(backend_dir)

# 2. Setup Django
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")
import django
django.setup()
from config.wsgi import application as django_app

def run_migrations():
    print("[SYSTEM] Running migrations...", flush=True)
    subprocess.run([sys.executable, "manage.py", "migrate"], cwd=backend_dir)

    print("[SYSTEM] Ensuring superuser...", flush=True)
    admin_email = os.getenv("DJANGO_ADMIN_EMAIL", "admin@example.com")
    admin_pass = os.getenv("DJANGO_ADMIN_PASSWORD", "admin123")
    script = f"from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.filter(email='{admin_email}').exists() or User.objects.create_superuser(email='{admin_email}', password='{admin_pass}', full_name='Admin')"
    subprocess.run([sys.executable, "manage.py", "shell", "-c", script], cwd=backend_dir)

# 3. Create Unified App
run_migrations()
main_app = FastAPI()

# 4. Define Gradio Interface
with gr.Blocks() as demo:
    gr.Markdown("# 🏥 HealthSphere Backend")
    gr.Markdown("### ✅ Status: Online")
    gr.Markdown("The server is healthy and running on Hugging Face.")
    gr.Markdown("---")
    gr.Markdown("- **Admin Panel:** [Click here to login](/admin/)")
    gr.Markdown("- **API Root:** [Click here](/api/)")
    gr.Markdown("---")
    gr.Markdown("Connect your Flutter app to: `https://manikadahal-health-sphere.hf.space/api/`")

# 5. Mount everything together
# This is the "Magic" - Django and Gradio on the same port!
main_app = gr.mount_gradio_app(main_app, demo, path="/")
main_app.mount("/api", WSGIMiddleware(django_app))
main_app.mount("/admin", WSGIMiddleware(django_app))
main_app.mount("/static", WSGIMiddleware(django_app))

if __name__ == "__main__":
    print("[SYSTEM] Launching unified server on 7860...", flush=True)
    uvicorn.run(main_app, host="0.0.0.0", port=7860)
