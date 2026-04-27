#!/usr/bin/env bash
# AIR Tool — Host GPU Setup Script (Linux)
#
# Copyright 2024 Carnegie Mellon University.
#
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE
# MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO
# WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER
# INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR
# MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL.
# CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT
# TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
#
# Licensed under a MIT (SEI)-style license, please see license.txt or contact
# permission_at_sei.cmu.edu for full terms.
#
# [DISTRIBUTION STATEMENT A] This material has been approved for public release
# and unlimited distribution.  Please see Copyright notice for non-US Government
# use and distribution.
#
# This Software includes and/or makes use of Third-Party Software each subject to
# its own license.
#
# DM24-1686
#
# ─────────────────────────────────────────────────────────────────────────────
# Installs the NVIDIA driver, CUDA toolkit, and nvidia-container-toolkit on
# Linux hosts so that podman can pass a GPU into the airtool container.
#
# Supports:
#   - RHEL / Fedora / CentOS Stream 9
#   - Ubuntu 22.04 / 24.04 and Debian-based distros
#
# Usage:
#   sudo bash scripts/setup-host.sh
#
# A reboot is required after installation. The script will prompt before
# rebooting so you can save any open work.
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

# ── Preflight ─────────────────────────────────────────────────────────────────
if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: This script must be run as root (use sudo)."
    exit 1
fi

# Detect NVIDIA GPU
if ! lspci | grep -qi nvidia; then
    echo "WARNING: No NVIDIA GPU detected via lspci."
    echo "         Continuing anyway — the GPU may not be visible at this stage."
fi

# Detect distro family
if [ -f /etc/os-release ]; then
    # shellcheck source=/dev/null
    . /etc/os-release
    DISTRO_ID="${ID:-unknown}"
    DISTRO_LIKE="${ID_LIKE:-}"
else
    echo "ERROR: Cannot detect OS. /etc/os-release not found."
    exit 1
fi

is_rhel_family() {
    case "$DISTRO_ID" in
        rhel|fedora|centos|rocky|almalinux) return 0 ;;
    esac
    case "$DISTRO_LIKE" in
        *rhel*|*fedora*|*centos*) return 0 ;;
    esac
    return 1
}

is_debian_family() {
    case "$DISTRO_ID" in
        ubuntu|debian|linuxmint|pop) return 0 ;;
    esac
    case "$DISTRO_LIKE" in
        *debian*|*ubuntu*) return 0 ;;
    esac
    return 1
}

# ── RHEL / Fedora / CentOS ────────────────────────────────────────────────────
setup_rhel() {
    echo "==> Detected RHEL/Fedora family: $DISTRO_ID"

    # Determine RHEL major version for repo URL
    RHEL_MAJOR="${VERSION_ID%%.*}"
    CUDA_REPO_URL="https://developer.download.nvidia.com/compute/cuda/repos/rhel${RHEL_MAJOR}/x86_64/cuda-rhel${RHEL_MAJOR}.repo"

    echo "==> Adding NVIDIA CUDA repository..."
    dnf config-manager --add-repo "$CUDA_REPO_URL"

    echo "==> Installing NVIDIA driver (DKMS) and CUDA toolkit..."
    dnf module install -y nvidia-driver:latest-dkms
    dnf install -y cuda-toolkit

    echo "==> Installing NVIDIA Container Toolkit..."
    dnf install -y nvidia-container-toolkit
}

# ── Ubuntu / Debian ───────────────────────────────────────────────────────────
setup_debian() {
    echo "==> Detected Debian/Ubuntu family: $DISTRO_ID ${VERSION_ID:-}"

    # Determine Ubuntu codename or fallback
    UBUNTU_VERSION="${VERSION_ID:-22.04}"
    UBUNTU_MAJOR="${UBUNTU_VERSION%%.*}"

    # Select the appropriate CUDA keyring package
    if [ "$UBUNTU_MAJOR" -ge 24 ]; then
        CUDA_KEYRING_URL="https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb"
    else
        CUDA_KEYRING_URL="https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb"
    fi

    echo "==> Adding NVIDIA CUDA repository..."
    TMP_DEB=$(mktemp --suffix=.deb)
    curl -fsSL "$CUDA_KEYRING_URL" -o "$TMP_DEB"
    dpkg -i "$TMP_DEB"
    rm -f "$TMP_DEB"
    apt-get update -q

    echo "==> Installing NVIDIA driver and CUDA toolkit..."
    apt-get install -y nvidia-driver-550 cuda-toolkit

    echo "==> Installing NVIDIA Container Toolkit..."
    apt-get install -y nvidia-container-toolkit
}

# ── Run distro-specific setup ─────────────────────────────────────────────────
if is_rhel_family; then
    setup_rhel
elif is_debian_family; then
    setup_debian
else
    echo "ERROR: Unsupported distro '$DISTRO_ID'."
    echo "       Please follow the manual instructions in HOST_SETUP.md."
    exit 1
fi

# ── Generate CDI spec for podman ─────────────────────────────────────────────
echo ""
echo "==> Generating CDI spec for podman GPU passthrough..."
echo "    (This step runs after the driver is installed but before reboot."
echo "     If it fails, re-run 'sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml'"
echo "     after rebooting.)"
mkdir -p /etc/cdi
nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml 2>/dev/null \
    && echo "    CDI spec written to /etc/cdi/nvidia.yaml" \
    || echo "    WARNING: CDI generation failed — re-run after reboot."

# ── Done — prompt for reboot ──────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║  Installation complete. A reboot is required to load the driver. ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "After rebooting, verify GPU passthrough with:"
echo "  nvidia-smi"
echo "  nvidia-ctk cdi list"
echo "  podman run --rm --device nvidia.com/gpu=all \\"
echo "    nvcr.io/nvidia/cuda:12.6.0-base-ubi9 nvidia-smi"
echo ""
read -r -p "Reboot now? [y/N] " REPLY
if [[ "${REPLY,,}" == "y" ]]; then
    echo "Rebooting..."
    reboot
else
    echo "Reboot skipped. Remember to reboot before running the container with GPU support."
fi
