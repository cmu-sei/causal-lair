# Ollama Integration Plan: Single-Container Architecture

## Current Architecture

The current setup requires two containers orchestrated via `compose.yaml`:

1. **`ollama` container** — runs `docker.io/ollama/ollama`, listens on port `11434`, persists model data in the `ollama_data` named volume.
2. **`airtool` container** — runs the Nix-built image, serves the Quarto app on port `4173`, and reaches ollama via the Docker network hostname `http://ollama:11434` (set by the `OLLAMA_BASE_URL` environment variable).

The airtool communicates with ollama through two R functions in `airtool.qmd`:
- `ollama_ensure_model()` — checks if the model exists and pulls it if not.
- `ollama_chat()` — POSTs to ollama's `/api/chat` endpoint using system `curl`.

The container entrypoint is `scripts/run_quarto.sh`, which starts `quarto preview` on port `4173`.

---

## Goal

Fold ollama into the Nix flake so it runs inside the same container as the airtool, eliminating the need for `compose.yaml`. The tool must:

- Work fully air-gapped (no cloud LLM API)
- Include `qwen2.5:7b` baked into the container image so it is available immediately without a network pull
- Use `qwen2.5:14b` on GPU when available (pulled on first GPU run, then cached)
- Fall back to `qwen2.5:7b` automatically when no GPU is present
- Be deployable by arbitrary analysts on Windows, Mac, and Linux with minimal host setup

---

## Deployment Strategy: GPU-Optional with Baked CPU Fallback

| Scenario | Model used | Model source | Network required? |
|----------|-----------|--------------|-------------------|
| GPU available | `qwen2.5:14b` | Pulled to named volume on first GPU run | Yes (first GPU run only) |
| No GPU / CPU fallback | `qwen2.5:7b` | Baked into image, copied to volume on first run | No |

`pkgs.ollama-cuda` auto-detects CUDA at runtime and uses CPU if CUDA is absent. The model selection is handled by the startup script.

---

## Key Design Decision: Model Storage and the Volume Shadow Problem

Baking a model into the image at `/root/.ollama/` and then mounting a volume at `/root/.ollama/` at runtime causes the volume to shadow (hide) the baked files entirely — the image copy becomes inaccessible.

**Solution: bake to a separate path, copy into the volume on first run.**

- During Nix build: `qwen2.5:7b` model files are placed at `/root/.ollama-baked/` inside the image.
- At container startup: the startup script checks whether the model already exists in the mounted volume (`/root/.ollama/`). If not, it copies from `/root/.ollama-baked/` into `/root/.ollama/`. This copy is fast (local filesystem, no network) and only happens once.
- Subsequently: both models live in `/root/.ollama/` (the named volume), which persists across container restarts. Ollama uses this path by default.

This means:
- **CPU-only machines** never need network access after the image is loaded — 7b is always present.
- **GPU machines** pull 14b to the volume once on first GPU-enabled run.

---

## Phase 0: Host Prerequisites

### What every deployer needs (all platforms)

Just **podman** (or Docker). That is sufficient for CPU mode with the baked 7b model.

GPU mode requires additional one-time host setup on Linux.

### Platform-specific host setup

A `HOST_SETUP.md` file will cover all platforms. A `scripts/setup-host.sh` script will automate the Linux path.

#### Linux — RHEL/Fedora/CentOS (GPU)

```bash
sudo dnf config-manager --add-repo \
  https://developer.download.nvidia.com/compute/cuda/repos/rhel9/x86_64/cuda-rhel9.repo
sudo dnf module install nvidia-driver:latest-dkms
sudo dnf install cuda-toolkit nvidia-container-toolkit
sudo reboot
sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml
# Verify:
podman run --rm --device nvidia.com/gpu=all \
  nvcr.io/nvidia/cuda:12.6.0-base-ubi9 nvidia-smi
```

#### Linux — Ubuntu/Debian (GPU)

```bash
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb && sudo apt update
sudo apt install nvidia-driver-550 nvidia-container-toolkit
sudo reboot
sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml
```

#### Windows (WSL2 + GPU)

