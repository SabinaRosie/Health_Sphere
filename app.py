import os
import sys
import subprocess
import gradio as gr
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

# 3. Initialize Django
run_migrations()

# 4. Create Gradio Interface
with gr.Blocks() as demo:
    gr.Markdown("# 🏥 HealthSphere Backend")
    gr.Markdown("### ✅ Status: Online")
    gr.Markdown("---")
    gr.Markdown("- **Admin Panel:** [Click here to login](/admin/)")
    gr.Markdown("- **API Root:** [Click here](/api/)")
    gr.Markdown("---")
    gr.Markdown("Your Android app should connect to: `https://manikadahal-health-sphere.hf.space/api/`")

# 5. The "Magic" - Mount Django as a WSGI Middleware on Gradio's app
# We use demo.app which is the underlying FastAPI instance
app = demo.app
app.mount("/api", WSGIMiddleware(django_app))
app.mount("/admin", WSGIMiddleware(django_app))
app.mount("/static", WSGIMiddleware(django_app))

if __name__ == "__main__":
    # Let Gradio handle the server launch on 7860
    # This is more stable on Hugging Face than calling uvicorn manually
    demo.launch(server_name="0.0.0.0", server_port=7860)
