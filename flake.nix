{
    description = "Rust Yew learning project"
    
    inputs = {
        flake-utils.url = "github:numtide/flake-utils";
        nixpkgs.url = "nixpkgs/nixpkgs-21.11";
    };

    outputs = { self, nixpkgs, flake-utils }:
        flake-utils.lib.eachDefaultSystem (system:
            let pkgs = import nixpkgs { inherit system; }; in {
                defaultPackage = pkgs.rustPlatform.buildRustPackage {
                    pname = "rust-yew-tut";
                    version = "0.0.1";
                    src = ./.;

                    cargoLock = {
                        lockFile = ./Cargo.lock;
                    };
                };
            }
        );
}