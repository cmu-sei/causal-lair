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
  description = "creates a dev container for AIR, with R and other tools";

  nixConfig = {
    substituters = [
        "https://cache.nixos.org"
        "https://airtool-dev.cachix.org"
    ];
    trusted-public-keys = [ 
        "airtool-dev.cachix.org-1:dfX1T1ibTyc1dIOSWtxQxbpPJUya00RVFu9gLtiWvn8="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  inputs = {
    flake-utils.url = "github:numtide/flake-utils"; # Utility functions for Nix flakes

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # Main Nix package repository

    tetrad.url = "github:daveman1010221/tetrad";

    # Rust packages source
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    # Neovim with customizations
    myNeovimOverlay = {
      url = "github:daveman1010221/nix-neovim";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.url = "github:NixOS/nixpkgs/eb9ceca17df2ea50a250b6b27f7bf6ab0186f198";
    };

  };

  outputs = { flake-utils, nixpkgs, rust-overlay, myNeovimOverlay, tetrad, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            rust-overlay.overlays.default
            myNeovimOverlay.overlays.default
          ];
        };

        identify = let
          identifySrc = ./identify;
          cargoToml = builtins.fromTOML (builtins.readFile "${identifySrc}/Cargo.toml");
          binaryName = cargoToml.package.name;
        in
        pkgs.rustPlatform.buildRustPackage {
          pname = binaryName;
          version = cargoToml.package.version;
          src = identifySrc;
          cargoLock.lockFile = "${identifySrc}/Cargo.lock";
          doCheck = false;
        
          installPhase = ''
            mkdir -p $out/bin
            cp target/${pkgs.stdenv.hostPlatform.config}/release/${binaryName} $out/bin/
          '';
        };

        score = let
          scoreSrc = ./score;
          cargoToml = builtins.fromTOML (builtins.readFile "${scoreSrc}/Cargo.toml");
        in
        pkgs.rustPlatform.buildRustPackage {
          pname = cargoToml.package.name;
          version = cargoToml.package.version;
          src = scoreSrc;

          cargoLock.lockFile = "${scoreSrc}/Cargo.lock";
          doCheck = false;

          nativeBuildInputs = [
            pkgs.pkg-config
            pkgs.openssl
            pkgs.openblasCompat
            pkgs.liblapack
            pkgs.gfortran13
            pkgs.gfortran13.cc.lib
          ];
        
          buildInputs = [
            pkgs.pkg-config
            pkgs.openssl
            pkgs.openblasCompat
            pkgs.liblapack
            pkgs.gfortran13
            pkgs.gfortran13.cc.lib
          ];
        
          env = {
            OPENBLAS_DIR = "${pkgs.openblasCompat}";
            OPENBLAS_INCLUDE_DIR = "${pkgs.openblasCompat}/include";
            OPENBLAS_LIB_DIR = "${pkgs.openblasCompat}/lib";
            OPENSSL_DIR = "${pkgs.openssl.out}";
            OPENSSL_INCLUDE_DIR = "${pkgs.openssl.dev}/include";
            OPENSSL_LIB_DIR = "${pkgs.openssl.out}/lib";
            PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
            LD_LIBRARY_PATH = "${pkgs.gfortran13.cc.lib}/lib:$LD_LIBRARY_PATH";
          };
        };

        # We create an account for the container user. These are necessary user files.
        baseInfo = pkgs.buildEnv {
          name  = "base-info";
          paths = with pkgs; [
            # Set up shadow file with user information
            (writeTextDir "etc/shadow" ''
              root:!x:::::::
            '')
            # Set up passwd file with user information
            (writeTextDir "etc/passwd" ''
              root:x:0:0::/root:${runtimeShell}
            '')
            # Set up group file with user information
            (writeTextDir "etc/group" ''
              root:x:0:
            '')
            # Set up gshadow file with user information
            (writeTextDir "etc/gshadow" ''
              root:x::
            '')
            # Set up os-release file with NixOS information
            (writeTextDir "etc/os-release" ''
              NAME="NixOS"
              ID=nixos
              VERSION="unstable"
              VERSION_CODENAME=unstable
              PRETTY_NAME="NixOS (unstable)"
              HOME_URL="https://nixos.org/"
              SUPPORT_URL="https://nixos.org/nixos/manual/"
              BUG_REPORT_URL="https://github.com/NixOS/nixpkgs/issues"
            '')

            # stock fonts.conf copied verbatim so it’s writable
            (pkgs.writeTextDir "etc/fonts/fonts.conf"
              (builtins.readFile "${pkgs.fontconfig.out}/etc/fonts/fonts.conf"))

            # /etc/fonts/local.conf
            (pkgs.writeTextDir "etc/fonts/local.conf" ''
              <?xml version="1.0"?>
              <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
              <fontconfig>
                <dir>${dejavuDir}</dir>
              </fontconfig>
            '')

            # /etc/fonts/conf.d/50-dejavu-extra.conf
            (pkgs.writeTextDir "etc/fonts/conf.d/50-dejavu-extra.conf" ''
              <?xml version="1.0"?>
              <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
              <fontconfig>
                <!-- extra faces for R -->
                <dir>${dejavuDir}</dir>
              </fontconfig>
            '')
          ];
        };

        sl3 = pkgs.rPackages.buildRPackage {
          name = "sl3";
          src = pkgs.fetchFromGitHub{
            owner = "tlverse";
            repo = "sl3";
            rev = "0e8f2365bcbe54010b8120c04a7a2dcfc8119227"; # <-- 'devel' branch
            sha256 = "0m1cg7icdza230l2jlpkwf9s8b4pwbyn0xj5vrk6yq6lfq8dgvpr";
          };
          propagatedBuildInputs = with pkgs.rPackages; [
            Rdpack
            data_table
            assertthat
            origami
            R6
            uuid
            BBmisc
            delayed
            ggplot2
            digest
            dplyr
            caret
            ROCR
          ];
        };

        rWithPkgs = pkgs.rWrapper.override {
          packages = [
            pkgs.rPackages.logger
            pkgs.rPackages.udunits2      # libudunits2-dev
            pkgs.rPackages.AIPW
            pkgs.rPackages.devtools
            pkgs.rPackages.DiagrammeR
            pkgs.rPackages.DiagrammeRsvg
            pkgs.rPackages.doParallel
            pkgs.rPackages.e1071
            pkgs.rPackages.earth
            pkgs.rPackages.gifski
            pkgs.rPackages.hash
            pkgs.rPackages.here
            pkgs.rPackages.igraph
            pkgs.rPackages.knitr
            pkgs.rPackages.lintr
            pkgs.rPackages.nnet
            pkgs.rPackages.randomForest
            pkgs.rPackages.ranger
            pkgs.rPackages.Rdpack
            pkgs.rPackages.readr
            pkgs.rPackages.rJava
            pkgs.rPackages.rmarkdown
            pkgs.rPackages.rsconnect
            pkgs.rPackages.rsvg
            pkgs.rPackages.sets
            pkgs.rPackages.shiny
            pkgs.rPackages.shinyWidgets
            pkgs.rPackages.tidyr
            pkgs.rPackages.xgboost
            pkgs.rPackages.quarto

            # These are SL3's dependencies
            pkgs.rPackages.BBmisc
            pkgs.rPackages.caret
            pkgs.rPackages.dplyr
            pkgs.rPackages.R6
            pkgs.rPackages.ROCR

            # These are TMLE3's dependencies
            pkgs.rPackages.foreach
            pkgs.rPackages.magrittr
            pkgs.rPackages.mvtnorm
            pkgs.rPackages.R6

            # These are HAL9001's dependencies
            pkgs.rPackages.Rcpp
            pkgs.rPackages.Matrix
            pkgs.rPackages.glmnet
            pkgs.rPackages.RcppEigen

            # These are common to TMLE3 and HAL9001
            pkgs.rPackages.stringr

            # These are common to SL3 and HAL9001
            pkgs.rPackages.origami

            # These are common to SL3, TMLE3, and HAL9001
            pkgs.rPackages.assertthat
            pkgs.rPackages.data_table
            pkgs.rPackages.delayed
            pkgs.rPackages.digest
            pkgs.rPackages.ggplot2
            pkgs.rPackages.uuid

            (pkgs.rPackages.buildRPackage {
              name = "tmle3";
              src = pkgs.fetchFromGitHub{
                owner = "tlverse";
                repo = "tmle3";
                rev = "ed72f8a20e64c914ab25ffe015d865f7a9963d27"; # <-- 'devel' branch
                sha256 = "159vhzpcw1rldicql8w4ykmc87y0rj970cnn8apcyk9cwd08bk1r";
              };
              propagatedBuildInputs = [
                sl3
                pkgs.rPackages.delayed
                pkgs.rPackages.data_table
                pkgs.rPackages.assertthat
                pkgs.rPackages.R6
                pkgs.rPackages.uuid
                pkgs.rPackages.ggplot2
                pkgs.rPackages.foreach
                pkgs.rPackages.mvtnorm
                pkgs.rPackages.magrittr
                pkgs.rPackages.stringr
                pkgs.rPackages.digest
              ];
            })

            (pkgs.rPackages.buildRPackage {
              name = "hal9001";
              src = pkgs.fetchFromGitHub{
                owner = "tlverse";
                repo = "hal9001";
                rev = "00fe70f32bcf32e006ad415fe5b1bd8947be8b6f"; # <-- 'devel' branch
                sha256 = "18wa8zk88fx1w5y814wby4an6jq1bj8ffkqnqsc9ykk37fagnnyw";
              };
              propagatedBuildInputs = [
                pkgs.rPackages.Rcpp
                pkgs.rPackages.Matrix
                pkgs.rPackages.assertthat
                pkgs.rPackages.origami
                pkgs.rPackages.glmnet
                pkgs.rPackages.data_table
                pkgs.rPackages.stringr
                pkgs.rPackages.RcppEigen
              ];
            })
          ];
        };

        quartoPatched = pkgs.quarto.overrideAttrs (old: {
          buildInputs = (old.buildInputs or []) ++ [ rWithPkgs ];

          postFixup = ''
            echo "[quarto patch] Replacing upstream QUARTO_R in-place..."

            # Remove any existing QUARTO_R export (important!)
            sed -i '/^export QUARTO_R=/d' $out/bin/quarto

            # Insert our QUARTO_R export *before* the exec line so it's actually used
            sed -i 's|^exec .*|export QUARTO_R="${rWithPkgs}/bin/R"\n&|' $out/bin/quarto

            echo "[quarto patch] Final result:"
            grep QUARTO_R $out/bin/quarto || true
          '';
        });

        quartoEnv = pkgs.buildEnv {
          name = "quarto-env";
          paths = [
            rWithPkgs
            quartoPatched
            identify
          ];
        };

        # Writable /etc/fonts tree
        dejavuDir   = "${pkgs.dejavu_fonts}/share/fonts/truetype";

        myEnv = pkgs.buildEnv {
          name = "my-env";
          paths = with pkgs; [

            gfortran13
            gnupg
            ffmpeg                  # libavfilter-dev
            graphviz
            curlFull                # libcurl4-openssl-dev
            fontconfig              # libfontconfig1-dev
            dejavu_fonts
            freetype                # libfreetype6-dev
            fribidi                 # libfribidi-dev
            giflib                  # libgif-dev
            libgit2                 # libgit2-dev
            harfbuzz                # libharfbuzz-dev
            libjpeg                 # libjpeg-dev
            #lapack                  # liblapack-dev    <- seems to be provided by openblas
            libmysqlclient          # libmariadb-dev
                                    # libmariadb-dev-compat
            openblasCompat                # libopenblas-dev
            libpng                  # libpng-dev
            poppler                 # libpoppler-cpp-dev
            librsvg                 # librsvg2-dev
            libsodium               # libsodium-dev
            openssl                 # libssl-dev
            libtiff                 # libtiff5-dev
            libwebp                 # libwebp-dev
            libxml2                 # libxml2-dev

            lsb-release
            iproute2
            pkg-config
            libiconv

	        pkgs.texlive.combined.scheme-full  # Full TeX distribution added here
	        pkgs.texlivePackages.framed
	        pkgs.texlivePackages.collection-latexextra


            # software-properties-common <- apt-specific, has no corollary in nix?

            wget
            zlib                    # zlib1g-dev

            jdk23
            maven
            pandoc
            libtirpc


            # -- Basic Required Files --
            bash # Basic bash. For real, this is the worst bash experience you'll ever have.

            # Some of these are essential packages, but most of these are here
            # to make a developer's life better. Remove them if you don't like
            # cool stuff.
            cacert
            cmake
            eza
            fd
            figlet
            findutils
            fzf
            gawk
            (lib.meta.hiPrio gcc)
            getent
            git
            glibc
            glibcLocalesUtf8
            gnugrep
            gnumake
            gnused
            gnutar
            grc
            gzip
            jq
            libclang
            lsof
            ncurses
            nix
            openssl
            pkg-config
            pkgs.stdenv.cc.cc.lib
            libiconv
            ps
            ripgrep
            strace
            tree
            tree-sitter
            uutils-coreutils-noprefix # Essential utilities
            which

            # We make the default terminal-based editor in the dev container
            # Neovim. If you want something sad like nano, you can remove all
            # vim references.
            nvim-pkg

            # Fish shell. Remove these and the overlay if you want a sad shell
            # experience.
            fish
            fishPlugins.bass
            fishPlugins.bobthefish
            fishPlugins.foreign-env
            fishPlugins.grc

            # -- Rust Toolchain --
            rust-analyzer
            (rust-bin.selectLatestNightlyWith (toolchain: toolchain.default.override {
              extensions = [ "rust-src" ];

              # I think the default architecture for rust is whatever
              # architecture you happen to be working on. If we need to support
              # other architectures, this is where you do it.
              # targets = [ "wasm32-unknown-unknown" ];
            }))

            quartoEnv
            tetrad.packages.${system}.default
            score
          ];
          pathsToLink = [
            "/bin"
            "/lib"
            "/inc"
            "/etc/ssl/certs"
          ];
        };

        fishConfig = pkgs.writeTextFile {
          name = "container-files/config.fish";
          destination = "/root/.config/fish/config.fish";
          text = builtins.readFile ./container-files/config.fish;
        };

        fishPluginsFile = pkgs.writeTextFile {
          name = "container-files/plugins.fish";
          destination = "/.plugins.fish";
          text = builtins.readFile ./container-files/plugins.fish;
        };

        license = pkgs.writeTextFile {
          name = "container-files/license.txt";
          destination = "/root/license.txt";
          text = builtins.readFile ./container-files/license.txt;
        };

        # User creation script
        createUserScript = pkgs.writeTextFile {
          name = "container-files/create-user.sh";
          destination = "/create-user.sh";
          text = builtins.readFile ./container-files/create-user.sh;
          executable = true;
        };
 
        # Materialize the flake directory
        workspacePath = pkgs.runCommand "materialized-flake" {} ''
          mkdir -p $out/workspace
          cp -r ${./.}/* $out/workspace
        '';

        # Dynamically resolve the full JAR path
        jarPath = pkgs.runCommand "tetrad-jar-path" { } ''
          jar=$(cd ${tetrad.packages.${system}.default}/share/java && echo tetrad-gui-*-launch.jar)
          echo -n ${tetrad.packages.${system}.default}/share/java/$jar > $out
        '';

        TETRAD_PATH = builtins.readFile jarPath;

      in
      {
        packages.default = pkgs.dockerTools.buildImage {
          name = "airtool-dev";
          tag = "latest";
          copyToRoot = [
            myEnv
            baseInfo
            fishConfig
            license
            createUserScript
            fishPluginsFile
            workspacePath
          ];
          config = {
            WorkingDir = "/workspace";
            Env = [
              # Certificates and environment setup
              "SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
              "SSL_CERT_DIR=/etc/ssl/certs"

              "LANG=en_US.UTF-8"
              "TZ=UTC"

              "CARGO_HTTP_CAINFO=/etc/ssl/certs/ca-bundle.crt"
              "CC=gcc"
              "CXX=g++"
              "LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib"
              "PKG_CONFIG_PATH=${pkgs.openssl}/lib/pkgconfig"
              "USER=root"
              "COREUTILS=${pkgs.uutils-coreutils-noprefix}"
              "CMAKE=/bin/cmake"
              "CMAKE_MAKE_PROGRAM=/bin/make"
              "LIBCLANG_PATH=${pkgs.libclang.lib}/lib/"
              "SHELL=/bin/fish"
              "JAVA_HOME=${pkgs.jdk23}"
              "PATH=${myEnv}/bin:/bin:/usr/bin:/root/.cargo/bin:$JAVA_HOME/bin"
              "QUARTO_R=${rWithPkgs}/bin/R"
              "LOCALE_ARCHIVE=${pkgs.glibcLocalesUtf8}/lib/locale/locale-archive"

              # Fish plugins environment variables
              "FISH_GRC=${pkgs.fishPlugins.grc}"
              "FISH_BASS=${pkgs.fishPlugins.bass}"
              "BOB_THE_FISH=${pkgs.fishPlugins.bobthefish}"
              "_JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=lcd -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel'"
              "DISPLAY=:1"
              "TETRAD_PATH=${TETRAD_PATH}"
            ];
            Volumes = { };
            Cmd = [ "/bin/fish" ]; # Default command
            ExposedPorts = {
                "4173/tcp" = {};
            };
            # Cmd = [ "sh" "/app/scripts/run_quarto.sh" ];
          };
          extraCommands = ''
            # Link the env binary (needed for the check requirements script)
            mkdir -p usr/bin/
            ln -n bin/env usr/bin/env

            # Link the dynamic linker/loader
            mkdir -p lib64
            ln -s ${pkgs.glibc}/lib/ld-linux-x86-64.so.2 lib64/ld-linux-x86-64.so.2

            # Create /tmp dir
            mkdir -p tmp

            ln -s ${myEnv}/bin/javadoc usr/bin/javadoc
          '';
        };
        devShells.default = pkgs.mkShell {
          name = "airtool-dev";
        
          packages = [
            myEnv
            pkgs.openssl
            pkgs.pkg-config
          ];
        
          # Set up required env vars for openssl-sys and friends
          shellHook = ''
            export OPENSSL_INCLUDE_DIR="${pkgs.openssl.dev}/include"
            export OPENSSL_LIB_DIR="${pkgs.openssl.out}/lib"
            export PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig"
            export LIBCLANG_PATH="${pkgs.libclang.lib}/lib/"
            export SSL_CERT_FILE="/etc/ssl/certs/ca-bundle.crt"
            export LOCALE_ARCHIVE="${pkgs.glibcLocalesUtf8}/lib/locale/locale-archive"
            export JAVA_HOME="${pkgs.jdk23}"
            export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.liblapack}/lib:${pkgs.openblasCompat}/lib:$LD_LIBRARY_PATH"
            export PATH="$JAVA_HOME/bin:$PATH"
          '';
        };
      }
    );
}
