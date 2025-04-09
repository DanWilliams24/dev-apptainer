#!/bin/bash
set -e

echo "[Entrypoint] Starting container session..."

if [[ -f /venv/bin/python ]] && /venv/bin/python -c "import sys; print(sys.executable)" | grep -q "^/venv"; then
    echo "[Entrypoint] Valid venv found at /venv"
else
    echo "[Entrypoint] Creating fresh venv at /venv"
    find /venv -mindepth 1 -delete  # Safely clean out existing contents
    python3 -m venv /venv
fi

# Activate
source /venv/bin/activate

# Install JAX if missing
if ! python -c "import jax" >/dev/null 2>&1; then
    echo "[Entrypoint] Installing JAX with CUDA support..."
    python -m pip install --upgrade pip
    python -m pip install "jax[cuda12]"
else
    echo "[Entrypoint] JAX already installed"
fi

# Confirm
echo "[Entrypoint] JAX version: $(python -c 'import jax; print(jax.__version__)')"
echo "[Entrypoint] Devices: $(python -c 'import jax; print(jax.devices())')"

# ANSI colors
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
WHITE="\033[1;37m"
RESET="\033[0m"

echo ""
echo -e "${WHITE}┌──────────────────────────────────────────────────────────────┐${RESET}"
echo -e "${WHITE}│${CYAN}  You are now inside a dedicated tmux session: apptainer-dev  ${WHITE}│${RESET}"
echo -e "${WHITE}├──────────────────────────────────────────────────────────────┤${RESET}"
echo -e "${WHITE}│${YELLOW}  • To detach from this session:   Ctrl + B, then D           ${WHITE}│${RESET}"
echo -e "${WHITE}│${YELLOW}  • To reattach later:             tmux attach -t apptainer-dev ${WHITE}│${RESET}"
echo -e "${WHITE}├──────────────────────────────────────────────────────────────┤${RESET}"
echo -e "${WHITE}│${CYAN}  This session will persist even if your terminal closes.     ${WHITE}│${RESET}"
echo -e "${WHITE}└──────────────────────────────────────────────────────────────┘${RESET}"

# Start code tunnel (requires Microsoft/GitHub login first time)
echo "[Entrypoint] Launching code tunnel..."
exec code tunnel --accept-server-license-terms
