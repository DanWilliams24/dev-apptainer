#!/bin/bash
set -e
echo "[Debug] Running on $(hostname)"
source "$(dirname "$0")/load_config.sh"

export APPTAINER_CACHEDIR="$PROJECT_ROOT/.apptainer-cache"
export APPTAINER_TMPDIR="$PROJECT_ROOT/tmp"

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
