#!/bin/bash
set -e

echo "Apptainer Dev Environment Quickstart"
echo "===================================="

source "$(dirname "$0")/scripts/load_config.sh"


# === Step 2: Run make build if needed ===
if [[ ! -f "$CONTAINER_IMAGE" ]]; then
    echo "[2/4] Building Apptainer image..."
    make build
else
    echo "[2/4] Apptainer image already exists"
fi

# === Step 3: Ask user for SLURM resources ===
echo ""
echo "Configure your SLURM session (press Enter to accept default):"

read -p "GPUs [default: 1]: " SLURM_GPUS
SLURM_GPUS="${SLURM_GPUS:-1}"

read -p "CPUs per task [default: 4]: " SLURM_CPUS
SLURM_CPUS="${SLURM_CPUS:-4}"

read -p "Memory [default: 16G]: " SLURM_MEM
SLURM_MEM="${SLURM_MEM:-16G}"

read -p "Time [default: 1:00:00]: " SLURM_TIME
SLURM_TIME="${SLURM_TIME:-1:00:00}"

SESSION_NAME="apptainer-dev"

echo ""
echo "[3/4] Allocating interactive node with tmux session: $SESSION_NAME"
echo "[→] Press Ctrl+B then D to detach from session."

# === Step 3: Launch tmux session on node via srun ===
srun --gres=gpu:$SLURM_GPUS \
     --cpus-per-task=$SLURM_CPUS \
     --mem=$SLURM_MEM \
     --time=$SLURM_TIME \
     --pty bash -c "tmux new-session -s $SESSION_NAME './scripts/start.sh'"

