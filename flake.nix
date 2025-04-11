{
  description = "Complete dev environment for Go, Python (Rasa/Langchain/OpenAI/Redis), Temporal, Node.js (React/Vite with Tailwind CSS).";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/21808d22b1cda1898b71cf1a1beb524a97add2c4";
  };

  outputs = { self, nixpkgs }:
    let
      allSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in {
      devShells = forAllSystems ({ pkgs }: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            apko
            gnutar
            go-task
            jq
            melange
            perl
            python39
            unzip
            yq-go
          ] ++ (if pkgs.stdenv.isLinux then [ inotify-tools ] else [])
            ++ (if pkgs.stdenv.isDarwin then [ fswatch ] else []);

          shellHook = ''
            export VENV=.venv
            if [ ! -d $VENV ]; then
              ${pkgs.python311}/bin/python -m venv $VENV
              source $VENV/bin/activate
              pip install --upgrade pip wheel setuptools
              pip install rasa langchain openai redis
            else
              source $VENV/bin/activate
            fi
            echo "✅ Dev environment ready: Go, Python (Rasa, Langchain, OpenAI), React/Vite with Tailwind CSS, Temporal CLI."
          '';

          buildInputs = [
            pkgs.python39
            pkgs.redis
          ];
        };
      });
    };
}