{
  description = "ex-markdown";

  inputs.fenix = {
    url = github:nix-community/fenix;
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.rust-analyzer-src.follows = "";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    fenix,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      inherit (pkgs) lib beamPackages libiconv;

      mixNixDeps = import ./mix.nix {inherit beamPackages lib;};

      src = ./.;
      rustToolchain = fenix.packages.${system}.stable.toolchain;
      nativePackage =
        (pkgs.makeRustPlatform {
          cargo = rustToolchain;
          rustc = rustToolchain;
        })
        .buildRustPackage {
          # TODO: parse Cargo.toml.
          pname = "comrak_rustler";
          version = "0.1.3";

          src = ./native/comrak_rustler;

          cargoLock.lockFile = ./native/comrak_rustler/Cargo.lock;
        };
    in rec {
      formatter = pkgs.alejandra;

      packages.default =
        (beamPackages.buildMix rec {
          # TODO: as above?  Should these versions stay in step?
          name = "markdown";
          version = "0.1.3";

          inherit src;

          patchPhase = ''
            mkdir -p priv/native
            find ${nativePackage}
            cp ${nativePackage}/lib/libcomrak_rustler.* priv/native/libcomrak_rustler.so
            export MARKDOWN_NATIVE_SKIP_COMPILATION="1"
          '';

          beamDeps = with mixNixDeps; [jason rustler html_entities];

          doInstallCheck = true;
          installCheckPhase = ''
            mix test --no-deps-check
          '';
        })
        .overrideAttrs (prev: {
          # buildMix clobbers the input passthru entirely.
          passthru =
            prev.passthru
            // {
              inherit src rustToolchain nativePackage;
            };
        });

      devShells.default = packages.default.overrideAttrs (prev: {
        nativeBuildInputs =
          prev.nativeBuildInputs
          ++ [
            rustToolchain
            # onig_sys
            libiconv
          ];
      });
    });
}
