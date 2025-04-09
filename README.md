# Apptainer Development Environment

Lightweight GPU-ready Apptainer setup with JAX, Python, and VS Code CLI support. It enables persistent Python virtual environments and integrates smoothly with SLURM-based cluster environments using shared filesystems like `/n/fs`.

---

## 📦 Overview

This project is designed to help you launch an interactive development container (with GPU support) directly on SLURM nodes, while maintaining a persistent Python environment and developer configuration.

---

## 📁 Project Structure

| File / Folder                     | Description                                                            |
|----------------------------------|------------------------------------------------------------------------|
| `install.sh`                     | Interactive setup script. Prompts for paths, writes `config.env`, and builds container if needed. |
| `config.env`                     | Auto-generated configuration file for all other scripts.              |
| `container.def`                  | Apptainer definition file (base image: CUDA 12 + Ubuntu 22.04).       |
| `scripts/start.sh`              | Starts the container using Apptainer and the generated config.        |
| `quickstart.sh`                  | Automates SLURM node allocation + launches the container.             |
| `Makefile`                       | Provides CLI for building, cleaning, purging, etc.                    |
| `load_config.sh`                 | Utility to consistently load `config.env` for scripts and Makefiles.  |

---

## 🧠 Files Dependent on `config.env`

These scripts source or include `config.env` and require it to be correctly generated:

- `install.sh`
- `scripts/start.sh`
- `quickstart.sh`
- `Makefile`
- `load_config.sh`

---

## 🚀 Quick Start

### 1. Clone and install

```bash
git clone <your-repo-url> my-container
cd my-container
bash install.sh
```

- Prompts for either `/n/fs` project space or a custom absolute path.
- Generates `config.env` automatically.
- Builds container image if not already built.

---

### 2. Launch manually

Once you've allocated a SLURM node:

```bash
bash scripts/start.sh
```

---

### 3. Launch with auto SLURM allocation

```bash
bash quickstart.sh
```

- Prompts for GPU, CPU, memory, and runtime options
- Allocates a SLURM node using `salloc`
- Starts the container when ready

---

## 🧹 Cleanup Commands

```bash
make clean       # Removes local Python and code-server cache
make uninstall   # Removes virtualenv, code-server, and config files
make purge       # Like uninstall, plus wipes ~/.bash_profile backups
make distclean   # Full wipe, including the Apptainer container image
```

---

## ⚙️ Build Container Manually

```bash
make build
```

This uses `container.def` to build the `.sif` image via:

```bash
apptainer build <output-image> container.def
```

---

## 🛠 Configuration Options (in `config.env`)

| Variable         | Description                                     |
|------------------|-------------------------------------------------|
| `PROJECT_ROOT`   | Root path where user files and container live   |
| `LAUNCHER_NAME`  | Name of the directory (auto-detected)           |
| `CONTAINER_IMAGE`| Full path to `.sif` file                        |
| `VENV_PATH`      | Where Python venv will persist                  |
| `CODESERVER_DIR` | Optional path for storing VS Code server        |
| `BIND_SSH`       | If true, binds host’s `.ssh` into the container |
| `BIND_GIT`       | If true, binds host’s `.gitconfig` into the container |

---

## 📎 Notes

- No root or fakeroot is required to run this setup.
- VS Code CLI (for tunneling) is built into the container and can be used if needed.
- You can mount `.ssh` and `.gitconfig` by toggling `BIND_SSH` and `BIND_GIT` in `config.env`.

---

## ✅ Example SLURM Run (Quickstart)

```bash
bash quickstart.sh
```

```text
[1/4] Detected container: container/
[2/4] Project root set to: /n/fs/my-project-space
[3/4] Launching node with: --gres=gpu:1 --cpus-per-task=4 --mem=16G --time=1:00:00
[4/4] Apptainer container started inside nodeNNN
```

---
