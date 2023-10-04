{
  inputs = {
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
  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          overlays = [ (import rust-overlay) ];
          pkgs = import nixpkgs {
            inherit system overlays;
          };
          # rustToolchain = pkgs.pkgsBuildHost.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
          # rustToolchain = pkgs.pkgsBuildHost.rust-bin.stable."1.71.0".default;
          rustToolchain = pkgs.pkgsBuildHost.rust-bin.stable.latest.default;
            # new! 👇
          nativeBuildInputs = with pkgs; [ rustToolchain pkg-config ];
          # also new! 👇
          buildInputs = with pkgs; [ openssl darwin.apple_sdk.frameworks.SystemConfiguration ];
        in
        with pkgs;
        {
          devShells.default = mkShell {
            # 👇 and now we can just inherit them
            inherit buildInputs nativeBuildInputs;
          };
        }
      );
}
