#!/bin/bash
set -e

# Detect the absolute path of the config file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_PATH="${SCRIPT_DIR}/../config.env"

if [[ -f "$CONFIG_PATH" ]]; then
    source "$CONFIG_PATH"
else
    echo "[load_config] Error: config.env not found at $CONFIG_PATH"
    exit 1
fi

# Path to Apptainer container image
CONTAINER_IMAGE="${PROJECT_ROOT}/${LAUNCHER_NAME}/minimal-python.sif"

# Python virtual environment location (bind mount)
VENV_PATH="${PROJECT_ROOT}/${LAUNCHER_NAME}/venv"

# code-server installation directory (bind mount)
CODESERVER_DIR="${PROJECT_ROOT}/${LAUNCHER_NAME}/code-server"

# Project space to mount into /workspace inside container
WORKSPACE_HOST="${PROJECT_ROOT}"

# Launcher script that runs the container
LAUNCHER_PATH="${PROJECT_ROOT}/${LAUNCHER_NAME}/scripts/start.sh"



# Export for use in Makefile if requested
if [[ "$1" == "--print" ]]; then
  echo "CONTAINER_IMAGE=$CONTAINER_IMAGE"
  echo "VENV_PATH=$VENV_PATH"
  echo "CODESERVER_DIR=$CODESERVER_DIR"
  echo "WORKSPACE_HOST=$WORKSPACE_HOST"
  echo "LAUNCHER_PATH=$LAUNCHER_PATH"
  echo "PROJECT_ROOT=$PROJECT_ROOT"
  echo "BIND_SSH=$BIND_SSH"
  echo "BIND_GIT=$BIND_GIT"
  exit 0
fi

