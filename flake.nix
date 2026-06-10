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
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

  };

  outputs = { flake-utils, nixpkgs, rust-overlay, myNeovimOverlay, tetrad, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (final: prev: {
              nodejs = prev.nodejs_22;
              gjs = prev.gjs.overrideAttrs (_: { doCheck = false; });
              sdl3 = prev.sdl3.overrideAttrs (old: { 
                doCheck = false;
                cmakeFlags = (old.cmakeFlags or []) ++ [ "-DSDL_TESTS=OFF" ];
                outputs = builtins.filter (o: o != "installedTests") old.outputs;
              });
              sdl2-compat = prev.sdl2-compat.overrideAttrs (old: { 
                doCheck = false;
                cmakeFlags = (old.cmakeFlags or []) ++ [ "-DSDL_TESTS=OFF" ];
                outputs = builtins.filter (o: o != "installedTests") old.outputs;
              });
            })
            rust-overlay.overlays.default
            myNeovimOverlay.overlays.default
          ];
          config = {
            doCheckByDefault = false;
          };
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

        pandoc-3_8_3 =
          let
            hpkgs = pkgs.haskell.packages.ghc967.override {
              overrides = hself: hsuper: {
                pandoc = pkgs.haskell.lib.dontCheck (hself.callHackageDirect {
                  pkg = "pandoc";
                  ver = "3.8.3";
                  sha256 = "sha256-tv6Ufj1cwFnwqXqVwaDC/8lxolwABdb7RCR8zKyUaZk=";
                } {});
                citeproc = hself.callHackageDirect {
                  pkg = "citeproc";
                  ver = "0.12";
                  sha256 = "sha256-yNDqJpXJeGpEXun46nFkhGeXBx3FVxqWT+y8+YjsoF4=";
                } {};
                texmath = hself.callHackageDirect {
                  pkg = "texmath";
                  ver = "0.13.0.2";
                  sha256 = "sha256-ecrQEgHZfYLojvoWOcwIgloRwh4m4+w0PN9LnU99Cgk=";
                } {};
                typst = hself.callHackageDirect {
                  pkg = "typst";
                  ver = "0.8.1";
                  sha256 = "sha256-KKtIUx1hXFaIu1DI3jolpL+eb62V/fK/mOGQv6+9nGs=";
                } {};
                typst-symbols = hself.callHackageDirect {
                  pkg = "typst-symbols";
                  ver = "0.1.9.1";
                  sha256 = "sha256-Gx1LV9dO68SuiwrxYx0ChnlbiBVPe3uFhzNKawIIXYE=";
                } {};
                pandoc-lua-engine = pkgs.haskell.lib.dontCheck (hself.callHackageDirect {
                  pkg = "pandoc-lua-engine";
                  ver = "0.5.0.2";
                  sha256 = "sha256-e5txwxgQGPVmcyZsABCjhtq9w4O7UGGveH4ZtSKbmWM=";
                } {});
                hslua = hself.callHackageDirect {
                  pkg = "hslua";
                  ver = "2.4.0";
                  sha256 = "sha256-br+uSVF7tx7LH636YojgJxvOA32XJti2m7Yf5SHEm4g=";
                } {};
                hslua-module-doclayout = hself.callHackageDirect {
                  pkg = "hslua-module-doclayout";
                  ver = "1.2.0.1";
                  sha256 = "sha256-1udisDrOjoormNtEO5q7zKyECNUu7+HIrcnqHjHyvZA=";
                } {};
                hslua-module-path = hself.callHackageDirect {
                  pkg = "hslua-module-path";
                  ver = "1.1.1";
                  sha256 = "sha256-sUatH0qA7afNMFaCQiFTh4idLBq/Mu/R0EpAJYjZtBU=";
                } {};
                hslua-module-system = hself.callHackageDirect {
                  pkg = "hslua-module-system";
                  ver = "1.2.3";
                  sha256 = "sha256-oK4LFzty2zacUyjhDKQtLNHXcQ/SoEij6T7RaDrQtnk=";
                } {};
                hslua-module-text = hself.callHackageDirect {
                  pkg = "hslua-module-text";
                  ver = "1.1.1";
                  sha256 = "sha256-x68vdBTOSR/YCJCLVgsF97GxCu4vG8Cj7DYpPW+YlKE=";
                } {};
                hslua-module-version = hself.callHackageDirect {
                  pkg = "hslua-module-version";
                  ver = "1.1.1";
                  sha256 = "sha256-823ZNb8CHrtk3RgYtG6p4qoxmyTGHVHxhr3YG8daxGg=";
                } {};
                hslua-module-zip = hself.callHackageDirect {
                  pkg = "hslua-module-zip";
                  ver = "1.1.4";
                  sha256 = "sha256-HYIni1uatiZJ3KqlCDn2bFi9pUqmGQNMfb5MfdNW9mg=";
                } {};
                hslua-repl = hself.callHackageDirect {
                  pkg = "hslua-repl";
                  ver = "0.1.2";
                  sha256 = "sha256-c6B5KATFzzkV3fD4vb/ZMOiy8PZ5eJnYQ2k1Z1CsYiM=";
                } {};
                pandoc-lua-marshal = hself.callHackageDirect {
                  pkg = "pandoc-lua-marshal";
                  ver = "0.3.2.1";
                  sha256 = "sha256-iuouPwYsUBUrliAoJV6wOGVUYlsh1yIONDTtlZOpDNc=";
                } {};
                pandoc-server = pkgs.haskell.lib.dontCheck (hself.callHackageDirect {
                  pkg = "pandoc-server";
                  ver = "0.1.1";
                  sha256 = "sha256-Tb+0OOSO1qI2k7AIbHmhNy5XD1gNWsrmNHlda/GsRJ8=";
                } {});
                hslua-cli = hself.callHackageDirect {
                  pkg = "hslua-cli";
                  ver = "1.4.4";
                  sha256 = "sha256-WaDuOkNuNPyUBm6gl5DQnjuyl73GQ6a9JnrNMHUtiqk=";
                } {};
                hslua-aeson = hself.callHackageDirect {
                  pkg = "hslua-aeson";
                  ver = "2.3.2";
                  sha256 = "sha256-BbWysq/injplaWuGd9dXkUiVzinZKeimYZE9wc1NUiE=";
                } {};
                hslua-classes = hself.callHackageDirect {
                  pkg = "hslua-classes";
                  ver = "2.3.2";
                  sha256 = "sha256-rfPvmxZwfEV+mlRv6YQSttCZggLB8UBW6sV4eC6BxPE=";
                } {};
                hslua-core = hself.callHackageDirect {
                  pkg = "hslua-core";
                  ver = "2.3.2.1";
                  sha256 = "sha256-nKJ4jjkHKrDMf39pcnXrIjfSJEs8zH6U7hM9rogRgs0=";
                } {};
                hslua-marshalling = hself.callHackageDirect {
                  pkg = "hslua-marshalling";
                  ver = "2.3.2";
                  sha256 = "sha256-0H+5/bCAN0EUG2JH6p42IbliDsWtXh3vI3nlDU+4uvc=";
                } {};
                hslua-objectorientation = hself.callHackageDirect {
                  pkg = "hslua-objectorientation";
                  ver = "2.4.0";
                  sha256 = "sha256-5ShHW5aRnX9fp5eAqUh3N7xQ48UCEVbDBW1IvsNUYzE=";
                } {};
                hslua-packaging = hself.callHackageDirect {
                  pkg = "hslua-packaging";
                  ver = "2.3.2";
                  sha256 = "sha256-FwsqfpoBrO/H+Vgi3JFjHbQyDzl/ffK5XEZr4vMGDmk=";
                } {};
                hslua-typing = hself.callHackageDirect {
                  pkg = "hslua-typing";
                  ver = "0.1.1";
                  sha256 = "sha256-RljGDysAiPPHXa5SI8oanzJ2JHvsDxNGt1guQqxoHm0=";
                } {};
              };
            };
          in
            pkgs.haskell.lib.dontCheck (
              hpkgs.callHackageDirect {
                pkg = "pandoc-cli";
                ver = "3.8.3";
                sha256 = "sha256-be+h2+6Se1MptUaisfrdaEDp1TcYKThLKrSgoAuQL8A=";
              } {}
            );

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
            rev = "0e8f2365bcbe54010b8120c04a7a2dcfc8119227"; # <-- 'master' branch
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
            pkgs.rPackages.shinyjs
            pkgs.rPackages.shinyWidgets
            pkgs.rPackages.tidyr
            pkgs.rPackages.xgboost

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
                rev = "df0a0ed192d3dfb8e795e2f304bf66e4681a28dc"; # <-- 'devel' branch
                sha256 = "1nq8akdg7vwldwgs72j0w4plwfwg428xz1h764yikij4m2l564qx";
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
                rev = "48f41e5d6cb86b926777ba44b465ac435ad0cb50"; # <-- 'devel' branch
                sha256 = "1kr1j0v2m3c7qwkhvi74vggmzcs5p1w1b0qppad9xp90x9av1fwl";
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

        quartoPatched = pkgs.quartoMinimal.overrideAttrs (old: {
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
            pandoc-3_8_3
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

            jdk25
            maven
            pandoc-3_8_3
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
              "JAVA_HOME=${pkgs.jdk25}"
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
              "QUARTO_PANDOC=${pandoc-3_8_3}/bin/pandoc"
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
            export JAVA_HOME="${pkgs.jdk25}"
            export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.liblapack}/lib:${pkgs.openblasCompat}/lib:$LD_LIBRARY_PATH"
            export PATH="$JAVA_HOME/bin:$PATH"
          '';
        };
      }
    );
}
