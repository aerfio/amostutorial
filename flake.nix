{
  inputs = {
    crane = {
      url = "github:ipetkov/crane";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        rust-overlay.follows = "rust-overlay";
        flake-utils.follows = "flake-utils";
      };
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };
  outputs = { self, nixpkgs, flake-utils, rust-overlay, crane }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          overlays = [ (import rust-overlay) ];
          pkgs = import nixpkgs {
            inherit system overlays;
                # 👇 yolo
            config.allowUnfree = true;
          };
          # rustToolchain = pkgs.pkgsBuildHost.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
          # rustToolchain = pkgs.pkgsBuildHost.rust-bin.stable."1.71.0".default;
          rustToolchain = pkgs.pkgsBuildHost.rust-bin.stable.latest.default;
            # new! 👇
          nativeBuildInputs = with pkgs; [ rustToolchain pkg-config ] ++ lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.SystemConfiguration ];
          # also new! 👇
          buildInputs = with pkgs; [];
          # buildInputs = with pkgs; [ darwin.apple_sdk.frameworks.SystemConfiguration ];
          # this is how we can tell crane to use our toolchain!
          craneLib = (crane.mkLib pkgs).overrideToolchain rustToolchain;
          # cf. https://crane.dev/API.html#libcleancargosource
          src = craneLib.cleanCargoSource ./.;
                # because we'll use it for both `cargoArtifacts` and `bin`
          commonArgs = {
            inherit src buildInputs nativeBuildInputs;
          };
          cargoArtifacts = craneLib.buildDepsOnly commonArgs;
          # remember, `set1 // set2` does a shallow merge:
          bin = craneLib.buildPackage (commonArgs // {
            inherit cargoArtifacts;
          });
          dockerImage = pkgs.dockerTools.buildImage {
            name = "amostutorial";
            tag = "latest";
            copyToRoot = [ bin ];
            config = {
              Cmd = [ "${bin}/bin/amostutorial" ];
            };
          };
        in
        with pkgs;
        {
          packages =
            {
              # that way we can build `bin` specifically,
              # but it's also the default.
              inherit bin dockerImage;
              default = bin;
            };
          devShells.default = mkShell {
            # instead of passing `buildInputs` / `nativeBuildInputs`,
            # we refer to an existing derivation here
            inputsFrom = [ bin ];
          };
        }
      );
}
