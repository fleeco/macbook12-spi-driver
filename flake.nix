{
  description = "Package the hello repeater.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.default =
      let
        pkgs = import nixpkgs {
          system = "x86_64-linux";
        };

        kernel = pkgs.linuxPackages.kernel;
      in


      pkgs.stdenv.mkDerivation {
        pname = "macbook12-spi-driver";
        version = "0.0.1";

        src = pkgs.fetchFromGitHub {
          owner = "marc-git";
          repo = "macbook12-spi-driver";
          rev = "b50cbf3c047acbcfd66dac4e8ebb649d0f4de3c8";
          hash = "sha256-8n55lV9YHwe9AyjgbnyggovVG+lHnp8iQGe92rbgrU8=";
        };

        patches = [
          ./linux-6.4.patch
        ];

        nativeBuildInputs = kernel.moduleBuildDependencies;

        makeFlags = [
          "KVER=${kernel.modDirVersion}"
          "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
        ];

        installPhase = ''
          install -D *.ko -t "$out/lib/modules/${kernel.modDirVersion}/kernel/drivers/misc/"
        '';
      };
  };
}

