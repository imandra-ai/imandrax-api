{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  nativeBuildInputs = [
    pkgs.bash
    pkgs.cacert
    pkgs.curl
    pkgs.git
    pkgs.ocaml
    pkgs.ocamlPackages.ocamlformat_0_26_2
    pkgs.ocamlPackages.dune_3
  ];
}
