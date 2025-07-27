{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems =
        [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { pkgs, lib, ... }: { packages = {
        capt-print = pkgs.stdenv.mkDerivation {
          name = "capt";
          version = "0.1";

          src = ./.;

          buildPhase = ''
            make capt
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp capt $out/bin/
            chmod +x $out/bin/capt

            cp capt-print $out/bin/
            substituteInPlace $out/bin/capt-print \
              --replace /usr/bin/gs '${lib.getBin pkgs.ghostscript}'
            chmod +x $out/bin/capt-print

            mkdir -p $out/share/cups/model/canon/
            cp ppd/Canon-LBP-810-capt.ppd $out/share/cups/model/canon/
          '';
        };
      }; };

      flake = { };
    };
}
