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

def run_command(command, cwd=None):
    log(f"Executing: {' '.join(command)}")
    result = subprocess.run(command, capture_output=True, text=True, cwd=cwd)
    if result.stdout:
        log(f"STDOUT: {result.stdout}")
    if result.stderr:
        log(f"STDERR: {result.stderr}")
    return result.returncode == 0

def start_backend():
    try:
        log("Checking environment...")
        db_url = os.getenv("DATABASE_URL")
        if not db_url:
            log("WARNING: DATABASE_URL secret is missing!")
        else:
            log(f"DATABASE_URL found (starts with: {db_url[:15]}...)")

        # 1. Migrations
        backend_dir = "HealthSphere_backend"
        if run_command([sys.executable, "manage.py", "migrate"], cwd=backend_dir):
            log("Migrations successful.")
        else:
            log("Migrations failed. Check logs above.")

        # 2. Superuser
        admin_user = os.getenv("DJANGO_ADMIN_USER", "admin")
        admin_pass = os.getenv("DJANGO_ADMIN_PASSWORD", "admin123")
        script = f"from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.filter(username='{admin_user}').exists() or User.objects.create_superuser('{admin_user}', 'admin@example.com', '{admin_pass}')"
        run_command([sys.executable, "manage.py", "shell", "-c", script], cwd=backend_dir)

        # 3. Start Gunicorn
        log("Starting Gunicorn...")
        # We don't use subprocess.run here because Gunicorn stays open
        subprocess.Popen(
            ["gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:8000", "--log-level", "debug"],
            cwd=backend_dir
        )
        log("Gunicorn process sent to background.")

    except Exception as e:
        log(f"Error in backend thread: {str(e)}")

# UI Logic
def get_logs():
    return "\n".join(execution_logs)

with gr.Blocks(title="HealthSphere Control Center") as demo:
    gr.Markdown("# 🏥 HealthSphere Backend Control Center")

    with gr.Row():
        with gr.Column():
            status_display = gr.Textbox(label="Live Logs", value="Initializing...", lines=20, max_lines=30)
            refresh_btn = gr.Button("🔄 Refresh Logs")

        with gr.Column():
            gr.Markdown("### Server Info")
            gr.Markdown("- **API Status:** Check logs on left")
            gr.Markdown("- **Admin Panel:** [Click Here](/admin) (Login: admin / admin123)")
            gr.Markdown("- **Database:** Neon PostgreSQL")

            redeploy_btn = gr.Button("🚀 Retry Deployment/Migrations")

    refresh_btn.click(fn=get_logs, outputs=status_display)
    redeploy_btn.click(fn=start_backend).then(fn=get_logs, outputs=status_display)

    # Auto-refresh logs on load
    demo.load(fn=get_logs, outputs=status_display)

if __name__ == "__main__":
    # Start the backend immediately
    threading.Thread(target=start_backend, daemon=True).start()

    log("Launching Control Center UI...")
    demo.launch(server_name="0.0.0.0", server_port=7860)
