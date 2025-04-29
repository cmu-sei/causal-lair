#!/usr/bin/env python3

import argparse
import datetime
import gzip
import json
import os
import shutil
import sys
import tarfile

# Color codes for fancy terminal output
RED = '\033[31m'
GREEN = '\033[32m'
YELLOW = '\033[33m'
BLUE = '\033[34m'
RESET = '\033[0m'

# Track whether any errors occurred during run
errors_occurred = False

def log(message):
    """Log full details to the logfile."""
    with open(logfile_path, 'a') as f:
        f.write(message + '\n')

def console(message, color=RESET):
    """Print simple summary to the console."""
    print(f"{color}{message}{RESET}")

def safe_extract_tar(tarobj, target_path):
    global errors_occurred
    """Safely extract one layer tar into target_path, with whiteout and safety handling."""
    for member in tarobj:
        log(f"Extracting: {member.name}")

        # Skip device files
        if member.isdev():
            log(f"  [skip device] {member.name}")
            continue

        dest = os.path.join(target_path, member.name)

        # Protect against path traversal attacks
        if not os.path.abspath(dest).startswith(os.path.abspath(target_path)):
            log(f"  [SECURITY WARNING] skipping path outside root: {member.name}")
            console(f"⚠️  Skipping suspicious path {member.name}", YELLOW)
            continue

        base_name = os.path.basename(member.name)
        dir_name = os.path.dirname(dest)

        # Handle whiteout files
        if base_name.startswith('.wh.'):
            target_name = base_name[4:]
            if target_name == '.wh..opq':
                # Opaque directory: clear existing contents
                log(f"  [whiteout opaque dir] {dir_name}")
                console(f"🧹 Opaque whiteout on {dir_name}", BLUE)
                if os.path.exists(dir_name):
                    for root, dirs, files in os.walk(dir_name, topdown=False):
                        for name in files:
                            os.unlink(os.path.join(root, name))
                        for name in dirs:
                            os.rmdir(os.path.join(root, name))
            else:
                # Normal whiteout: delete a file or directory
                target_path_to_remove = os.path.join(dir_name, target_name)
                if os.path.exists(target_path_to_remove):
                    log(f"  [whiteout remove] {target_path_to_remove}")
                    console(f"🗑️  Whiteout delete {target_path_to_remove}", BLUE)
                    if os.path.isdir(target_path_to_remove):
                        os.rmdir(target_path_to_remove)
                    else:
                        os.unlink(target_path_to_remove)
            continue  # Skip extraction of the .wh.* entry itself

        # Normal file or directory extraction
        dest_dir = os.path.dirname(dest)
        os.makedirs(dest_dir, exist_ok=True)

        if member.isdir():
            if not os.path.exists(dest):
                log(f"  [mkdir] {member.name}")
                os.makedirs(dest, exist_ok=True)
            os.chmod(dest, member.mode)
            os.chown(dest, os.getuid(), os.getgid())  # <-- Set owner to current user
        elif member.isreg():
            try:
                with tarobj.extractfile(member) as source, open(dest, "wb") as out:
                    out.write(source.read())
                os.chmod(dest, member.mode)
                os.chown(dest, os.getuid(), os.getgid())  # <-- Set owner to current user
                log(f"  [extract file] {member.name}")
            except Exception as e:
                global errors_occurred
                errors_occurred = True
                log(f"  [error] extracting file {member.name}: {e}")
                console(f"❌ Failed extracting {member.name}", RED)
        elif member.issym():
            link_target = member.linkname

            try:
                # Always remove the destination if it already exists
                if os.path.lexists(dest):
                    os.unlink(dest)

                # Now create the symlink exactly as stored
                os.symlink(link_target, dest)

            except Exception as e:
                errors_occurred = True
                log(f"  [error] creating symlink {member.name} -> {link_target}: {e}")
                console(f"❌ Failed symlink {member.name} -> {link_target}", RED)

            else:
                log(f"  [symlink] {member.name} -> {link_target}")
        elif member.islnk():
            try:
                os.link(os.path.join(target_path, member.linkname), dest)
                log(f"  [hardlink] {member.name} -> {member.linkname}")
            except FileNotFoundError:
                errors_occurred = True
                log(f"  [warning] skipping hardlink (target missing): {member.linkname}")
                console(f"⚠️  Hardlink target missing: {member.linkname}", YELLOW)

def main():
    global errors_occurred
    global logfile_path

    parser = argparse.ArgumentParser(
        description="Extract a Docker/OCI image tarball to a filesystem directory."
    )
    parser.add_argument(
        "image_tar",
        type=str,
        help="Path to the container image tar file (e.g., airtool.tar)"
    )
    parser.add_argument(
        "output_dir",
        type=str,
        help="Path to directory where filesystem will be extracted"
    )

    args = parser.parse_args()

    image_tar_path = args.image_tar
    output_dir = args.output_dir

    if os.path.exists(output_dir):
        console(f"❌ Output directory '{output_dir}' already exists. Aborting to prevent overwrite.", RED)
        sys.exit(1)

    # Prepare logfile
    now = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    image_basename = os.path.basename(image_tar_path).rsplit('.', 1)[0]
    logfile_path = f"{image_basename}.unpack.{now}.log"

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    console(f"📦 Extracting image {image_tar_path} to {output_dir}", BLUE)
    console(f"📝 Full log: {logfile_path}", BLUE)

    try:
        with tarfile.open(image_tar_path) as image_tar:
            try:
                manifest_data = image_tar.extractfile('manifest.json')
                manifest = json.loads(manifest_data.read())
            except KeyError:
                errors_occurred = True
                console("❌ manifest.json not found in archive.", RED)
                sys.exit(1)
            except json.JSONDecodeError:
                errors_occurred = True
                console("❌ manifest.json is not valid JSON.", RED)
                sys.exit(1)

            for layer_path in manifest[0]['Layers']:
                console(f"\n🔵 Layer: {layer_path}", BLUE)
                log(f"\n=== Processing Layer: {layer_path} ===\n")
                try:
                    with tarfile.open(fileobj=image_tar.extractfile(layer_path)) as layer_tar:
                        safe_extract_tar(layer_tar, output_dir)
                except KeyError:
                    errors_occurred = True
                    console(f"❌ Layer {layer_path} not found in archive.", RED)
                    sys.exit(1)

    except (tarfile.TarError, FileNotFoundError) as e:
        errors_occurred = True
        console(f"❌ Unable to open image tarball: {e}", RED)
        sys.exit(1)

    # Gzip the log file
    console("\n🗜️ Compressing log file...", BLUE)
    with open(logfile_path, 'rb') as f_in:
        with gzip.open(logfile_path + '.gz', 'wb') as f_out:
            shutil.copyfileobj(f_in, f_out)
    os.remove(logfile_path)  # Remove the uncompressed log
    logfile_path += '.gz'
    console(f"📦 Log compressed: {logfile_path}", BLUE)
    
    # If errors occurred, tail last 20 lines of the log
    if errors_occurred:
        console("\n⚠️  Errors detected during extraction. Last 20 lines of log:", YELLOW)
        try:
            with gzip.open(logfile_path, 'rt') as f:
                lines = f.readlines()
                for line in lines[-20:]:
                    print(line.strip())
        except Exception as e:
            console(f"⚠️  Failed to tail log: {e}", RED)

    console("\n✅ Extraction complete!", GREEN)

if __name__ == "__main__":
    main()
