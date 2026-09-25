#!/usr/bin/env python3
"""Run the Connect IQ simulator on an isolated virtual KDE display."""

import argparse
import json
import os
from pathlib import Path
import shutil
import signal
import socket
import subprocess
import sys
import time


ROOT = Path(__file__).resolve().parents[1]
WORK = ROOT / "build" / "simulator-bg"
STATE = WORK / "state.json"
RUNTIME = Path(os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}"))


def process_start(pid):
    try:
        return Path(f"/proc/{pid}/stat").read_text().split()[21]
    except (OSError, IndexError):
        return None


def alive(pid, started):
    return process_start(pid) == started


def load_state():
    if not STATE.is_file():
        return None
    return json.loads(STATE.read_text())


def send_group(pid, started, action):
    if alive(pid, started) and os.getpgid(pid) == pid:
        os.killpg(pid, action)


def stop(state):
    for key in ("simulator", "compositor"):
        send_group(state[f"{key}_pid"], state[f"{key}_start"], signal.SIGINT)
    for _ in range(30):
        if not any(alive(state[f"{key}_pid"], state[f"{key}_start"])
                   for key in ("simulator", "compositor")):
            break
        time.sleep(0.1)
    for key in ("simulator", "compositor"):
        send_group(state[f"{key}_pid"], state[f"{key}_start"], signal.SIGTERM)


def tcp_ready():
    try:
        with socket.create_connection(("127.0.0.1", 1234), timeout=0.25):
            return True
    except OSError:
        return False


def start():
    old = load_state()
    if old and alive(old["simulator_pid"], old["simulator_start"]):
        print(f"Already running on DISPLAY={old['display']}")
        return
    if old:
        stop(old)
        STATE.unlink()
    if tcp_ready():
        raise RuntimeError("Simulator port 1234 is in use; close the other instance first.")

    for program in ("dbus-run-session", "kwin_wayland", "xdpyinfo"):
        if not shutil.which(program):
            raise RuntimeError(f"Required local program is missing: {program}")
    sdk_config = Path.home() / ".Garmin/ConnectIQ/current-sdk.cfg"
    sdk = Path(sdk_config.read_text().strip())
    launcher = sdk / "bin/connectiq"
    if not launcher.is_file():
        raise RuntimeError(f"Connect IQ simulator not found: {launcher}")

    WORK.mkdir(parents=True, exist_ok=True)
    prior_displays = {path.name for path in Path("/tmp/.X11-unix").glob("X*")}
    wayland_socket = f"padel-ciq-bg-{os.getpid()}"
    env = os.environ.copy()
    env.pop("DISPLAY", None)
    env.pop("WAYLAND_DISPLAY", None)
    # The simulator uses libpulse. An unreachable server makes its audio silent
    # without muting browsers or changing the system output device.
    env["PULSE_SERVER"] = f"unix:{RUNTIME}/{wayland_socket}-no-audio"
    compositor_log = (WORK / "compositor.log").open("w")
    compositor = subprocess.Popen(
        ["dbus-run-session", "--", "kwin_wayland", "--virtual", "--xwayland",
         f"--socket={wayland_socket}", "--width", "1024", "--height", "768"],
        env=env, stdin=subprocess.DEVNULL, stdout=compositor_log,
        stderr=subprocess.STDOUT, start_new_session=True,
    )
    try:
        display = None
        for _ in range(150):
            if compositor.poll() is not None:
                raise RuntimeError(f"Virtual display exited; see {WORK / 'compositor.log'}")
            new_displays = sorted(
                (path.name for path in Path("/tmp/.X11-unix").glob("X*")
                 if path.name not in prior_displays),
                key=lambda name: int(name[1:]),
            )
            for name in new_displays:
                candidate = ":" + name[1:]
                check = subprocess.run(
                    ["xdpyinfo", "-display", candidate], env=env,
                    stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                    timeout=2,
                )
                if check.returncode == 0:
                    display = candidate
                    break
            if display:
                break
            time.sleep(0.1)
        if not display:
            raise RuntimeError(f"Virtual X display did not start; see {WORK / 'compositor.log'}")

        env["DISPLAY"] = display
        env["WAYLAND_DISPLAY"] = wayland_socket
        simulator_log = (WORK / "simulator.log").open("w")
        simulator = subprocess.Popen(
            [str(launcher)], env=env, stdin=subprocess.DEVNULL,
            stdout=simulator_log, stderr=subprocess.STDOUT,
            start_new_session=True,
        )
        for _ in range(150):
            if simulator.poll() is not None:
                raise RuntimeError(f"Simulator exited; see {WORK / 'simulator.log'}")
            if tcp_ready():
                break
            time.sleep(0.1)
        else:
            raise RuntimeError(f"Simulator did not become ready; see {WORK / 'simulator.log'}")

        state = {
            "display": display, "wayland_socket": wayland_socket,
            "compositor_pid": compositor.pid,
            "compositor_start": process_start(compositor.pid),
            "simulator_pid": simulator.pid,
            "simulator_start": process_start(simulator.pid),
        }
        STATE.write_text(json.dumps(state, indent=2) + "\n")
        print(f"Connect IQ simulator ready in the background (DISPLAY={display}).")
        print(f"Logs: {WORK}")
    except Exception:
        if "simulator" in locals() and simulator.poll() is None:
            os.killpg(simulator.pid, signal.SIGTERM)
        if compositor.poll() is None:
            os.killpg(compositor.pid, signal.SIGTERM)
        raise


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=("start", "status", "stop"))
    args = parser.parse_args()
    if args.action == "start":
        start()
        return
    state = load_state()
    running = bool(state and alive(state["simulator_pid"], state["simulator_start"]))
    if args.action == "status":
        print(f"Running on DISPLAY={state['display']}" if running else "Stopped")
    elif state:
        stop(state)
        STATE.unlink()
        print("Stopped background Connect IQ simulator.")
    else:
        print("Already stopped.")


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, subprocess.SubprocessError, RuntimeError) as error:
        print(f"Error: {error}", file=sys.stderr)
        sys.exit(1)
