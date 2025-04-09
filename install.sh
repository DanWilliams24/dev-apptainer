#!/bin/bash
set -e

CONFIG_PATH="$(dirname "$0")/config.env"

echo "Apptainer Dev Environment Installer"
echo "==================================="

# === [1/4] Ask if using /n/fs and gather project path ===
read -p "[1/4] Are you using /n/fs project space? [Y/n]: " use_nfs
use_nfs="${use_nfs,,}"  # to lowercase

if [[ -z "$use_nfs" || "$use_nfs" == "y" || "$use_nfs" == "yes" ]]; then
    read -p "      Enter your project space name (e.g., my-project-space): " proj_space
    if [[ -z "$proj_space" ]]; then
        echo "      ✘ Project space name is required when using /n/fs"
        exit 1
    fi
    PROJECT_ROOT="/n/fs/$proj_space"
else
    read -p "      Enter absolute path to your desired project root: " PROJECT_ROOT
    if [[ -z "$PROJECT_ROOT" ]]; then
        echo "      ✘ No path provided. Aborting."
        exit 1
    fi
fi

# === [2/4] Detect Apptainer launcher folder ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAUNCHER_NAME="$(basename "$SCRIPT_DIR")"

# === [3/4] Confirm or create root directory ===
if [[ ! -d "$PROJECT_ROOT" ]]; then
    read -p "[3/4] Directory does not exist. Create it? [y/N]: " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        mkdir -p "$PROJECT_ROOT"
        echo "      ✔ Created directory: $PROJECT_ROOT"
    else
        echo "      ✘ Aborting installation."
        exit 1
    fi
else
    echo "[3/4] Using existing directory: $PROJECT_ROOT"
fi

# === [4/4] Generate config.env ===
echo "      ✔ Writing configuration to: $CONFIG_PATH"
cat > "$CONFIG_PATH" <<EOF
# config.env (auto-generated)

PROJECT_ROOT="$PROJECT_ROOT"
LAUNCHER_NAME="$LAUNCHER_NAME"

CONTAINER_IMAGE="\${PROJECT_ROOT}/\${LAUNCHER_NAME}/minimal-python.sif"
VENV_PATH="\${PROJECT_ROOT}/\${LAUNCHER_NAME}/venv"
CODESERVER_DIR="\${PROJECT_ROOT}/\${LAUNCHER_NAME}/code-server"
WORKSPACE_HOST="\${PROJECT_ROOT}"
LAUNCHER_PATH="\${PROJECT_ROOT}/\${LAUNCHER_NAME}/scripts/start.sh"

BIND_SSH=true
BIND_GIT=true
EOF

# Wait until the config file exists and is non-empty
while [[ ! -s "$CONFIG_PATH" ]]; do
    sleep 0.1
done

# === Final Step: Build image if needed ===
if [[ ! -f "${PROJECT_ROOT}/${LAUNCHER_NAME}/minimal-python.sif" ]]; then
    echo "[✔] No Apptainer image found. Running: make build"
    make build
else
    echo "[✔] Apptainer image already exists: ${PROJECT_ROOT}/${LAUNCHER_NAME}/minimal-python.sif"
fi

echo
echo "Install complete:"
echo "  - Launcher folder: $LAUNCHER_NAME"
echo "  - Project root:    $PROJECT_ROOT"
echo "  - Config saved to: $CONFIG_PATH"
