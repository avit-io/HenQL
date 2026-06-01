{
  description = "HenQL — typed PromQL DSL in Agda";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2511.912939";
    piforge = {
      url   = "github:avit-io/piforge";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    prometea = {
      url   = "github:avit-io/prometea";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.piforge.follows = "piforge";
    };
  };

  outputs = { self, nixpkgs, piforge, prometea }:
    let
      system = "x86_64-linux";
      pkgs   = nixpkgs.legacyPackages.${system};

      henqlLib = pkgs.stdenv.mkDerivation {
        name      = "henql-agda-lib";
        src       = builtins.path { path = ./.; name = "henql-src"; };
        dontBuild = true;
        installPhase = ''
          mkdir -p $out
          cp -r HenQL $out/
          printf 'name: henql\ninclude: .\ndepend: standard-library prometea\n' \
            > $out/henql.agda-lib
        '';
      };

      # Requires _cache and _prometea to be set (call after prometea's hooks).
      copyHenQL = ''
        _henql="$_cache/henql"
        if [ ! -d "$_henql" ]; then
          echo "henql: copying library to $_henql (one-time setup)..." >&2
          mkdir -p "$_henql"
          cp -r ${henqlLib}/. "$_henql/"
          chmod -R u+w "$_henql"
          printf 'name: henql\ninclude: .\ndepend: standard-library prometea\n' \
            > "$_henql/henql.agda-lib"
        fi
      '';

    in
    {
      packages.${system} = {
        lib     = henqlLib;
        default = henqlLib;
      };

      # Dev shell for working on HenQL itself: stdlib + prometea in AGDA_DIR.
      # Agda resolves henql.agda-lib by walking up from the source file.
      devShells.${system}.default = prometea.lib.mkShell {
        inherit pkgs;
        extraPackages = with pkgs; [ watchexec ];
      };

      # For consumers: stdlib + prometea + henql in AGDA_DIR.
      lib.mkShell = { pkgs, extraPackages ? [], shellHook ? "" }:
        prometea.lib.mkShell {
          inherit pkgs extraPackages;
          shellHook = copyHenQL + ''
            mkdir -p "$_cache/henql-env"
            printf '%s\n%s\n%s\n' \
              "$_stdlib/standard-library.agda-lib" \
              "$_prometea/prometea.agda-lib" \
              "$_henql/henql.agda-lib" \
              > "$_cache/henql-env/libraries"
            export AGDA_DIR="$_cache/henql-env"
          '' + shellHook;
        };
    };
}
