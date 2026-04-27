#!/usr/bin/env bash
# AIR Tool
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

set -euo pipefail

OLLAMA_MODEL="${OLLAMA_MODEL:-qwen2.5:14b}"
BAKED_MODELS="/root/.ollama-baked"
RUNTIME_MODELS="/root/.ollama"
OLLAMA_READINESS_TIMEOUT=60

echo ""
echo "=== AIR Tool Container Startup ==="
echo ""

# ── Step 1: Seed volume from baked 7b model (first-run only) ─────────────────
# The 7b model is baked into the image at /root/.ollama-baked to avoid the
# volume shadow problem (mounting a volume over /root/.ollama would hide the
# image contents). On first run we copy it into the runtime volume.
MANIFEST_7B="$RUNTIME_MODELS/models/manifests/registry.ollama.ai/library/qwen2.5/7b"
if [ -d "$BAKED_MODELS" ] && [ ! -f "$MANIFEST_7B" ]; then
    echo "[startup] Seeding qwen2.5:7b from image into runtime volume (first run)..."
    mkdir -p "$RUNTIME_MODELS"
    cp -r "$BAKED_MODELS/." "$RUNTIME_MODELS/"
    echo "[startup] qwen2.5:7b seeded."
else
    echo "[startup] qwen2.5:7b already present in volume — skipping seed."
fi

# ── Step 2: Detect GPU, select model ─────────────────────────────────────────
if nvidia-smi > /dev/null 2>&1; then
    echo "[startup] NVIDIA GPU detected. Using model: $OLLAMA_MODEL"
else
    echo "[startup] No GPU detected — falling back to qwen2.5:7b (CPU mode)."
    OLLAMA_MODEL="qwen2.5:7b"
fi

export OLLAMA_MODEL

# ── Step 3: Start ollama serve in the background ─────────────────────────────
echo "[startup] Starting ollama server..."
ollama serve &
OLLAMA_PID=$!

# ── Step 4: Wait for ollama to be ready ──────────────────────────────────────
echo "[startup] Waiting for ollama to be ready (timeout: ${OLLAMA_READINESS_TIMEOUT}s)..."
ELAPSED=0
until curl -sf http://localhost:11434 > /dev/null 2>&1; do
    if [ "$ELAPSED" -ge "$OLLAMA_READINESS_TIMEOUT" ]; then
        echo "[startup] ERROR: ollama did not become ready within ${OLLAMA_READINESS_TIMEOUT}s. Exiting."
        kill "$OLLAMA_PID" 2>/dev/null || true
        exit 1
    fi
    sleep 1
    ELAPSED=$((ELAPSED + 1))
done
echo "[startup] Ollama is ready."

# ── Step 5: Ensure the selected model is present ─────────────────────────────
# For 7b: already seeded from the image — ollama pull is a no-op.
# For 14b: pulled here on first GPU run (~9 GB); subsequent runs are no-ops.
echo "[startup] Ensuring model '$OLLAMA_MODEL' is available..."
ollama pull "$OLLAMA_MODEL"
echo "[startup] Model '$OLLAMA_MODEL' ready."

# ── Step 6: Start Quarto ─────────────────────────────────────────────────────
IP=$(ip route get 1 | awk '{print $7}')

echo ""
echo "*******************************************************"
echo "*            You can find the AIR Tool at:            *"
echo "*       http://$IP:4173/ OR localhost:4173  *"
echo "*******************************************************"
echo ""

exec quarto preview /workspace/airtool.qmd --server --quiet --port 4173 --host "$IP"
