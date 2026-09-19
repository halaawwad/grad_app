import os
import subprocess
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path


ROOT = Path(__file__).resolve().parent
BACKEND_DIR = ROOT / "backend"
BACKEND_HEALTH_URL = "http://127.0.0.1:4000/api/health"
APP_EXE = ROOT / "build" / "windows" / "x64" / "runner" / "Release" / "rosecare_ai.exe"
BACKEND_LOG = ROOT / "launcher-backend.log"
HEALTH_TIMEOUT_SECONDS = 30


def is_windows():
    return os.name == "nt"


def run_command(command, cwd):
    creationflags = subprocess.CREATE_NO_WINDOW if is_windows() else 0
    return subprocess.Popen(
        command,
        cwd=str(cwd),
        stdout=subprocess.DEVNULL,
        stderr=subprocess.STDOUT,
        creationflags=creationflags,
    )


def start_backend():
    npm_command = "npm.cmd" if is_windows() else "npm"
    log_file = open(BACKEND_LOG, "a", encoding="utf-8")
    creationflags = subprocess.CREATE_NO_WINDOW if is_windows() else 0
    process = subprocess.Popen(
        [npm_command, "run", "start"],
        cwd=str(BACKEND_DIR),
        stdout=log_file,
        stderr=subprocess.STDOUT,
        creationflags=creationflags,
    )
    return process, log_file


def wait_for_backend():
    deadline = time.time() + HEALTH_TIMEOUT_SECONDS
    while time.time() < deadline:
        try:
            with urllib.request.urlopen(BACKEND_HEALTH_URL, timeout=2) as response:
                if response.status == 200:
                    return True
        except (urllib.error.URLError, TimeoutError):
            time.sleep(1)
    return False


def ensure_windows_build():
    if APP_EXE.exists():
        return

    print("Windows app build not found. Building it now...")
    flutter_command = "flutter.bat" if is_windows() else "flutter"
    subprocess.run(
        [
            flutter_command,
            "build",
            "windows",
            "--dart-define=API_BASE_URL=http://localhost:4000/api",
        ],
        cwd=str(ROOT),
        check=True,
    )


def start_app():
    ensure_windows_build()
    return run_command([str(APP_EXE)], ROOT)


def main():
    if not is_windows():
        print("This launcher is currently configured for Windows only.")
        sys.exit(1)

    print("Starting backend...")
    backend_process, backend_log_file = start_backend()

    try:
        if not wait_for_backend():
            print("Backend did not become ready in time.")
            print(f"Check the log file: {BACKEND_LOG}")
            backend_process.terminate()
            sys.exit(1)

        print("Backend is ready.")
        print("Starting app...")
        app_process = start_app()
        print("System is running.")
        print("Close the app window to stop the launcher.")
        app_process.wait()
    finally:
        if backend_process.poll() is None:
            backend_process.terminate()
            try:
                backend_process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                backend_process.kill()
        backend_log_file.close()


if __name__ == "__main__":
    main()
