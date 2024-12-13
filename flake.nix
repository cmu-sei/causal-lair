{
  description = "creates a dev container for AIR, with R and other tools";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils"; # Utility functions for Nix flakes

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # Main Nix package repository

    # Rust packages source
    rust-overlay = {
      url = "github:oxalica/rust-overlay?rev=260ff391290a2b23958d04db0d3e7015c8417401";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
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

    # VSCode Extensions
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    # Rust static analysis tools and scripts
    staticanalysis = {
      url = "github:rmdettmar/polar-static-analysis";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs = { flake-utils, nixpkgs, rust-overlay, myNeovimOverlay, nix-vscode-extensions, staticanalysis, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            rust-overlay.overlays.default
            myNeovimOverlay.overlays.default
          ];
        };

        # We create an account for the container user. These are necessary user files.
        baseInfo = with pkgs; [
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
        ];

        extensions = nix-vscode-extensions.extensions.${system};

        code-extended = pkgs.vscode-with-extensions.override {
          vscode = pkgs.code-server;
          vscodeExtensions = [
            extensions.open-vsx-release.rust-lang.rust-analyzer
            extensions.vscode-marketplace.vadimcn.vscode-lldb
            extensions.vscode-marketplace.fill-labs.dependi
            extensions.vscode-marketplace.tamasfe.even-better-toml
            extensions.vscode-marketplace.jnoortheen.nix-ide
            extensions.vscode-marketplace.jinxdash.prettier-rust
            extensions.vscode-marketplace.dustypomerleau.rust-syntax
            extensions.vscode-marketplace.ms-vscode.test-adapter-converter
            extensions.vscode-marketplace.hbenl.vscode-test-explorer
            extensions.vscode-marketplace.swellaby.vscode-rust-test-adapter
            extensions.vscode-marketplace.vscodevim.vim
            extensions.vscode-marketplace.redhat.vscode-yaml
            extensions.vscode-marketplace.ms-azuretools.vscode-docker
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
            pkgs.rPackages.udunits2      # libudunits2-dev
            pkgs.rPackages.AIPW
            pkgs.rPackages.devtools
            pkgs.rPackages.DiagrammeR
            pkgs.rPackages.e1071
            pkgs.rPackages.earth
            pkgs.rPackages.gifski
            pkgs.rPackages.hash
            pkgs.rPackages.here
            pkgs.rPackages.igraph
            pkgs.rPackages.knitr
            pkgs.rPackages.lintr
            pkgs.rPackages.magick
            pkgs.rPackages.nnet
            pkgs.rPackages.randomForest
            pkgs.rPackages.ranger
            pkgs.rPackages.Rdpack
            pkgs.rPackages.readr
            pkgs.rPackages.rJava
            pkgs.rPackages.rmarkdown
            pkgs.rPackages.rsconnect
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

        myEnv = pkgs.buildEnv {
          name = "my-env";
          paths = with pkgs; [

            gfortran
            gnupg
            ffmpeg                  # libavfilter-dev
            curlFull                # libcurl4-openssl-dev
            fontconfig              # libfontconfig1-dev
            freetype                # libfreetype6-dev
            fribidi                 # libfribidi-dev
            giflib                  # libgif-dev
            libgit2                 # libgit2-dev
            harfbuzz                # libharfbuzz-dev
            libjpeg                 # libjpeg-dev
            #lapack                  # liblapack-dev    <- seems to be provided by openblas
            imagemagick_light       # libmagick++-dev
            libmysqlclient          # libmariadb-dev
                                    # libmariadb-dev-compat
            openblas                # libopenblas-dev
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
            quarto

            # software-properties-common <- apt-specific, has no corollary in nix?

            wget
            zlib                    # zlib1g-dev

            jdk17
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
            lolcat
            lsof
            ncurses
            nix
            openssl
            openssl.dev
            pkg-config
            pkgs.stdenv.cc.cc.lib
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

            # If for some reason you don't want VS Code Server, remove this and
            # its overlay.
            code-extended

            # -- Rust Toolchain --
            rust-analyzer
            (rust-bin.selectLatestNightlyWith (toolchain: toolchain.default.override {
              extensions = [ "rust-src" ];

              # I think the default architecture for rust is whatever
              # architecture you happen to be working on. If we need to support
              # other architectures, this is where you do it.
              # targets = [ "wasm32-unknown-unknown" ];
            }))

            # -- Rust Static Analysis Tools --
            staticanalysis.packages.${system}.default

            sl3
            rWithPkgs
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

        codeSettings = pkgs.writeTextFile {
          name = "container-files/settings.json";
          destination = "/root/.local/share/code-server/User/settings.json";
          text = builtins.readFile ./container-files/settings.json;
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

      in
      {
        packages.default = pkgs.dockerTools.buildImage {
          name = "airtool-dev";
          tag = "latest";
          copyToRoot = [
            myEnv
            baseInfo
            fishConfig
            codeSettings
            license
            createUserScript
            fishPluginsFile
          ];
          config = {
            WorkingDir = "workspace";
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
              "PKG_CONFIG_PATH=${pkgs.openssl.dev}/lib/pkgconfig"
              "USER=root"
              "COREUTILS=${pkgs.uutils-coreutils-noprefix}"
              "CMAKE=/bin/cmake"
              "CMAKE_MAKE_PROGRAM=/bin/make"
              "LIBCLANG_PATH=${pkgs.libclang.lib}/lib/"
              "SHELL=/bin/fish"
              "JAVA_HOME=${pkgs.jdk17}"
              "PATH=${myEnv}/bin:/bin:/usr/bin:/root/.cargo/bin:$JAVA_HOME/bin"
              "QUARTO_R=${rWithPkgs}/bin"
              "LOCALE_ARCHIVE=${pkgs.glibcLocalesUtf8}/lib/locale/locale-archive"

              # Fish plugins environment variables
              "FISH_GRC=${pkgs.fishPlugins.grc}"
              "FISH_BASS=${pkgs.fishPlugins.bass}"
              "BOB_THE_FISH=${pkgs.fishPlugins.bobthefish}"
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
          '';
        };
      }
    );
}
