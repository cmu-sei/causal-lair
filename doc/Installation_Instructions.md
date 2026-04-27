# AIR Tool Installation Instructions

## Overview

The AIR Tool runs as a self-contained container. Once you have podman (or Docker) installed, a single command downloads and starts everything — the tool, the AI interpretation engine, and all dependencies.

- **CPU mode** works on any machine and requires no additional setup beyond podman.
- **GPU mode** (Linux only) enables the larger `qwen2.5:14b` model for faster, higher-quality AI interpretations. It requires a one-time host setup described below.

---

## Step 1: Install Podman

| Platform | Instructions |
|----------|-------------|
| **Linux (RHEL/Fedora)** | `sudo dnf install podman` |
| **Linux (Ubuntu/Debian)** | `sudo apt install podman` |
| **macOS** | `brew install podman` then `podman machine init && podman machine start` |
| **Windows** | Install [Podman Desktop](https://podman-desktop.io/) or enable WSL2 and install podman inside Ubuntu |

Docker works as a drop-in replacement — substitute `docker` for `podman` in all commands below.

---

## Step 2: (Optional) Enable GPU Support — Linux only

Skip this step if you do not have an NVIDIA GPU or do not need GPU acceleration. The tool falls back to CPU mode automatically.

An automated setup script is provided for RHEL/Fedora and Ubuntu/Debian:

```bash
sudo bash scripts/setup-host.sh
```

This installs the NVIDIA driver, CUDA toolkit, and nvidia-container-toolkit, generates the CDI spec for podman, and prompts you to reboot. **A reboot is required after running the script.**

For manual instructions or other Linux distributions, see [HOST_SETUP.md](../HOST_SETUP.md).

---

## Step 3: Run the Container

Navigate to the directory where you cloned this repository, then run:

**CPU mode (all platforms):**
```bash
podman run \
  -it \
  -v .:/workspace \
  -v ollama_data:/root/.ollama \
  -p 4173:4173 \
  ghcr.io/cmu-sei/airtool-dev:latest
```

**GPU mode (Linux, after Step 2):**
```bash
podman run \
  --device nvidia.com/gpu=all \
  -it \
  -v .:/workspace \
  -v ollama_data:/root/.ollama \
  -p 4173:4173 \
  ghcr.io/cmu-sei/airtool-dev:latest
```

You will see startup messages as the container initializes ollama and selects the AI model. The tool is ready when you see:

```
*******************************************************
*            You can find the AIR Tool at:            *
*       http://<ip>:4173/ OR localhost:4173  *
*******************************************************
```

---

## Step 4: Open the AIR Tool in Your Browser

Navigate to `http://localhost:4173` in Chrome, Edge, Firefox, or Safari.

> **Linux:** You may also use the IP address printed in the startup message (e.g., `http://172.17.0.2:4173/`).  
> **Windows (WSL2):** Use `localhost:4173`.  
> **macOS:** Use `localhost:4173`.

The page may take up to 30 seconds to load on first access.

---

## Notes

**AI model on first run:**
- CPU mode: the `qwen2.5:7b` model is bundled in the image — no download needed.
- GPU mode: the `qwen2.5:14b` model (~9 GB) is downloaded on the first GPU run and cached in the `ollama_data` volume. Subsequent runs start immediately.

**Stopping the container:**
Press `Ctrl+C` in the terminal where the container is running.

**Keeping the container:**
Remove `--rm` from the run command if you want the container to persist after stopping. Use `podman start <name>` to restart it.

**Updating to a new version:**
Pull the new image and re-run:
```bash
podman pull ghcr.io/cmu-sei/airtool-dev:latest
```
The `ollama_data` volume is preserved between image updates — the AI model does not need to be re-downloaded.

For additional instructions on using the AIR Tool, see the [Getting Started Guide](./getting_started.md).
