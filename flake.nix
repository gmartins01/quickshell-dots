{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    quickshell,
  }: let
    inherit (pkgs.lib) makeSearchPath;
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};

    qtDeps = [
      pkgs.quickshell
      pkgs.kdePackages.qtbase
      pkgs.kdePackages.qtdeclarative
    ];

    qmlPath = makeSearchPath "lib/qt-6/qml" qtDeps;
  in {
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = qtDeps;

      shellHook = ''
        # Required for qmlls to find the correct type declarations
        export QMLLS_BUILD_DIRS=${pkgs.kdePackages.qtdeclarative}/lib/qt-6/qml/:${quickshell}/lib/qt-6/qml/
        export QML_IMPORT_PATH=$PWD/
        export QML2_IMPORT_PATH="$QML2_IMPORT_PATH:${qmlPath}:${quickshell}/lib/qt-6/qml"
      '';
    };
  };
}
