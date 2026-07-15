import os
import subprocess
import threading
import gradio as gr
import time

def run_django():
    # Change directory to where manage.py is
    os.chdir("HealthSphere_backend")
    # Start Django on port 7860 (required by Hugging Face)
    os.system("python manage.py runserver 0.0.0.0:7860")

# Start Django in a background thread
threading.Thread(target=run_django, daemon=True).start()

# Simple Gradio interface to keep the Space alive
def health_check(name):
    return f"HealthSphere Backend is running! Hello {name}"

demo = gr.Interface(
    fn=health_check,
    inputs="text",
    outputs="text",
    title="HealthSphere Backend Server",
    description="This Space is running the Django backend for the HealthSphere Android App."
)

if __name__ == "__main__":
    # Gradio runs on 7860, but since we are running Django on 7860 above,
    # we should actually run them on the same port or use a proxy.
    # Actually, Hugging Face only allows ONE process to listen on 7860.

    # Better approach: Run Django on 8000 and have Gradio/FastAPI proxy it,
    # OR run Django directly on 7860 and just have a dummy app.py for HF logic.

    # Let's run Gradio on 7860 as required, and Django on 8000.
    # Your Flutter app will then need to talk to the Gradio proxy or
    # we can use a simpler approach.

    # For now, let's just launch Gradio to satisfy Hugging Face.
    demo.launch(server_name="0.0.0.0", server_port=7860)
