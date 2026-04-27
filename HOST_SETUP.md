# HOST_SETUP.md — Running the AIR Tool Container

This guide covers how to set up your machine to run the AIR Tool container.
**GPU support is optional.** The container works on any machine with podman installed — it automatically falls back to a smaller model (`qwen2.5:7b`) when no GPU is available.

---

## Prerequisites (all platforms)

You need **podman** (or Docker). That is the only hard requirement for CPU mode.

| Platform | Install |
|----------|---------|
| Linux (RHEL/Fedora) | `sudo dnf install podman` |
| Linux (Ubuntu/Debian) | `sudo apt install podman` |
| macOS | `brew install podman` then `podman machine init && podman machine start` |
| Windows | [Podman Desktop](https://podman-desktop.io/) or enable WSL2 and install podman inside it |

---

## Running the container

### CPU mode (works everywhere, no GPU setup needed)

```bash
podman run \
  -it \
  -v .:/workspace \
  -v ollama_data:/root/.ollama \
  -p 4173:4173 \
  airtool-dev:latest
```

The tool uses `qwen2.5:7b`, which is bundled in the image. No download is needed on first run.

### GPU mode (Linux only, requires setup below)

```bash
podman run \
  --device nvidia.com/gpu=all \
  -it \
  -v .:/workspace \
  -v ollama_data:/root/.ollama \
  -p 4173:4173 \
  airtool-dev:latest
```

The tool uses `qwen2.5:14b`. On the first GPU run it will download the model (~9 GB) into the `ollama_data` volume. Subsequent runs skip the download.

Open your browser to `http://localhost:4173` once the startup messages finish.

---

## GPU setup — Linux

GPU passthrough requires a one-time host setup. An automated script is provided:

```bash
sudo bash scripts/setup-host.sh
```

This installs the NVIDIA driver, CUDA toolkit, and nvidia-container-toolkit, then generates the CDI spec that podman needs for `--device nvidia.com/gpu=all`. It supports RHEL/Fedora and Ubuntu/Debian. **A reboot is required after the script completes.**

### Manual steps (if the script doesn't work for your distro)

#### RHEL / Fedora / CentOS 9

```bash
# 1. Add NVIDIA CUDA repo
sudo dnf config-manager --add-repo \
  https://developer.download.nvidia.com/compute/cuda/repos/rhel9/x86_64/cuda-rhel9.repo

# 2. Install driver and toolkits
sudo dnf module install -y nvidia-driver:latest-dkms
sudo dnf install -y cuda-toolkit nvidia-container-toolkit

# 3. Reboot
sudo reboot

# 4. After reboot: generate CDI spec
sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml

# 5. Verify
nvidia-smi
podman run --rm --device nvidia.com/gpu=all \
  nvcr.io/nvidia/cuda:12.6.0-base-ubi9 nvidia-smi
```

#### Ubuntu 22.04 / 24.04

```bash
# 1. Add NVIDIA CUDA repo
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt update

# 2. Install driver and toolkits
sudo apt install -y nvidia-driver-550 cuda-toolkit nvidia-container-toolkit

# 3. Reboot
sudo reboot

# 4. After reboot: generate CDI spec
sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml

# 5. Verify
nvidia-smi
podman run --rm --device nvidia.com/gpu=all \
  nvcr.io/nvidia/cuda:12.6.0-base-ubi9 nvidia-smi
```

> **Driver version note:** The NVIDIA driver must be version 525 or later to support CUDA 12.x. The `latest-dkms` module on RHEL9 and `nvidia-driver-550` on Ubuntu both satisfy this requirement.

---

## GPU setup — Windows (WSL2)

Windows uses a single NVIDIA driver that covers both the host and WSL2 — you do **not** install a separate Linux driver inside WSL2.

1. Install or update your [NVIDIA Windows driver](https://www.nvidia.com/drivers) to version 525 or later.
2. Enable WSL2 and install Ubuntu: `wsl --install -d Ubuntu`.
3. Inside WSL2, install podman and the container toolkit:
   ```bash
   sudo apt update
   sudo apt install podman nvidia-container-toolkit
   sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml
   ```
4. Run the container from inside WSL2 using the GPU command above.

---

## GPU setup — macOS

macOS does not support NVIDIA GPUs. All Mac hardware (Apple Silicon and Intel) runs in CPU mode automatically. No additional setup is needed beyond installing podman.

---

## Troubleshooting

**`nvidia-smi` not found after install**
The driver was installed but the system has not been rebooted yet. Reboot and try again.

**`podman run --device nvidia.com/gpu=all` fails with "no such device"**
The CDI spec has not been generated, or was generated before the driver was loaded. Run:
```bash
sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml
```

**Container starts but uses CPU mode unexpectedly**
Check that `--device nvidia.com/gpu=all` is present in your podman command. The startup log will print either `NVIDIA GPU detected` or `No GPU detected` to confirm which path was taken.

**First GPU run is slow to start**
The `qwen2.5:14b` model (~9 GB) is being downloaded on first use. Subsequent starts are fast because the model is cached in the `ollama_data` volume.
