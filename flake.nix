{
  description = "ex-markdown dev shell";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
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
            ;
        };
      };
    });
}