Install the standard NVIDIA Windows driver (≥ 525). WSL2 inherits CUDA from the Windows driver — no separate Linux driver is installed inside WSL2. Inside WSL2, install podman and nvidia-container-toolkit, then generate the CDI spec as on Linux.

#### macOS

Apple Silicon and Intel Macs have no NVIDIA GPU support. macOS always runs in CPU mode. No GPU setup steps needed.

```bash
brew install podman
podman machine init && podman machine start
```

---

## Phase 1: Flake Changes

### 1. Add `pkgs.ollama-cuda` to `myEnv`

Add `pkgs.ollama-cuda` to the `paths` list in `myEnv`. This provides the `ollama` binary with bundled CUDA runtime libraries. It auto-detects whether CUDA is available at startup and uses CPU if not.

### 2. Add a model-baking derivation for `qwen2.5:7b`

Add a derivation in `flake.nix` that runs `ollama pull qwen2.5:7b` during the Nix build and captures the resulting model directory:

```nix
qwen7bModel = pkgs.runCommand "qwen2.5-7b-model" {
  __noChroot = true;   # required: allows network access during build
  nativeBuildInputs = [ pkgs.ollama-cuda pkgs.cacert ];
} ''
  export HOME=$TMPDIR
  export OLLAMA_MODELS=$out
  export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
  mkdir -p $out

  ollama serve &
  OLLAMA_PID=$!

  # Wait for server
  for i in $(seq 1 30); do
    curl -sf http://localhost:11434 && break
    sleep 2
  done

  OLLAMA_MODELS=$out ollama pull qwen2.5:7b
  kill $OLLAMA_PID || true
'';
```

**Important:** `__noChroot = true` disables the Nix sandbox for this derivation, which means:
- Network access is allowed during `nix build` (required to download the model)
- The derivation is **not hermetic** — if the `qwen2.5:7b` tag changes upstream, the output changes
- Every clean build re-downloads the model unless the Nix store output is cached

This is an acceptable trade-off: `nix build` requires internet, but the resulting image is self-contained and can be loaded onto air-gapped machines.

### 3. Include baked model in `copyToRoot` at a separate path

Add `qwen7bModel` to `copyToRoot` in `pkgs.dockerTools.buildImage`, placing it at `/root/.ollama-baked/` inside the image. This path is intentionally separate from `/root/.ollama/` so it is not shadowed by the runtime volume mount.

```nix
copyToRoot = [
  myEnv
  baseInfo
  fishConfig
  license
  createUserScript
  fishPluginsFile
  workspacePath
  (pkgs.buildEnv {
    name = "ollama-baked";
    paths = [ qwen7bModel ];
    postBuild = ''
      mkdir -p $out/root/.ollama-baked
      cp -r ${qwen7bModel}/. $out/root/.ollama-baked/
    '';
  })
];
```

### 4. Add env vars to `config.Env`

```nix
"NVIDIA_VISIBLE_DEVICES=all"
"NVIDIA_DRIVER_CAPABILITIES=compute,utility"
"OLLAMA_BASE_URL=http://localhost:11434"
"OLLAMA_MODEL=qwen2.5:14b"   # startup script may override this to qwen2.5:7b
```

`OLLAMA_MODEL` makes the model name configurable at runtime without rebuilding the image.

### 5. Expose port `11434` in `config.ExposedPorts`

Add `"11434/tcp" = {}` alongside the existing `"4173/tcp" = {}`.

### 6. Update `Cmd`

```nix
Cmd = [ "/bin/bash" "/workspace/scripts/start.sh" ];
```

---

## Phase 2: New Startup Script (`scripts/start.sh`)

Replaces `scripts/run_quarto.sh` as the container entrypoint.

