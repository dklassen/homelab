{
  description = "ClickHouse on the prairie";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.clickhouse
            pkgs.go-task
            pkgs.jq
            pkgs.k3d
            pkgs.kubectl
            pkgs.kubernetes-helm
          ];

          shellHook = ''

          if [[ -z "$CLICKHOUSE_DEV_SHELL" ]]; then
            echo "dev shell"
            echo "  k3d     $(k3d version --short 2>/dev/null || echo n/a)"
            echo "  kubectl $(kubectl version --client --short 2>/dev/null || echo n/a)"
            echo "  helm    $(helm version --short 2>/dev/null || echo n/a)"
            echo "  task    $(task --version 2>/dev/null || echo n/a)"

            // Prevent infinite shell spawning when the user is already in a dev shell
            // wonky 
            //  [ :TOODO:] fix 
              export CLICKHOUSE_DEV_SHELL=1
              exec zsh
            fi
          '';
        };
      }
    );
}
