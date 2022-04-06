{
    description = "Rust Yew learning project";
    
    inputs = {
        flake-utils.url = "github:numtide/flake-utils";
        nixpkgs.url = "github:NixOS/nixpkgs/release-21.11";
        rust-overlay = {
            url = "github:oxalica/rust-overlay";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = { self, nixpkgs, flake-utils, rust-overlay }:
        flake-utils.lib.eachDefaultSystem (system:
            let 
                overlays = [ rust-overlay.overlay ];
                pkgs = import nixpkgs { inherit overlays system; }; 
                rust = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
                inputs = [ rust pkgs.wasm-bindgen-cli pkgs.zlib ];
            in {
                defaultPackage = pkgs.rustPlatform.buildRustPackage {
                    pname = "rust-yew-tut";
                    version = "0.0.1";

                    src = ./.;

                    cargoLock = {
                        lockFile = ./Cargo.lock;
                    };

                    nativeBuildInputs = inputs;

                    buildPhase = ''
                        cargo build --release --target=wasm32-unknown-unknown
                        echo 'Creating out dir...'
                        mkdir -p $out/src;
                        # Optional, of course
                        # echo 'Copying package.json...'
                        # cp ./package.json $out/;
                        echo 'Generating node module...'
                        wasm-bindgen \
                        --target nodejs \
                        --out-dir $out/src \
                        target/wasm32-unknown-unknown/release/yew-tut.wasm;
                    '';

                    installPhase = "echo 'Skipping installPhase'";
                };

                devShell = with pkgs; mkShell {
                    buildInputs = [ rust rustfmt pre-commit rustPackages.clippy rls trunk wasm-bindgen-cli ];
                    RUST_SRC_PATH = rustPlatform.rustLibSrc;
                };
            }
        );
}