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

{
  description = "Nix flake for building the Rust binary for AIR step two";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Parse Cargo.toml
        cargoToml = builtins.fromTOML (builtins.readFile ./Cargo.toml);

        # Extract the project name
        binaryName = cargoToml.package.name;
      in {
        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname = binaryName;
          version = cargoToml.package.version;
          src = ./.;

          # Use dependencies from nixpkgs
          cargoLock.lockFile = ./Cargo.lock;

          # Disable tests for release builds
          doCheck = false;

          installPhase = ''
            mkdir -p $out/bin

            # TODO: This is aggravating. Nix can target multiple architectures
            # and cargo will build for many of them. However, there is no good
            # way to just ASK it for the target architecture string, such as
            # x86_64-unknown-linux-gnu. The most terse way I can figure out how
            # to get this is simply to hard-code for the architecture you're
            # building on...
            cp target/x86_64-unknown-linux-gnu/release/${binaryName} $out/bin/
          '';
        };
      }
    );
}
