import os
import subprocess
import threading
import gradio as gr
import sys
import time

# 1. Print directory structure to Logs for debugging
print("--- Current Directory Content ---")
print(os.listdir("."))

def run_django():
    try:
        # Check if the backend folder exists
        if not os.path.exists("HealthSphere_backend"):
            print("ERROR: 'HealthSphere_backend' folder not found!")
            return

        print("Starting Django server...")
        os.chdir("HealthSphere_backend")

        # Run migrations just in case it's a fresh deploy
        subprocess.run(["python", "manage.py", "migrate"])

        # Start Django on port 8000
        # Using 0.0.0.0 to make it accessible within the container
        os.system("python manage.py runserver 0.0.0.0:8000")
    except Exception as e:
        print(f"Django Error: {e}")

# 2. Start Django in a background thread
django_thread = threading.Thread(target=run_django, daemon=True)
django_thread.start()

# 3. Simple Gradio interface
def health_check(name):
    return f"HealthSphere Backend is running! Hello {name}. Django is active on port 8000."

demo = gr.Interface(
    fn=health_check,
    inputs="text",
    outputs="text",
    title="HealthSphere Backend Server",
    description="Backend status: Check 'Logs' for Django output."
)

if __name__ == "__main__":
    # Gradio MUST run on port 7860
    demo.launch(server_name="0.0.0.0", server_port=7860)
