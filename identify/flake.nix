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
