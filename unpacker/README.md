# Container Image Unpacker

**Unpack** a Docker or OCI container image tarball into a regular filesystem
layout,  with clean layer merging, whiteout handling, safe extraction, and
detailed logging.

This tool extracts all filesystem layers from an image tarball into a
directory, preserving file structure, symbolic links, and hardlinks, and
correctly applying whiteouts.

---

## ✨ Features

- Extracts multi-layer Docker/OCI image tarballs, works with Docker and/or Podman
- Applies whiteouts and opaque directory rules
- Safe filesystem handling (no path traversal risks)
- Skips device files
- Produces verbose, compressed log file of extraction
- CLI summary
- **No external Python dependencies** (uses standard library only, Python 3.6+)

---

## 📦 How to use

Ensure you have a local image tarball.  

**Example using Docker:**

```bash
# Pull the image of interest
docker pull daveman1010220/airtool-dev:latest

# Save it to a local tar file
docker save airtool-dev -o airtool.tar
```

**Note:** If you do not have access to a container runtime or container runtime tools such as docker or podman, you can also use Skopeo to pull the container you want to unpack.

**Example using Skopeo:**

```bash
skopeo login docker.io

# <enter your credentials to complete the login>

skopeo copy --override-os linux docker://docker.io/daveman1010220/airtool-dev:latest docker-archive:airtool.tar
```

Now that you have the image, you can set permissions on the unpack.py script and run it:

```bash
# Make the unpack script executable
chmod +x unpack.py

# Unpack the image tarball into a new directory
sudo python3 unpack.py airtool.tar airtool-rootfs/
```
**Note:** At this time, it is necessary to run the script with root permissions. This is due to the need to create symbolic links which are invalid, as they will point to invalid files unless accessed in a sandbox'd environment like unshare or chroot. (Invalid symlinks cause an exception in python. Providing the necessary privileges allows the links to be created anyway.)

- ✅ The extracted filesystem will appear under airtool-rootfs/.
- ✅ A full (compressed) log of the operation will be saved as airtool.unpack.<date_time>.log.gz.

**Example output:**

```bash
📦 Extracting image airtool.tar to airtool-rootfs/
📝 Full log: airtool.unpack.20240428_104521.log

🔵 Layer: airtool/layer.tar
🧹 Opaque whiteout on root/tmp
🗑️  Whiteout delete root/etc/motd

🗜️ Compressing log file...
📦 Log compressed: airtool.unpack.20240428_104521.log.gz

✅ Extraction complete!
```

If any errors are detected, the last 20 lines of the log will be displayed for quick troubleshooting.

## 🛠 Requirements
- Python 3.6 or newer
- No additional libraries needed (standard library only)

## 📋 Notes
- The output directory must not already exist; the script will refuse to overwrite existing directories to prevent data loss.
- The logfile is compressed to .gz format automatically to save space.
- Supports extraction of container tarballs exported with docker save, podman save, or other OCI-compliant tools.

## 🚪 After Extraction: Chroot and Explore/Run the tool

Once the filesystem is unpacked, you can chroot into it and explore it like a real minimal system.

    Warning: Only chroot into trusted images. Malicious filesystems can escape
    chroot under certain conditions. That's why we have containers in the first
    place. ;-)

**Quick steps:**

```bash

# Enter the extracted filesystem
sudo mkdir -p airtool-rootfs/dev airtool-rootfs/proc airtool-rootfs/sys

sudo mount -o bind /dev/ airtool-rootfs/dev
sudo mount -o bind /proc/ airtool-rootfs/proc
sudo mount -o bind /sys/ airtool-rootfs/sys

sudo cp chroot-env.fish airtool-rootfs/workspace

sudo chroot airtool-rootfs/ /bin/bash

cd workspace

/bin/fish

source chroot-env.fish

scripts/run_quarto.sh
```

## 🛡️ Safer Way: Isolated Namespaces

If you want extra safety and have the necessary tools and permissions, you can use Linux namespaces to isolate the session. This is very close to how containers actually work under-the-hood:

```bash
sudo mkdir -p airtool-rootfs/dev airtool-rootfs/proc airtool-rootfs/sys

# These three may be unnecessary when using unshare, as it sets much of this up for you.
sudo mount -o bind /dev/ airtool-rootfs/dev
sudo mount -o bind /proc/ airtool-rootfs/proc
sudo mount -o bind /sys/ airtool-rootfs/sys

sudo unshare --mount \
             --uts \
             --ipc \
             --net \
             --pid \
             --fork \
             --user \
             --map-root-user \
             chroot airtool-rootfs/ /bin/sh

cd workspace

/bin/fish

source chroot-env.fish

scripts/run_quarto.sh
```

This gives you a running environment for the tool that is no longer in a container.
