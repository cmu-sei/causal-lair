{
  description = "creates a dev container for polar, with R setup per the dev shell example";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils"; # Utility functions for Nix flakes
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # Main Nix package repository
    rust-overlay.url = "github:oxalica/rust-overlay?rev=260ff391290a2b23958d04db0d3e7015c8417401";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
    rust-overlay.inputs.flake-utils.follows = "flake-utils";
    myNeovimOverlay.url = "github:daveman1010221/nix-neovim";
    myNeovimOverlay.inputs.nixpkgs.follows = "nixpkgs";
    myNeovimOverlay.inputs.flake-utils.follows = "flake-utils";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";
    nix-vscode-extensions.inputs.flake-utils.follows = "flake-utils";
    staticanalysis.url = "github:rmdettmar/polar-static-analysis";
    staticanalysis.inputs.nixpkgs.follows = "nixpkgs";
    staticanalysis.inputs.flake-utils.follows = "flake-utils";
  };

  outputs = { self, flake-utils, nixpkgs, rust-overlay, myNeovimOverlay, nix-vscode-extensions, staticanalysis, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ rust-overlay.overlays.default myNeovimOverlay.overlays.default ];
        };
        # This is needed since VSCode Devcontainers need the following files in order to function.
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

        myEnv = pkgs.buildEnv {
          name = "my-env";
          paths = with pkgs; [
            # -- Basic Required Files --
            bash # Basic bash
            uutils-coreutils-noprefix # Essential utilities
            gnutar
            gzip
            gnugrep
            gnused
            pkgs.stdenv.cc.cc.lib
            fish
            fishPlugins.bass
            fishPlugins.bobthefish
            fishPlugins.foreign-env
            fishPlugins.grc
            figlet
            lolcat
            cacert
            openssl
            openssl.dev
            code-extended
            rust-analyzer

            which
            nvim-pkg
            curl
            lsof
            strace
            ripgrep
            tree
            tree-sitter
            nix
            git
            fzf
            fd
            eza
            findutils
            gnugrep
            getent
            gawk
            jq
            ps
            ncurses

            # -- Compilers, Etc. --
            gcc
            grc
            cmake
            gnumake
            libclang
            glibc

            # -- Rust toolchain --
            (rust-bin.selectLatestNightlyWith (toolchain: toolchain.default.override {
              extensions = [ "rust-src" ];
              targets = [ "wasm32-unknown-unknown" "wasm32-wasip1" ];
            }))
            pkg-config

            # -- Static Analysis Tools --
            staticanalysis.packages.${system}.default

            # -- R and R packages (from your dev shell example) --
            R
            rPackages.lintr
            rPackages.assertthat
            rPackages.caret
            rPackages.delayed
            rPackages.devtools
            rPackages.DiagrammeR
            rPackages.dplyr
            rPackages.ggplot2
            rPackages.gifski
            rPackages.hash
            rPackages.here
            rPackages.igraph
            rPackages.knitr
            rPackages.magick
            rPackages.origami
            rPackages.readr
            rPackages.rJava
            rPackages.rmarkdown
            rPackages.rsconnect
            rPackages.sets
            rPackages.shiny
            rPackages.shinyWidgets
            rPackages.tidyr
            rPackages.AIPW
            rPackages.e1071
            rPackages.earth
            rPackages.nnet
            rPackages.randomForest
            rPackages.ranger
            rPackages.xgboost
          ];
          pathsToLink = [
            "/bin"
            "/lib"
            "/inc"
            "/etc/ssl/certs"
          ];
        };

        sl3 = pkgs.rPackages.buildRPackage {
          name = "sl3";
          src = pkgs.fetchFromGitHub{
            owner = "tlverse";
            repo = "sl3";
            rev = "0m1cg7icdza230l2jlpkwf9s8b4pwbyn0xj5vrk6yq6lfq8dgvpr";
            sha256 = "12mhmmibizbxgmsns80c8h97rr7rclv9hz98zpgsl26hw3s4l0vm";
          };
          propagatedBuildInputs = with pkgs.rPackages; [
            assertthat
            caret
            delayed
            devtools
            DiagrammeR
            dplyr
            ggplot2
            gifski
            hash
            here
            igraph
            knitr
            magick
            origami
            readr
            rJava
            rmarkdown
            rsconnect
            sets
            shiny
            shinyWidgets
            tidyr
            AIPW
            e1071
            earth
            nnet
            randomForest
            ranger
            xgboost
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

        # Predicate for filterSource if you still need it
        predicate = path: type:
        type != "directory" || (baseNameOf path != ".git");

        localPath = toString ./.; # Convert flake path to a string path
        filteredSrc = builtins.filterSource predicate localPath;

        # Now we create a derivation that:
        # 1. Copies filteredSrc into $out (our "workspace")
        # 2. Downloads the Tetrad JAR into $out/inst
        # 3. Runs the R dependency script from within $out
        myWorkspace = pkgs.runCommand "workspace" {
          buildInputs = [
            pkgs.R
          ];
        } ''
            mkdir $out
            cp -r ${filteredSrc}/* $out/
            cd $out
            #${pkgs.R}/bin/Rscript $out/scripts/install_dependencies.R
          '';
      in
      {
        packages.default = pkgs.dockerTools.buildImage {
          name = "polar-dev";
          tag = "latest";
          copyToRoot = [
            myEnv
            baseInfo
            fishConfig
            codeSettings
            license
            createUserScript
            fishPluginsFile
            myWorkspace
            sl3
          ];
          config = {
            WorkingDir = "workspace";
            Env = [
              # Certificates and environment setup
              "SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
              "SSL_CERT_DIR=/etc/ssl/certs"
              "CARGO_HTTP_CAINFO=/etc/ssl/certs/ca-bundle.crt"
              "CC=gcc"
              "CXX=g++"
              "LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib"
              "PKG_CONFIG_PATH=${pkgs.openssl.dev}/lib/pkgconfig"
              "PATH=/bin:/usr/bin:${myEnv}/bin:/root/.cargo/bin"
              "USER=root"
              "COREUTILS=${pkgs.uutils-coreutils-noprefix}"
              "CMAKE=/bin/cmake"
              "CMAKE_MAKE_PROGRAM=/bin/make"
              "LIBCLANG_PATH=${pkgs.libclang.lib}/lib/"
              "SHELL=/bin/fish"

              # Fish plugins environment variables
              "FISH_GRC=${pkgs.fishPlugins.grc}"
              "FISH_BASS=${pkgs.fishPlugins.bass}"
              "BOB_THE_FISH=${pkgs.fishPlugins.bobthefish}"
            ];
            Volumes = { };
            Cmd = [ "/bin/fish" ]; # Default command
            ExposedPorts = ["4173"];
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

            #mkdir -p /workspace/inst
            #cd /workspace/inst
            #curl -fsSLO "https://s01.oss.sonatype.org/content/repositories/releases/io/github/cmu-phil/tetrad-gui/7.6.5/tetrad-gui-7.6.5-launch.jar"
            #cd /

            #${pkgs.R}/bin/Rscript /workspace/scripts/install_dependencies.R
          '';
        };
      }
    );
}