```
1. Seed the volume from the baked model (first-run only):
   If /root/.ollama/models/manifests/.../qwen2.5/7b does not exist:
     cp -r /root/.ollama-baked/. /root/.ollama/

2. Detect GPU:
   If `nvidia-smi` succeeds silently:
     Use OLLAMA_MODEL (default: qwen2.5:14b)
   Else:
     Override OLLAMA_MODEL=qwen2.5:7b
     Log: "No GPU detected — falling back to qwen2.5:7b (CPU mode)"

3. Start `ollama serve &` in background

4. Wait for ollama to be ready:
   Poll http://localhost:11434 every 1s, timeout after 60s

5. Pull $OLLAMA_MODEL if not already in /root/.ollama:
   - qwen2.5:7b: already present from step 1, pull is a no-op
   - qwen2.5:14b: pulled here on first GPU run (~9 GB); subsequent runs are no-ops

6. exec quarto preview (same command as run_quarto.sh)
   exec replaces the shell so quarto is the direct foreground process
```

---

## Phase 3: Application Changes (`airtool.qmd`)

### Changes needed (two small string updates)

**Model name** — `ollama_ensure_model()` and `ollama_chat()` hardcode `"qwen2.5:14b"`. Change to:
```r
model = Sys.getenv("OLLAMA_MODEL", "qwen2.5:14b")
```

**Base URL fallback** — both functions use `Sys.getenv("OLLAMA_BASE_URL", "http://ollama:11434")`. Update fallback to `"http://localhost:11434"`.

### Already implemented — no changes needed

The following behaviors are already in place and will be preserved unchanged:

**Boilerplate/template fallback** (`get_fallback_interpretation()`, line ~2619)
The original template-based "mad libs" interpretation already exists as a named function and is already wired into two places:
- `get_ui_interpretation()` (~line 2603): if the LLM pipeline returns `NULL` or throws, it falls back to the template output with a user-facing note explaining the LLM is unavailable.
- `output$ui_interpretation` renderUI (~line 5578): same fallback if `ai_insights_buffer()` is empty.

No changes to this logic are needed. The template interpretation will continue to display whenever ollama is unreachable, the model fails to load, or any other LLM-side error occurs.

**Max-rounds disclaimer** (`run_ai_insights()`, lines 2557–2567)
`max_rounds = 3` is already the default. When the reviewer loop exhausts all rounds without an `APPROVED` response, the function already appends a disclaimer to the latest draft and returns it — it does not return `NULL` or suppress the output. This behavior is preserved as-is.

---

## Summary of All File Changes

| File | Change |
|------|--------|
| `flake.nix` | `pkgs.ollama-cuda` in `myEnv`; `qwen7bModel` baking derivation; update `copyToRoot`; add env vars; expose port `11434`; update `Cmd` |
| `scripts/start.sh` | New: seeds volume from baked model, GPU detection, model selection, ollama startup, readiness poll, model pull, quarto exec |
| `scripts/setup-host.sh` | New: automated RHEL/Ubuntu host setup for GPU passthrough |
| `HOST_SETUP.md` | New: user-facing setup guide for Windows, Mac, Linux (CPU and GPU paths) |
| `airtool.qmd` | Update default model and base URL fallbacks in `ollama_ensure_model()` and `ollama_chat()` |
| `compose.yaml` → `compose.yaml.bak` | Renamed — kept for reference, no longer active |

---

## Runtime Invocation

**With GPU (Linux, after host setup):**
```bash
podman run \
  --device nvidia.com/gpu=all \
  -it \
  -v .:/workspace \
  -v ollama_data:/root/.ollama \
  -p 4173:4173 \
  airtool-dev:latest
```

**Without GPU (any platform — CPU fallback, no network needed after image load):**
```bash
podman run \
  -it \
  -v .:/workspace \
  -v ollama_data:/root/.ollama \
  -p 4173:4173 \
  airtool-dev:latest
```

The startup script detects the absence of GPU and uses `qwen2.5:7b` automatically. The 7b model is seeded from the image into the volume on first run — no download required.

---

## Build-time vs Runtime Network Requirements

| Operation | Network needed? | When |
|-----------|----------------|------|
| `nix build` | Yes — downloads `qwen2.5:7b` | Once, by whoever builds the image |
| First CPU run | No | Model is in the image |
| First GPU run | Yes — downloads `qwen2.5:14b` (~9 GB) | Once per volume |
| Subsequent runs (any) | No | Both models cached in volume |
