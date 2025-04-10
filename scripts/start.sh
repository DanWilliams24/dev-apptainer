#!/bin/bash
set -e
echo "[Debug] Running on $(hostname)"
SOURCE_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo "[Debug] Script located in $SOURCE_DIR"
source "$SOURCE_DIR/load_config.sh"

echo "[Debug] PROJECT_ROOT=$PROJECT_ROOT"
echo "[Debug] VENV_PATH=$VENV_PATH"

echo "Start point: - exports"
export APPTAINER_CACHEDIR="$PROJECT_ROOT/.apptainer-cache"
export APPTAINER_TMPDIR="$PROJECT_ROOT/tmp"
echo "Fixed point - exports"
# Create the bind mount target if it doesn't exist (do NOT populate it)
if [[ ! -e "$VENV_PATH" ]]; then
    echo "[Host] Creating empty mount point for venv at $VENV_PATH"
    mkdir -p "$VENV_PATH"
fi

EXTRA_BINDS=""
[[ "$BIND_SSH" == "true" ]] && EXTRA_BINDS+=" --bind $HOME/.ssh:/workspace/.ssh"
[[ "$BIND_GIT" == "true" ]] && EXTRA_BINDS+=" --bind $HOME/.gitconfig:/workspace/.gitconfig"

apptainer run --nv \
    --bind "$PROJECT_ROOT":/workspace \
    --bind "$VENV_PATH":/venv \
    $EXTRA_BINDS \
    --home /workspace \
    --pwd /workspace \
    "$CONTAINER_IMAGE"
