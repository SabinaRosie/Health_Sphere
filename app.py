import os
import subprocess
import threading
import gradio as gr
import time

def run_django():
    try:
        print("Waiting for environment...")
        time.sleep(5) # Give the container a moment to settle
        print("Starting Django setup...")
        os.chdir("HealthSphere_backend")

        # 1. Run migrations
        subprocess.run(["python", "manage.py", "migrate"])

        # 2. Create Superuser automatically
        # We use environment variables for safety.
        # You can set these in Hugging Face Settings -> Secrets.
        # Default fallback is admin/admin123 for now.
        admin_user = os.getenv("DJANGO_ADMIN_USER", "admin")
        admin_email = os.getenv("DJANGO_ADMIN_EMAIL", "admin@example.com")
        admin_password = os.getenv("DJANGO_ADMIN_PASSWORD", "admin123")

        script = f"""
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='{admin_user}').exists():
    User.objects.create_superuser('{admin_user}', '{admin_email}', '{admin_password}')
    print('Superuser created successfully!')
else:
    print('Superuser already exists.')
"""
        subprocess.run(["python", "manage.py", "shell", "-c", script])

        # 3. Start Django on port 8000
        print("Launching Django server on port 8000...")
        os.system("python manage.py runserver 0.0.0.0:8000")
    except Exception as e:
        print(f"Django Error: {e}")

# Start Django in background
threading.Thread(target=run_django, daemon=True).start()

# Gradio interface for status
def health_check(name):
    return f"HealthSphere Backend is LIVE! Admin at /admin. Hello {name}."

demo = gr.Interface(
    fn=health_check,
    inputs="text",
    outputs="text",
    title="HealthSphere Backend Server",
    description="Backend: Active | Admin: /admin | DB: Neon PostgreSQL"
)

if __name__ == "__main__":
    demo.launch(server_name="0.0.0.0", server_port=7860)
