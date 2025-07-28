{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems =
        [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { pkgs, lib, ... }: {
        packages = rec {
          capt-bin = pkgs.stdenv.mkDerivation {
            name = "capt-bin";
            version = "0.1";

            src = ./.;

            buildPhase = ''
              make capt
            '';

            installPhase = ''
              mkdir -p $out/bin
              cp capt $out/bin/
              chmod +x $out/bin/capt
            '';
          };

          default = pkgs.stdenv.mkDerivation {
            name = "capt-canon-lbp-810";
            version = "0.1";

            src = ./.;

            buildPhase = ''
              true
            '';

            installPhase = ''
              mkdir -p $out/bin
              cp capt-print $out/bin/
              substituteInPlace $out/bin/capt-print \
                --replace /usr/bin/gs "${pkgs.ghostscript}/bin/gs" \
                --replace /usr/bin/capt "${capt-bin}/bin/capt"
              chmod +x $out/bin/capt-print

              mkdir -p $out/share/cups/model/canon/
              cp ppd/Canon-LBP-810-capt.ppd $out/share/cups/model/canon/
              substituteInPlace $out/share/cups/model/canon/* \
                --replace gs "${pkgs.ghostscript}/bin/gs" \
                --replace "|capt" "|${capt-bin}/bin/capt"
            '';
          };
        };
      };

      flake = { };
    };
}
