# in shell.nix
{ pkgs ? import <nixpkgs> { } }:
with pkgs;
mkShell
{
  packages = [
    go # 1.20.8 is available as of writing this, but newest is 1.21.1...
    golangci-lint # 1.54.2 which is newest
  ];
}
