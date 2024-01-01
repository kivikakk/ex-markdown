{
  description = "ex-markdown dev shell";

  inputs.fenix = {
    url = "github:nix-community/fenix";
    inputs.nixpkgs.follows = "nixpkgs";
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
      inherit (pkgs) lib;
    in rec {
      formatter = pkgs.alejandra;

      devShells.default = pkgs.mkShell {
        nativeBuildInputs = builtins.attrValues {
          inherit
            (pkgs)
            elixir
            # erlang
            
            hex
            libiconv
            ;

          inherit
            (fenix.packages.${system}.stable)
            toolchain
            ;
        };
      };
    });
}
