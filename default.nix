{ pkgs ? import <nixpkgs> {} }:
with pkgs.haskell.lib;
let
  pg_query = pkgs.stdenv.mkDerivation {
    name = "pg_query";
    src = pkgs.fetchFromGitHub {
      owner = "pganalyze";
      repo = "libpg_query";
      rev = "a2482061d8ad8731c485b3cb7e8c9109b7b3529b";
      sha256 = "1zdq3lq0ym329gjak8xj2a9i0psp2qvr7imlm1cy4in3rwx9vdf6";
    };
    buildInputs = with pkgs; [ clang which protobufc ] ;
    patchPhase = with pkgs; ''
      ${gnused}/bin/sed -i.bak 's/prefix = .*/prefix = $(out)/g' Makefile
    '' + pkgs.lib.optionalString pkgs.stdenv.isDarwin ''
      ${gnused}/bin/sed -i.bak 's/-Wl,-soname,$(SONAME)/-Wl/g' Makefile
    '';
  };
  pgQuery =
    pkgs.haskellPackages.callCabal2nix "pg-query" ./. { inherit pg_query; };
  lib =
    disableCabalFlag
      (appendConfigureFlags pgQuery
        [ "--extra-include-dirs=${pg_query}/include"
          "--extra-lib-dirs=${pg_query}/lib"
        ]) "default_paths";
in
  lib
